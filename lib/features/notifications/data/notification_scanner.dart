import '../../../l10n/l10n.dart';
import '../../accounts/data/account_model.dart';
import '../../categories/data/category_model.dart';
import '../../debts/data/debt_model.dart';
import '../../investments/data/investment_model.dart';
import '../../notification_prefs/data/notification_prefs.dart';
import '../../recurring_bills/data/recurring_bill_model.dart';
import '../../savings_challenge/data/savings_challenge_model.dart';
import '../../savings_goals/data/savings_goal_model.dart';
import '../../transactions/domain/entities/movement.dart';
import '../../transfers/data/transfer_model.dart';
import 'notification_model.dart';
import 'notification_repository.dart';

/// A notification the scan just created, plus who its push should skip.
/// For a household-level alert (debt due, budget exceeded...) that's the
/// current device, since whoever's scan just detected it is presumably
/// looking at the app right now. For something a household member DID
/// (partner activity, a contribution), it's THAT member - not the current
/// device - since they're the one who already sees it live; the whole point
/// of the push is to reach the other member who didn't just act.
class ScannedNotification {
  const ScannedNotification({required this.notification, required this.excludePushUid});

  final HouseholdNotification notification;
  final String excludePushUid;
}

/// Detects the household's alert-worthy conditions and writes any missing
/// notification (deterministic IDs keep re-scans idempotent). Titles and
/// bodies are stored text, written in the language of the device whose scan
/// creates them - whoever reads them later sees that language. Runs entirely
/// on the client - there's no backend to trigger this on a schedule, so it
/// re-checks whenever the relevant data changes while the app is open.
class NotificationScanner {
  const NotificationScanner(this._repository);

  final NotificationRepository _repository;

  /// Returns every notification actually created this scan (as opposed to
  /// ones that already existed) - callers use this to trigger a real push
  /// only for genuinely new alerts.
  Future<List<ScannedNotification>> scan({
    required String householdId,
    required String currentUid,
    required List<Debt> debts,
    required List<SavingsGoal> goals,
    required Map<String, int> budget,
    required List<Movement> transactionsThisMonth,
    required List<Category> categories,
    required NotificationPrefs prefs,
    List<Account> accounts = const [],
    List<Investment> investments = const [],
    List<RecurringBill> recurringBills = const [],
    List<Transfer> transfers = const [],
    SavingsChallenge? savingsChallenge,
    DateTime? now,
  }) async {
    now ??= DateTime.now();
    final created = <ScannedNotification>[];

    if (prefs.debtPayments) {
      await _scanDebts(created, householdId, debts, now, currentUid);
    }
    if (prefs.goalProgress) {
      await _scanGoalProgress(created, householdId, goals, now, currentUid);
    }
    if (prefs.budgetExceeded) {
      await _scanBudget(
        created,
        householdId,
        budget,
        transactionsThisMonth,
        categories,
        now,
        currentUid,
      );
    }
    if (prefs.partnerActivity) {
      await _scanContributions(created, householdId, goals, currentUid);
      await _scanPartnerCreated(
        created: created,
        householdId: householdId,
        currentUid: currentUid,
        now: now,
        transactionsThisMonth: transactionsThisMonth,
        transfers: transfers,
        debts: debts,
        accounts: accounts,
        investments: investments,
        recurringBills: recurringBills,
        categories: categories,
        savingsChallenge: savingsChallenge,
        goals: goals,
      );
    }
    return created;
  }

