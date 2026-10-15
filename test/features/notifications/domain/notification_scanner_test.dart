import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:finan2/features/investments/data/investment_model.dart';
import 'package:finan2/features/notification_prefs/data/notification_prefs.dart';
import 'package:finan2/features/notifications/domain/entities/household_notification.dart';
import 'package:finan2/features/notifications/data/notification_mapper.dart';
import 'package:finan2/features/notifications/data/notification_repository.dart';
import 'package:finan2/features/notifications/data/notification_scan_sources.dart';
import 'package:finan2/features/notifications/domain/notification_scanner.dart';
import 'package:finan2/features/notifications/presentation/l10n_notification_texts.dart';
import 'package:finan2/features/recurring_bills/domain/entities/recurring_bill.dart';
import 'package:finan2/features/savings_challenge/data/savings_challenge_model.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_model.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transfers/data/transfer_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _householdId = 'h1';
final _now = DateTime(2026, 7, 9);

Debt _debt({String id = 'd1', int paymentDay = 10, int balance = 1000000, String createdBy = ''}) {
  return Debt(
    id: id,
    name: 'Tarjeta',
    type: DebtType.tarjeta,
    balance: balance,
    rate: 28,
    paymentDay: paymentDay,
    creditLimit: 5000000,
    minPayment: 180000,
    extraPayment: 0,
    createdBy: createdBy,
  );
}

