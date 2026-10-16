import 'package:finan2/features/categories/domain/category_type.dart';
import 'package:finan2/features/dashboard/domain/month_overview.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx(String category, int amount, {String payer = 'a', bool income = false}) => Movement(
  id: '$category$amount',
  amount: amount,
  type: income ? CategoryType.ingreso : CategoryType.gasto,
  categoryId: category,
  accountId: 'acc',
  description: '',
  date: DateTime(2026, 10, 3),
  createdBy: 'a',
  paidBy: payer,
);

void main() {
  final today = DateTime(2026, 10, 14);

  test('what is left of the plan, per remaining day', () {
    final overview = computeMonthOverview(
      budget: {'casa': 2000000, 'mercado': 1000000},
      carryOver: {'mercado': 600000},
      transactions: [
        _tx('casa', 1500000),
        _tx('mercado', 400000),
        _tx('sueldo', 5000000, income: true),
      ],
      today: today,
    );

    expect(overview.planned, 3600000);
    expect(overview.spent, 1900000);
    expect(overview.income, 5000000);
    expect(overview.left, 1700000);
    expect(overview.daysLeft, 17);
    expect(overview.perDay, 1700000 ~/ 17);
  });

  test('over the plan there is nothing per day and the bar measures the spending', () {
    final overview = computeMonthOverview(
      budget: {'casa': 1000000},
      carryOver: const {},
      transactions: [_tx('casa', 1200000)],
      today: today,
    );

    expect(overview.left, -200000);
    expect(overview.perDay, isNull);
    expect(overview.scale, 1200000);
  });

  test('without a budget there is no plan', () {
    final overview = computeMonthOverview(
      budget: const {},
      carryOver: const {},
      transactions: [_tx('casa', 100)],
      today: today,
    );

    expect(overview.hasPlan, isFalse);
    expect(overview.perDay, isNull);
  });

  test('biggest categories first, the rest grouped into one slice', () {
    final overview = computeMonthOverview(
      budget: const {},
      carryOver: const {},
      transactions: [
        _tx('a', 10),
        _tx('b', 50),
        _tx('c', 30),
        _tx('d', 40),
        _tx('e', 20),
        _tx('f', 5),
      ],
      today: today,
      maxSlices: 4,
    );

    expect(overview.slices.map((s) => s.categoryId), ['b', 'd', 'c', 'e', null]);
    expect(overview.slices.last.amount, 15);
  });

  test('who paid counts what went out, not what came in', () {
    final overview = computeMonthOverview(
      budget: const {},
      carryOver: const {},
      transactions: [
        _tx('casa', 100, payer: 'a'),
        _tx('mercado', 50, payer: 'b'),
        _tx('mercado', 30, payer: 'b'),
        _tx('sueldo', 999, payer: 'a', income: true),
      ],
      today: today,
    );

    expect(overview.byPayer['a']!.amount, 100);
    expect(overview.byPayer['a']!.count, 1);
    expect(overview.byPayer['b']!.amount, 80);
    expect(overview.byPayer['b']!.count, 2);
  });
}