  Future<void> _scanDebts(
    List<ScannedNotification> created,
    String householdId,
    List<Debt> debts,
    DateTime now,
    String currentUid,
  ) async {
    final l10n = currentL10n;
    for (final debt in debts) {
      if (debt.balance <= 0) continue;
      final daysUntil = _daysUntilDayOfMonth(debt.paymentDay, now);
      if (daysUntil < 0 || daysUntil > 3) continue;
      // One notification per day of the countdown (day included in the ID),
      // not one per month - re-scanning the same day never duplicates it,
      // but each new day of the 4-day window (3, 2, 1, 0 días) gets its own.
      final id = 'debt_due_${debt.id}_${now.year}_${now.month}_${now.day}';
      final isToday = daysUntil == 0;
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.debtDue,
          title: isToday
              ? l10n.notificationsDebtDueTodayTitle(debt.name)
              : l10n.notificationsDebtDueSoonTitle(debt.name),
          body: isToday
              ? l10n.notificationsDebtDueTodayBody(debt.name)
              : l10n.notificationsDebtDueSoonBody(debt.name, daysUntil),
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: currentUid));
      }
    }
  }

  Future<void> _scanGoalProgress(
    List<ScannedNotification> created,
    String householdId,
    List<SavingsGoal> goals,
    DateTime now,
    String currentUid,
  ) async {
    final l10n = currentL10n;
    for (final goal in goals) {
      final fraction = goal.progressFractionAsOf(now);
      if (fraction < 0.9 || fraction >= 1.0) continue;
      final id = 'goal_near_${goal.id}';
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.goalNear,
          title: l10n.notificationsGoalNearTitle,
          body: l10n.notificationsGoalNearBody(goal.name, (fraction * 100).round()),
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: currentUid));
      }
    }
  }

  Future<void> _scanBudget(
    List<ScannedNotification> created,
    String householdId,
    Map<String, int> budget,
    List<Movement> transactionsThisMonth,
    List<Category> categories,
    DateTime now,
    String currentUid,
  ) async {
    final spendByCategory = <String, int>{};
    for (final tx in transactionsThisMonth) {
      if (tx.isIncome) continue;
      spendByCategory[tx.categoryId] = (spendByCategory[tx.categoryId] ?? 0) + tx.amount;
    }
    final categoryById = {for (final c in categories) c.id: c};
    final l10n = currentL10n;

    for (final entry in budget.entries) {
      final planned = entry.value;
      if (planned <= 0) continue;
      final real = spendByCategory[entry.key] ?? 0;
      if (real <= planned) continue;
      final id = 'budget_exceeded_${entry.key}_${now.year}_${now.month}';
      final categoryName = categoryById[entry.key]?.name ?? l10n.notificationsUnknownCategory;
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.budgetExceeded,
          title: l10n.notificationsBudgetExceededTitle,
          body: l10n.notificationsBudgetExceededBody(categoryName),
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: currentUid));
      }
    }
  }

  Future<void> _scanContributions(
    List<ScannedNotification> created,
    String householdId,
    List<SavingsGoal> goals,
    String currentUid,
  ) async {
    final l10n = currentL10n;
    for (final goal in goals) {
      for (final contribution in goal.contributions) {
        if (contribution.createdBy.isEmpty || contribution.createdBy == currentUid) {
          continue;
        }
        final id = 'contribution_${goal.id}_${contribution.date.millisecondsSinceEpoch}';
        final notification = await _repository.createIfAbsent(
          householdId,
          id,
          HouseholdNotification(
            id: id,
            type: NotificationType.contribution,
            title: l10n.notificationsContributionTitle,
            body: l10n.notificationsContributionBody(goal.name),
            createdAt: contribution.date,
            read: false,
          ),
        );
        if (notification != null) {
          created.add(
            ScannedNotification(notification: notification, excludePushUid: contribution.createdBy),
          );
        }
      }
    }
  }

  /// One notification per record the OTHER member created, across every
  /// entity that tracks a `createdBy`. Deterministic per-record IDs keep
  /// this idempotent the same way every other scan is.
  Future<void> _scanPartnerCreated({
    required List<ScannedNotification> created,
    required String householdId,
    required String currentUid,
    required DateTime now,
    required List<Movement> transactionsThisMonth,
    required List<Transfer> transfers,
    required List<Debt> debts,
    required List<Account> accounts,
    required List<Investment> investments,
    required List<RecurringBill> recurringBills,
    required List<Category> categories,
    required SavingsChallenge? savingsChallenge,
    required List<SavingsGoal> goals,
  }) async {
    final l10n = currentL10n;
    Future<void> notify(
      String idSuffix,
      String createdBy,
      String title,
      String body,
      DateTime createdAt,
    ) async {
      if (createdBy.isEmpty || createdBy == currentUid) return;
      final id = 'partner_$idSuffix';
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.partnerActivity,
          title: title,
          body: body,
          createdAt: createdAt,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: createdBy));
      }
    }

    for (final tx in transactionsThisMonth) {
      await notify(
        'tx_${tx.id}',
        tx.createdBy,
        l10n.notificationsPartnerMovementTitle,
        tx.description.isEmpty ? l10n.notificationsPartnerMovementBody : tx.description,
        tx.date,
      );
    }
    for (final transfer in transfers) {
      await notify(
        'transfer_${transfer.id}',
        transfer.createdBy,
        l10n.notificationsPartnerTransferTitle,
        l10n.notificationsPartnerTransferBody,
        transfer.date,
      );
    }
    for (final debt in debts) {
      await notify(
        'debt_${debt.id}',
        debt.createdBy,
        l10n.notificationsPartnerDebtTitle,
        debt.name,
        now,
      );
    }
    for (final account in accounts) {
      await notify(
        'account_${account.id}',
        account.createdBy,
        l10n.notificationsPartnerAccountTitle,
        account.name,
        now,
      );
    }
    for (final investment in investments) {
      await notify(
        'investment_${investment.id}',
        investment.createdBy,
        l10n.notificationsPartnerInvestmentTitle,
        investment.name,
        now,
      );
    }
    for (final bill in recurringBills) {
      await notify(
        'bill_${bill.id}',
        bill.createdBy,
        l10n.notificationsPartnerBillTitle,
        bill.name,
        now,
      );
    }
    for (final category in categories) {
      await notify(
        'category_${category.id}',
        category.createdBy,
        l10n.notificationsPartnerCategoryTitle,
        category.name,
        now,
      );
    }
    final challenge = savingsChallenge;
    if (challenge != null) {
      await notify(
        'challenge_${challenge.id}',
        challenge.createdBy,
        l10n.notificationsPartnerChallengeTitle,
        challenge.name,
        now,
      );
    }
    for (final goal in goals) {
      await notify(
        'goal_${goal.id}',
        goal.createdBy,
        l10n.notificationsPartnerGoalTitle,
        goal.name,
        now,
      );
    }
  }
}

/// Days from today until the next occurrence of [dayOfMonth] (0 = today).
int _daysUntilDayOfMonth(int dayOfMonth, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var target = DateTime(now.year, now.month, dayOfMonth);
  if (target.isBefore(today)) {
    target = DateTime(now.year, now.month + 1, dayOfMonth);
  }
  return target.difference(today).inDays;
}
