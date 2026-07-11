import '../../accounts/data/account_model.dart';
import '../../categories/data/category_model.dart';
import '../../debts/data/debt_model.dart';
import '../../investments/data/investment_model.dart';
import '../../notification_prefs/data/notification_prefs.dart';
import '../../recurring_bills/data/recurring_bill_model.dart';
import '../../savings_challenge/data/savings_challenge_model.dart';
import '../../savings_goals/data/savings_goal_model.dart';
import '../../transactions/data/transaction_model.dart';
import '../../transfers/data/transfer_model.dart';
import 'notification_model.dart';
import 'notification_repository.dart';

/// Detects the household's alert-worthy conditions and writes any missing
/// notification (deterministic IDs keep re-scans idempotent). Runs entirely
/// on the client - there's no backend to trigger this on a schedule, so it
/// re-checks whenever the relevant data changes while the app is open.
class NotificationScanner {
  const NotificationScanner(this._repository);

  final NotificationRepository _repository;

  /// Returns every notification actually created this scan (as opposed to
  /// ones that already existed) - callers use this to trigger a real push
  /// only for genuinely new alerts.
  Future<List<HouseholdNotification>> scan({
    required String householdId,
    required String currentUid,
    required List<Debt> debts,
    required List<SavingsGoal> goals,
    required Map<String, int> budget,
    required List<Movement> transactionsThisMonth,
    required List<Category> categories,
    required NotificationPrefs prefs,
    required String Function(num) formatMoney,
    List<Account> accounts = const [],
    List<Investment> investments = const [],
    List<RecurringBill> recurringBills = const [],
    List<Transfer> transfers = const [],
    SavingsChallenge? savingsChallenge,
    DateTime? now,
  }) async {
    now ??= DateTime.now();
    final created = <HouseholdNotification>[];

    if (prefs.debtPayments) {
      await _scanDebts(created, householdId, debts, now, formatMoney);
    }
    if (prefs.goalProgress) {
      await _scanGoalProgress(created, householdId, goals, now);
    }
    if (prefs.budgetExceeded) {
      await _scanBudget(
        created,
        householdId,
        budget,
        transactionsThisMonth,
        categories,
        now,
        formatMoney,
      );
    }
    if (prefs.partnerActivity) {
      await _scanContributions(created, householdId, goals, currentUid, formatMoney);
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
        formatMoney: formatMoney,
      );
    }
    return created;
  }

  Future<void> _scanDebts(
    List<HouseholdNotification> created,
    String householdId,
    List<Debt> debts,
    DateTime now,
    String Function(num) formatMoney,
  ) async {
    for (final debt in debts) {
      if (debt.balance <= 0) continue;
      final daysUntil = _daysUntilDayOfMonth(debt.paymentDay, now);
      if (daysUntil < 0 || daysUntil > 2) continue;
      final id = 'debt_due_${debt.id}_${now.year}_${now.month}';
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.debtDue,
          title: 'Pago de ${debt.name} pronto',
          body: 'La cuota de ${debt.name} '
              '(${formatMoney(debt.monthlyBasePayment)}) '
              '${daysUntil == 0 ? 'vence hoy' : 'vence en $daysUntil días'}.',
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) created.add(notification);
    }
  }

  Future<void> _scanGoalProgress(
    List<HouseholdNotification> created,
    String householdId,
    List<SavingsGoal> goals,
    DateTime now,
  ) async {
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
          title: '¡Casi logras tu meta!',
          body: '${goal.name} va en ${(fraction * 100).round()}%.',
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) created.add(notification);
    }
  }

  Future<void> _scanBudget(
    List<HouseholdNotification> created,
    String householdId,
    Map<String, int> budget,
    List<Movement> transactionsThisMonth,
    List<Category> categories,
    DateTime now,
    String Function(num) formatMoney,
  ) async {
    final spendByCategory = <String, int>{};
    for (final tx in transactionsThisMonth) {
      if (tx.isIncome) continue;
      spendByCategory[tx.categoryId] = (spendByCategory[tx.categoryId] ?? 0) + tx.amount;
    }
    final categoryById = {for (final c in categories) c.id: c};

    for (final entry in budget.entries) {
      final planned = entry.value;
      if (planned <= 0) continue;
      final real = spendByCategory[entry.key] ?? 0;
      if (real <= planned) continue;
      final id = 'budget_exceeded_${entry.key}_${now.year}_${now.month}';
      final categoryName = categoryById[entry.key]?.name ?? 'una categoría';
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.budgetExceeded,
          title: 'Te pasaste del presupuesto',
          body: '$categoryName superó lo planeado por '
              '${formatMoney(real - planned)}.',
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) created.add(notification);
    }
  }

  Future<void> _scanContributions(
    List<HouseholdNotification> created,
    String householdId,
    List<SavingsGoal> goals,
    String currentUid,
    String Function(num) formatMoney,
  ) async {
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
            title: 'Aporte registrado',
            body: 'Tu pareja agregó ${formatMoney(contribution.amount)} '
                'a ${goal.name}.',
            createdAt: contribution.date,
            read: false,
          ),
        );
        if (notification != null) created.add(notification);
      }
    }
  }

  /// One notification per record the OTHER member created, across every
  /// entity that tracks a `createdBy`. Deterministic per-record IDs keep
  /// this idempotent the same way every other scan is.
  Future<void> _scanPartnerCreated({
    required List<HouseholdNotification> created,
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
    required String Function(num) formatMoney,
  }) async {
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
      if (notification != null) created.add(notification);
    }

    for (final tx in transactionsThisMonth) {
      await notify(
        'tx_${tx.id}',
        tx.createdBy,
        'Nuevo movimiento',
        '${tx.description} · ${formatMoney(tx.amount)}',
        tx.date,
      );
    }
    for (final transfer in transfers) {
      await notify(
        'transfer_${transfer.id}',
        transfer.createdBy,
        'Nueva transferencia',
        'Transferencia de ${formatMoney(transfer.amount)}',
        transfer.date,
      );
    }
    for (final debt in debts) {
      await notify('debt_${debt.id}', debt.createdBy, 'Nueva deuda', debt.name, now);
    }
    for (final account in accounts) {
      await notify(
        'account_${account.id}',
        account.createdBy,
        'Nueva cuenta',
        account.name,
        now,
      );
    }
    for (final investment in investments) {
      await notify(
        'investment_${investment.id}',
        investment.createdBy,
        'Nueva inversión',
        investment.name,
        now,
      );
    }
    for (final bill in recurringBills) {
      await notify(
        'bill_${bill.id}',
        bill.createdBy,
        'Nueva factura recurrente',
        bill.name,
        now,
      );
    }
    for (final category in categories) {
      await notify(
        'category_${category.id}',
        category.createdBy,
        'Nueva categoría',
        category.name,
        now,
      );
    }
    final challenge = savingsChallenge;
    if (challenge != null) {
      await notify(
        'challenge_${challenge.id}',
        challenge.createdBy,
        'Nuevo reto de ahorro',
        challenge.name,
        now,
      );
    }
    for (final goal in goals) {
      await notify(
        'goal_${goal.id}',
        goal.createdBy,
        'Nueva meta de ahorro',
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