SavingsGoal _goal({
  String id = 'g1',
  int targetAmount = 1000000,
  List<Contribution> contributions = const [],
  String createdBy = '',
}) {
  return SavingsGoal(
    id: id,
    name: 'Viaje',
    iconSlug: 'viaje',
    targetAmount: targetAmount,
    targetDate: null,
    monthlyContribution: 100000,
    interestRate: 0,
    contributions: contributions,
    createdBy: createdBy,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late NotificationScanner scanner;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    scanner = NotificationScanner(
      NotificationRepository(firestore: firestore),
      const L10nNotificationTexts(),
    );
  });

  Future<List<HouseholdNotification>> readAll() async {
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('notifications')
        .get();
    return snap.docs.map(householdNotificationFromFirestore).toList();
  }

  group('debt payment due', () {
    test('notifies when payment day is within 2 days', () async {
      final returned = await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day + 2)],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(returned, hasLength(1));
      expect(returned.single.notification.type, NotificationType.debtDue);
      // A household-level alert (nobody "did" this) excludes the scanning
      // device's own user - they're presumably looking at the app right now.
      expect(returned.single.excludePushUid, 'u1');
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.debtDue);
    });

    test('notifies 3 days before, the start of the countdown', () async {
      final returned = await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day + 3)],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(returned, hasLength(1));
      expect(returned.single.notification.body, contains('vence en 3 días'));
    });

    test('on the due day itself, uses the "hoy" wording', () async {
      final returned = await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day)],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(returned, hasLength(1));
      expect(returned.single.notification.title, 'Hoy pagas Tarjeta');
      expect(returned.single.notification.body, 'Hoy es el día de pago de tu deuda Tarjeta.');
    });

    test('does not notify when payment day is more than 3 days away', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day + 10)], // well outside the ≤3-day window
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('the countdown fires again on each new day, not just once for the month', () async {
      final debt = _debt(paymentDay: _now.day + 3);
      for (var daysBefore = 3; daysBefore >= 0; daysBefore--) {
        final today = _now.add(Duration(days: 3 - daysBefore));
        final returned = await scanner.scan(
          householdId: _householdId,
          currentUid: 'u1',
          debts: [debt],
          goals: const [],
          budget: const {},
          transactionsThisMonth: const [],
          categories: const [],
          prefs: NotificationPrefs.defaults,
          now: today,
        );
        expect(returned, hasLength(1), reason: 'day $daysBefore before should still notify');
      }
      // 4 distinct notifications, one per day of the countdown.
      expect(await readAll(), hasLength(4));
    });

    test('does not notify for an already-paid-off debt', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(balance: 0, paymentDay: _now.day)],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('re-scanning the same day never duplicates the notification', () async {
      final debts = [_debt(paymentDay: _now.day)];
      for (var i = 0; i < 3; i++) {
        final returned = await scanner.scan(
          householdId: _householdId,
          currentUid: 'u1',
          debts: debts,
          goals: const [],
          budget: const {},
          transactionsThisMonth: const [],
          categories: const [],
          prefs: NotificationPrefs.defaults,
          now: _now,
        );
        expect(returned, i == 0 ? hasLength(1) : isEmpty);
      }
      expect(await readAll(), hasLength(1));
    });

    test('respects prefs.debtPayments == false', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day)],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(debtPayments: false),
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });
  });

  group('goal near completion', () {
    test('notifies between 90% and 100%', () async {
      final goal = _goal(
        targetAmount: 1000000,
        contributions: [Contribution(date: _now, amount: 950000, createdBy: 'u1')],
      );
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.goalNear);
    });

    test('does not notify once the goal is fully met', () async {
      final goal = _goal(
        targetAmount: 1000000,
        contributions: [Contribution(date: _now, amount: 1000000, createdBy: 'u1')],
      );
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('does not notify below 90%', () async {
      final goal = _goal(
        targetAmount: 1000000,
        contributions: [Contribution(date: _now, amount: 500000, createdBy: 'u1')],
      );
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });
  });

  group('budget exceeded', () {
    test('notifies when real spend exceeds the plan', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: const [],
        goals: const [],
        budget: const {'ocio': 300000},
        transactionsThisMonth: [
          Movement(
            id: 'tx1',
            amount: 390000,
            type: CategoryType.gasto,
            categoryId: 'ocio',
            accountId: 'acc',
            description: '',
            date: _now,
            createdBy: 'u1',
          ),
        ],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.budgetExceeded);
    });

    test('does not notify when real spend is within the plan', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: const [],
        goals: const [],
        budget: const {'ocio': 300000},
        transactionsThisMonth: [
          Movement(
            id: 'tx1',
            amount: 200000,
            type: CategoryType.gasto,
            categoryId: 'ocio',
            accountId: 'acc',
            description: '',
            date: _now,
            createdBy: 'u1',
          ),
        ],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });
  });

  group('contribution by partner', () {
    // partnerActivity defaults to off (the mockup itself shows this toggle
    // unchecked by default), so these enable it explicitly.
    test('notifies when the OTHER member contributed', () async {
      final goal = _goal(
        contributions: [Contribution(date: _now, amount: 500000, createdBy: 'partner')],
      );
      final returned = await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.contribution);
      // The push must exclude the contributor ("partner"), not the current
      // device ("me") - "me" is exactly who needs to be told about it.
      expect(returned.single.excludePushUid, 'partner');
    });

    test('does not notify for my own contribution', () async {
      final goal = _goal(
        contributions: [Contribution(date: _now, amount: 500000, createdBy: 'me')],
      );
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('respects prefs.partnerActivity == false (its own default)', () async {
      final goal = _goal(
        contributions: [Contribution(date: _now, amount: 500000, createdBy: 'partner')],
      );
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });
  });

  group('partner created an entity', () {
    test('a new debt from the partner notifies', () async {
      final returned = await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: [_debt(paymentDay: _now.day + 20, createdBy: 'partner')],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.partnerActivity);
      // The push must exclude the creator ("partner"), not the current
      // device ("me") - this was the bug: it used to exclude "me" instead,
      // so the person who needed the push never got it.
      expect(returned.single.excludePushUid, 'partner');
    });

    test('a new savings goal from the partner notifies', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: [_goal(createdBy: 'partner')],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.partnerActivity);
    });

    test('a new transaction from the partner notifies', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: const [],
        budget: const {},
        transactionsThisMonth: [
          Movement(
            id: 'tx1',
            amount: 50000,
            type: CategoryType.gasto,
            categoryId: 'ocio',
            accountId: 'acc',
            description: 'Cine',
            date: _now,
            createdBy: 'partner',
          ),
        ],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.partnerActivity);
      expect(notifications.single.id, 'partner_tx_tx1');
      expect(notifications.single.body, 'Cine');
    });

    test('a new transfer from the partner notifies', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        transfers: [
          Transfer(
            id: 't1',
            amount: 100000,
            fromAccountId: 'a1',
            toAccountId: 'a2',
            date: _now,
            createdBy: 'partner',
          ),
        ],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.partnerActivity);
      expect(notifications.single.id, 'partner_transfer_t1');
    });

    test('a new account, investment, bill, category and challenge from the '
        'partner each notify once', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: [
          const Category(
            id: 'c1',
            name: 'Ocio',
            type: CategoryType.gasto,
            iconSlug: 'ocio',
            color: 0xFF0F9D74,
            createdBy: 'partner',
          ),
        ],
        accounts: [
          const Account(
            id: 'a1',
            name: 'Nequi',
            type: AccountType.billetera,
            balance: 0,
            includeInAvailable: true,
            createdBy: 'partner',
          ),
        ],
        investments: [
          const Investment(
            id: 'i1',
            name: 'CDT',
            kind: InvestmentKind.rentaFija,
            rate: 12,
            investedAmount: 1000000,
            currentValue: 1000000,
            createdBy: 'partner',
          ),
        ],
        recurringBills: [
          const RecurringBill(
            id: 'b1',
            name: 'Arriendo',
            type: CategoryType.factura,
            categoryId: 'c1',
            accountId: 'a1',
            amount: 500000,
            dayOfMonth: 5,
            createdBy: 'partner',
          ),
        ],
        savingsChallenge: const SavingsChallenge(
          id: 'ch1',
          name: 'Reto',
          cellAmounts: [1000],
          done: [false],
          createdBy: 'partner',
        ),
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      // The IDs are stored, so they must never change - or everything notifies again.
      expect((await readAll()).map((n) => n.id).toSet(), {
        'partner_category_c1',
        'partner_account_a1',
        'partner_investment_i1',
        'partner_bill_b1',
        'partner_challenge_ch1',
      });
    });

    test('does not notify for my own creation', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: [_debt(paymentDay: _now.day + 20, createdBy: 'me')],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('respects prefs.partnerActivity == false', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: [_debt(paymentDay: _now.day + 20, createdBy: 'partner')],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('re-scanning never duplicates the notification', () async {
      final debts = [_debt(paymentDay: _now.day + 20, createdBy: 'partner')];
      for (var i = 0; i < 3; i++) {
        await scanner.scan(
          householdId: _householdId,
          currentUid: 'me',
          debts: debts,
          goals: const [],
          budget: const {},
          transactionsThisMonth: const [],
          categories: const [],
          prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
          now: _now,
        );
      }
      expect(await readAll(), hasLength(1));
    });
  });
}
