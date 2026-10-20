import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../accounts/data/account_repository.dart';
import '../../budget/data/budget_repository.dart';
import '../../categories/data/category_model.dart';
import '../../categories/data/category_repository.dart';
import '../../debts/domain/entities/debt.dart';
import '../../debts/data/debt_mapper.dart';
import '../../debts/data/debt_repository.dart';
import '../../savings_goals/data/savings_goal_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../domain/export_period.dart';

export '../domain/export_period.dart';

extension ExportPeriodLabel on ExportPeriod {
  String get label => switch (this) {
    ExportPeriod.thisMonth => currentL10n.exportPeriodThisMonth,
    ExportPeriod.quarter => currentL10n.exportPeriodQuarter,
    ExportPeriod.year => currentL10n.exportPeriodYear,
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

  Future<Report> build({
    required String householdId,
    required String householdName,
    required ExportPeriod period,
    required bool includeTransactions,
    required bool includeBudget,
    required bool includeDebtsAndSavings,
    required String Function(num) formatMoney,
    Map<String, String> memberNames = const {},

    /// For CSV: amounts as bare integers and ISO dates, so the file can be
    /// summed in a spreadsheet and read back in.
    bool plainValues = false,
  }) async {
    // Titles and headers in the app's language: the CSV file names come from
    // the section titles too.
    final l10n = currentL10n;
    final money = plainValues ? (num v) => v.round().toString() : formatMoney;
    final dateFormat = plainValues ? DateFormat('yyyy-MM-dd') : DateFormat.yMd();
    final now = DateTime.now();
    final months = exportMonths(period, now);
    final sections = <ReportSection>[];

    final categories = await categoryRepository.watchCategories(householdId).first;
    final categoryById = {for (final c in categories) c.id: c};
    final accounts = await accountRepository.watchAccounts(householdId).first;
    final accountById = {for (final a in accounts) a.id: a};
    final cardById = {
      for (final d in await debtRepository.watchDebts(householdId).first)
        if (d.type.isCard) d.id: d,
    };

    if (includeTransactions) {
      final transactions = [
        for (final (:year, :month) in months)
          ...await transactionRepository
              .watchTransactions(householdId, year: year, month: month)
              .first,
      ]..sort((a, b) => a.date.compareTo(b.date));

      sections.add(
        ReportSection(
          title: l10n.exportTransactions,
          headers: [
            l10n.commonDate,
            l10n.exportColumnType,
            l10n.commonCategory,
            l10n.commonAccount,
            l10n.commonDescription,
            l10n.commonAmount,
            if (plainValues) ...[l10n.exportColumnPaidBy, l10n.exportColumnTags],
          ],
          rows: [
            for (final tx in transactions)
              [
                dateFormat.format(tx.date),
                tx.type.label,
                categoryById[tx.categoryId]?.name ?? '',
                tx.isCardPurchase
                    ? (cardById[tx.cardDebtId]?.name ?? '')
                    : (accountById[tx.accountId]?.name ?? ''),
                tx.description,
                money(tx.amount),
                if (plainValues) ...[memberNames[tx.payer] ?? '', tx.tags.join(' ')],
              ],
          ],
        ),
      );
    }

    if (includeBudget) {
      final plannedTotals = <String, int>{};
      final realTotals = <String, int>{};
      for (final (:year, :month) in months) {
        final budget = await budgetRepository
            .watchBudget(householdId, year: year, month: month)
            .first;
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
          title: l10n.exportBudget,
          headers: [l10n.commonCategory, l10n.exportColumnPlanned, l10n.exportColumnActual],
          rows: [
            for (final id in categoryIds)
              [
                categoryById[id]?.name ?? '',
                money(plannedTotals[id] ?? 0),
                money(realTotals[id] ?? 0),
              ],
          ],
        ),
      );
    }

    if (includeDebtsAndSavings) {
      final debts = await debtRepository.watchDebts(householdId).first;
      sections.add(
        ReportSection(
          title: l10n.exportDebts,
          headers: [
            l10n.commonName,
            l10n.exportColumnType,
            l10n.exportColumnBalance,
            plainValues ? l10n.exportColumnRatePercent : l10n.exportColumnRate,
          ],
          rows: [
            for (final debt in debts)
              [
                debt.name,
                debt.type.label,
                money(debt.balance),
                plainValues ? '${debt.rate}' : '${debt.rate}%',
              ],
          ],
        ),
      );

      final goals = await savingsGoalRepository.watchGoals(householdId).first;
      sections.add(
        ReportSection(
          title: l10n.exportSavingsGoals,
          headers: [
            l10n.commonName,
            l10n.exportColumnSaved,
            l10n.exportColumnTarget,
            plainValues ? l10n.exportColumnCompletedPercent : l10n.exportColumnCompleted,
          ],
          rows: [
            for (final goal in goals)
              [
                goal.name,
                money(goal.currentAmountAsOf(now)),
                money(goal.targetAmount),
                '${(goal.progressFractionAsOf(now) * 100).round()}${plainValues ? '' : '%'}',
              ],
          ],
        ),
      );
    }

    return Report(
      title: 'Finan2 · $householdName',
      subtitle: '${period.label} · ${DateFormat.yMd().format(now)}',
      sections: sections,
    );
  }
}
