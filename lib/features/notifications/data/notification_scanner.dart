import '../../categories/data/category_model.dart';
import '../../debts/data/debt_model.dart';
import '../../notification_prefs/data/notification_prefs.dart';
import '../../savings_goals/data/savings_goal_model.dart';
import '../../transactions/data/transaction_model.dart';
import 'notification_model.dart';
import 'notification_repository.dart';

/// Detects the household's alert-worthy conditions and writes any missing
/// notification (deterministic IDs keep re-scans idempotent). Runs entirely
/// on the client - there's no backend to trigger this on a schedule, so it
/// re-checks whenever the relevant data changes while the app is open.
class NotificationScanner {
  const NotificationScanner(this._repository);

  final NotificationRepository _repository;

  Future<void> scan({
    required String householdId,
    required String currentUid,
    required List<Debt> debts,
    required List<SavingsGoal> goals,
    required Map<String, int> budget,
    required List<Movement> transactionsThisMonth,
    required List<Category> categories,
    required NotificationPrefs prefs,
    required String Function(num) formatMoney,
  }) async {
    final now = DateTime.now();

    if (prefs.debtPayments) {
      await _scanDebts(householdId, debts, now, formatMoney);
    }
    if (prefs.goalProgress) {
      await _scanGoalProgress(householdId, goals, now);
    }
    if (prefs.budgetExceeded) {
      await _scanBudget(
        householdId,
        budget,
        transactionsThisMonth,
        categories,
        now,
        formatMoney,
      );
    }
    if (prefs.partnerActivity) {
      await _scanContributions(householdId, goals, currentUid, formatMoney);
    }
  }

  Future<void> _scanDebts(
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
      await _repository.createIfAbsent(
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
    }
  }

  Future<void> _scanGoalProgress(
    String householdId,
    List<SavingsGoal> goals,
    DateTime now,
  ) async {
    for (final goal in goals) {
      final fraction = goal.progressFractionAsOf(now);
      if (fraction < 0.9 || fraction >= 1.0) continue;
      final id = 'goal_near_${goal.id}';
      await _repository.createIfAbsent(
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
    }
  }

  Future<void> _scanBudget(
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
      await _repository.createIfAbsent(
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
    }
  }

  Future<void> _scanContributions(
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
        await _repository.createIfAbsent(
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
      }
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
