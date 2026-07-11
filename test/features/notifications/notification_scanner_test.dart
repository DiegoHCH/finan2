import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/debts/data/debt_model.dart';
import 'package:finan2/features/notification_prefs/data/notification_prefs.dart';
import 'package:finan2/features/notifications/data/notification_model.dart';
import 'package:finan2/features/notifications/data/notification_repository.dart';
import 'package:finan2/features/notifications/data/notification_scanner.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

String _fmt(num n) => '\$$n';
const _householdId = 'h1';
final _now = DateTime(2026, 7, 9);

Debt _debt({String id = 'd1', int paymentDay = 10, int balance = 1000000}) {
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
  );
}

SavingsGoal _goal({
  String id = 'g1',
  int targetAmount = 1000000,
  List<Contribution> contributions = const [],
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
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late NotificationScanner scanner;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    scanner = NotificationScanner(NotificationRepository(firestore: firestore));
  });

  Future<List<HouseholdNotification>> readAll() async {
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('notifications')
        .get();
    return snap.docs.map(HouseholdNotification.fromFirestore).toList();
  }

  group('debt payment due', () {
    test('notifies when payment day is within 2 days', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day + 2)],
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        formatMoney: _fmt,
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.debtDue);
    });

    test('does not notify when payment day is more than 2 days away', () async {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        debts: [_debt(paymentDay: _now.day + 10)], // 19th, well outside the ≤2-day window
        goals: const [],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults,
        formatMoney: _fmt,
        now: _now,
      );
      expect(await readAll(), isEmpty);
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
        formatMoney: _fmt,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });

    test('re-scanning the same month never duplicates the notification', () async {
      final debts = [_debt(paymentDay: _now.day)];
      for (var i = 0; i < 3; i++) {
        await scanner.scan(
          householdId: _householdId,
          currentUid: 'u1',
          debts: debts,
          goals: const [],
          budget: const {},
          transactionsThisMonth: const [],
          categories: const [],
          prefs: NotificationPrefs.defaults,
          formatMoney: _fmt,
          now: _now,
        );
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
        formatMoney: _fmt,
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
        formatMoney: _fmt,
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
        formatMoney: _fmt,
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
        formatMoney: _fmt,
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
        formatMoney: _fmt,
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
        formatMoney: _fmt,
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
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'me',
        debts: const [],
        goals: [goal],
        budget: const {},
        transactionsThisMonth: const [],
        categories: const [],
        prefs: NotificationPrefs.defaults.copyWith(partnerActivity: true),
        formatMoney: _fmt,
        now: _now,
      );
      final notifications = await readAll();
      expect(notifications, hasLength(1));
      expect(notifications.single.type, NotificationType.contribution);
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
        formatMoney: _fmt,
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
        formatMoney: _fmt,
        now: _now,
      );
      expect(await readAll(), isEmpty);
    });
  });
}
