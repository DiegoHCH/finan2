import 'package:finan2/features/budget/domain/budget_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('what is left reads against the plan plus what was carried', () {
    const line = BudgetLine(categoryId: 'm', spent: 920000, planned: 1000000, carry: 60000);
    expect(line.limit, 1060000);
    expect(line.left, 140000);
    expect(line.state, BudgetLineState.left);
    expect(line.fraction, closeTo(0.868, 0.001));
  });

  test('spending exactly the plan is complete, past it is over', () {
    expect(
      const BudgetLine(categoryId: 'c', spent: 1300000, planned: 1300000).state,
      BudgetLineState.complete,
    );
    const over = BudgetLine(categoryId: 't', spent: 540000, planned: 500000);
    expect(over.state, BudgetLineState.over);
    expect(over.left, -40000);
    expect(over.fraction, greaterThan(1));
  });

  test('spending with no plan is not over anything', () {
    const line = BudgetLine(categoryId: 'o', spent: 50000, planned: 0);
    expect(line.state, BudgetLineState.unplanned);
    expect(line.fraction, 0);
  });

  test('a limit eaten by earlier overspending is over', () {
    const line = BudgetLine(categoryId: 'o', spent: 10000, planned: 100000, carry: -100000);
    expect(line.state, BudgetLineState.over);
    expect(line.fraction, greaterThan(1));
  });

  test('lines keep the given order and the overspent come biggest first', () {
    final lines = computeBudgetLines(
      categoryIds: ['a', 'b', 'c'],
      planned: {'a': 100, 'b': 100, 'c': 100},
      carry: {'c': -50},
      spent: {'a': 120, 'b': 50, 'c': 200},
    );
    expect(lines.map((l) => l.categoryId), ['a', 'b', 'c']);
    expect(overspentLines(lines).map((l) => l.categoryId), ['c', 'a']);
  });
}
