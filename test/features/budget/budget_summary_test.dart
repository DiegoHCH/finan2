import 'package:finan2/features/budget/data/budget_summary.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx({
  required int amount,
  required CategoryType type,
  String categoryId = 'cat',
}) {
  return Movement(
    id: 'tx',
    amount: amount,
    type: type,
    categoryId: categoryId,
    accountId: 'acc',
    description: '',
    date: DateTime(2026, 7, 9),
    createdBy: 'u1',
  );
}

void main() {
  test('no income and no budget yields the noIncome banner and null pct', () {
    final summary = computeBudgetSummary(budget: const {}, transactions: const []);
    expect(summary.income, 0);
    expect(summary.totalPlanned, 0);
    expect(summary.pctAsignado, isNull);
    expect(summary.bannerKind, BudgetBannerKind.noIncome);
    expect(summary.bannerAmount, 0);
  });

  test('income with nothing budgeted yields 0% asignado and the full amount remaining', () {
    final summary = computeBudgetSummary(
      budget: const {},
      transactions: [_tx(amount: 3000000, type: CategoryType.ingreso)],
    );
    expect(summary.income, 3000000);
    expect(summary.pctAsignado, 0);
    expect(summary.bannerKind, BudgetBannerKind.remaining);
    expect(summary.bannerAmount, 3000000);
  });

  test('planned under income reports the correct pct and remaining amount', () {
    final summary = computeBudgetSummary(
      budget: const {'arriendo': 1300000, 'mercado': 900000},
      transactions: [_tx(amount: 3000000, type: CategoryType.ingreso)],
    );
    expect(summary.totalPlanned, 2200000);
    expect(summary.pctAsignado, 73); // 2,200,000 / 3,000,000 rounded
    expect(summary.bannerKind, BudgetBannerKind.remaining);
    expect(summary.bannerAmount, 800000);
  });

  test('planned at or above income reports overBudgeted with the overspend amount', () {
    final summary = computeBudgetSummary(
      budget: const {'arriendo': 3500000},
      transactions: [_tx(amount: 3000000, type: CategoryType.ingreso)],
    );
    expect(summary.bannerKind, BudgetBannerKind.overBudgeted);
    expect(summary.bannerAmount, 500000);
  });

  test('spendByCategory only tallies non-income transactions, grouped by category', () {
    final summary = computeBudgetSummary(
      budget: const {},
      transactions: [
        _tx(amount: 3000000, type: CategoryType.ingreso, categoryId: 'salario'),
        _tx(amount: 200000, type: CategoryType.gasto, categoryId: 'mercado'),
        _tx(amount: 150000, type: CategoryType.gasto, categoryId: 'mercado'),
        _tx(amount: 80000, type: CategoryType.factura, categoryId: 'celular'),
      ],
    );
    expect(summary.spendByCategory, {'mercado': 350000, 'celular': 80000});
  });

  test('visibleCategoryIds includes budgeted-but-unspent and spent-but-unbudgeted, '
      'excludes categories with neither', () {
    final summary = computeBudgetSummary(
      budget: const {'ocio': 300000, 'salud': 0},
      transactions: [_tx(amount: 50000, type: CategoryType.gasto, categoryId: 'transporte')],
    );
    expect(summary.visibleCategoryIds, {'ocio', 'transporte'});
  });
}
