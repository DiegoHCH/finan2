import 'package:intl/intl.dart';

import '../../accounts/data/account_repository.dart';
import '../../budget/data/budget_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../debts/data/debt_model.dart';
import '../../debts/data/debt_repository.dart';
import '../../savings_goals/data/savings_goal_repository.dart';
import '../../transactions/data/transaction_repository.dart';

enum ExportPeriod { thisMonth, quarter, year }

extension ExportPeriodLabel on ExportPeriod {
  String get label => switch (this) {
        ExportPeriod.thisMonth => 'Este mes',
        ExportPeriod.quarter => 'Trimestre',
        ExportPeriod.year => 'Año',
      };
}

class ReportSection {
  const ReportSection({required this.title, required this.headers, required this.rows});

  final String title;
  final List<String> headers;
  final List<List<String>> rows;
}

class Report {
  const Report({required this.title, required this.subtitle, required this.sections});

  final String title;
  final String subtitle;
  final List<ReportSection> sections;
}

/// Pulls a one-off snapshot (not streams) from the existing repositories
/// for the chosen period/sections and shapes it into plain rows - the CSV
/// and PDF writers just render this, they don't touch Firestore.
class ReportBuilder {
  const ReportBuilder({
    required this.transactionRepository,
    required this.accountRepository,
    required this.categoryRepository,
    required this.budgetRepository,
    required this.debtRepository,
    required this.savingsGoalRepository,
  });

  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final BudgetRepository budgetRepository;
  final DebtRepository debtRepository;
  final SavingsGoalRepository savingsGoalRepository;

  List<(int, int)> _monthsFor(ExportPeriod period, DateTime now) {
    final count = switch (period) {
      ExportPeriod.thisMonth => 1,
      ExportPeriod.quarter => 3,
      ExportPeriod.year => 12,
    };
    return [
      for (var i = count - 1; i >= 0; i--)
        (
          DateTime(now.year, now.month - i).year,
          DateTime(now.year, now.month - i).month,
        ),
    ];
  }

  Future<Report> build({
    required String householdId,
    required String householdName,
    required ExportPeriod period,
    required bool includeTransactions,
    required bool includeBudget,
    required bool includeDebtsAndSavings,
    required String Function(num) formatMoney,
  }) async {
    final now = DateTime.now();
    final months = _monthsFor(period, now);
    final sections = <ReportSection>[];

    final categories = await categoryRepository.watchCategories(householdId).first;
    final categoryById = {for (final c in categories) c.id: c};
    final accounts = await accountRepository.watchAccounts(householdId).first;
    final accountById = {for (final a in accounts) a.id: a};

    if (includeTransactions) {
      final transactions = [
        for (final (year, month) in months)
          ...await transactionRepository
              .watchTransactions(householdId, year: year, month: month)
              .first,
      ]..sort((a, b) => a.date.compareTo(b.date));

      sections.add(
        ReportSection(
          title: 'Movimientos',
          headers: const ['Fecha', 'Tipo', 'Categoría', 'Cuenta', 'Descripción', 'Monto'],
          rows: [
            for (final tx in transactions)
              [
                DateFormat('dd/MM/yyyy').format(tx.date),
                tx.isIncome ? 'Ingreso' : 'Gasto',
                categoryById[tx.categoryId]?.name ?? '',
                accountById[tx.accountId]?.name ?? '',
                tx.description,
                formatMoney(tx.amount),
              ],
          ],
        ),
      );
    }

    if (includeBudget) {
      final plannedTotals = <String, int>{};
      final realTotals = <String, int>{};
      for (final (year, month) in months) {
        final budget =
            await budgetRepository.watchBudget(householdId, year: year, month: month).first;
        final transactions = await transactionRepository
            .watchTransactions(householdId, year: year, month: month)
            .first;
        for (final entry in budget.entries) {
          plannedTotals[entry.key] = (plannedTotals[entry.key] ?? 0) + entry.value;
        }
        for (final tx in transactions) {
          if (tx.isIncome) continue;
          realTotals[tx.categoryId] = (realTotals[tx.categoryId] ?? 0) + tx.amount;
        }
      }
      final categoryIds = {...plannedTotals.keys, ...realTotals.keys}.toList()
        ..sort((a, b) => (categoryById[a]?.name ?? '').compareTo(categoryById[b]?.name ?? ''));

      sections.add(
        ReportSection(
          title: 'Presupuesto',
          headers: const ['Categoría', 'Planeado', 'Real'],
          rows: [
            for (final id in categoryIds)
              [
                categoryById[id]?.name ?? '',
                formatMoney(plannedTotals[id] ?? 0),
                formatMoney(realTotals[id] ?? 0),
              ],
          ],
        ),
      );
    }

    if (includeDebtsAndSavings) {
      final debts = await debtRepository.watchDebts(householdId).first;
      sections.add(
        ReportSection(
          title: 'Deudas',
          headers: const ['Nombre', 'Tipo', 'Saldo', 'Tasa E.A.'],
          rows: [
            for (final debt in debts)
              [
                debt.name,
                debt.type.label,
                formatMoney(debt.balance),
                '${debt.rate}%',
              ],
          ],
        ),
      );

      final goals = await savingsGoalRepository.watchGoals(householdId).first;
      sections.add(
        ReportSection(
          title: 'Metas de ahorro',
          headers: const ['Nombre', 'Ahorrado', 'Meta', '% Completado'],
          rows: [
            for (final goal in goals)
              [
                goal.name,
                formatMoney(goal.currentAmountAsOf(now)),
                formatMoney(goal.targetAmount),
                '${(goal.progressFractionAsOf(now) * 100).round()}%',
              ],
          ],
        ),
      );
    }

    return Report(
      title: 'Finan2 · $householdName',
      subtitle: '${period.label} · ${DateFormat('dd/MM/yyyy').format(now)}',
      sections: sections,
    );
  }
}
