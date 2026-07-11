import '../../transactions/data/transaction_model.dart';

enum BudgetBannerKind { noIncome, overBudgeted, remaining }

/// Pure result of [computeBudgetSummary] - the banner/badge/highlight
/// decisions the Presupuesto screen renders, split out from the widget so
/// this math can be unit-tested without a BuildContext.
class BudgetSummary {
  const BudgetSummary({
    required this.income,
    required this.totalPlanned,
    required this.spendByCategory,
    required this.visibleCategoryIds,
    required this.pctAsignado,
    required this.bannerKind,
    required this.bannerAmount,
  });

  final int income;
  final int totalPlanned;
  final Map<String, int> spendByCategory;
  final Set<String> visibleCategoryIds;

  /// null when there's no income yet this month to measure against.
  final int? pctAsignado;

  final BudgetBannerKind bannerKind;

  /// Meaning depends on [bannerKind]: 0 for noIncome, overspend for
  /// overBudgeted, remaining-to-plan for remaining.
  final int bannerAmount;
}

/// [budget] is categoryId -> planned amount for the month; [transactions]
/// is every Movement for that same month.
BudgetSummary computeBudgetSummary({
  required Map<String, int> budget,
  required List<Movement> transactions,
}) {
  var income = 0;
  final spendByCategory = <String, int>{};
  for (final tx in transactions) {
    if (tx.isIncome) {
      income += tx.amount;
    } else {
      spendByCategory[tx.categoryId] = (spendByCategory[tx.categoryId] ?? 0) + tx.amount;
    }
  }

  final totalPlanned = budget.values.fold(0, (sum, v) => sum + v);

  final visibleIds = <String>{
    for (final entry in budget.entries)
      if (entry.value > 0) entry.key,
    for (final entry in spendByCategory.entries)
      if (entry.value > 0) entry.key,
  };

  final pctAsignado = income > 0 ? ((totalPlanned / income) * 100).round() : null;

  final BudgetBannerKind bannerKind;
  final int bannerAmount;
  if (income <= 0) {
    bannerKind = BudgetBannerKind.noIncome;
    bannerAmount = 0;
  } else if (totalPlanned >= income) {
    bannerKind = BudgetBannerKind.overBudgeted;
    bannerAmount = totalPlanned - income;
  } else {
    bannerKind = BudgetBannerKind.remaining;
    bannerAmount = income - totalPlanned;
  }

  return BudgetSummary(
    income: income,
    totalPlanned: totalPlanned,
    spendByCategory: spendByCategory,
    visibleCategoryIds: visibleIds,
    pctAsignado: pctAsignado,
    bannerKind: bannerKind,
    bannerAmount: bannerAmount,
  );
}
