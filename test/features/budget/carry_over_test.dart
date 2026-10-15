import 'package:finan2/features/budget/data/carry_over.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _spend(String categoryId, int month, int amount, {bool income = false}) => Movement(
      id: '$categoryId-$month-$amount',
      amount: amount,
      type: income ? CategoryType.ingreso : CategoryType.gasto,
      categoryId: categoryId,
      accountId: 'a',
      description: '',
      date: DateTime(2026, month, 10),
      createdBy: 'u1',
    );

void main() {
  test('leftovers and overspending chain from January', () {
    final carry = computeCarryOver(
      month: 4,
      rolloverCategoryIds: {'ropa'},
      budgets: {
        1: {'ropa': 100},
        2: {'ropa': 100},
        3: {'ropa': 100},
      },
      transactions: [
        _spend('ropa', 1, 0),
        _spend('ropa', 2, 250), // 100 left from January, 150 over now
        _spend('ropa', 3, 20),
      ],
    );
    // 100 + 100 - 250 + 100 - 20
    expect(carry, {'ropa': 30});
  });

  test('a negative balance carries as negative', () {
    final carry = computeCarryOver(
      month: 2,
      rolloverCategoryIds: {'ocio'},
      budgets: {1: {'ocio': 100}},
      transactions: [_spend('ocio', 1, 160)],
    );
    expect(carry, {'ocio': -60});
  });

  test('only rollover categories and only spending count', () {
    final carry = computeCarryOver(
      month: 3,
      rolloverCategoryIds: {'ropa'},
      budgets: {
        1: {'ropa': 100, 'mercado': 500},
      },
      transactions: [
        _spend('mercado', 1, 100),
        _spend('ropa', 1, 40, income: true),
      ],
    );
    expect(carry, {'ropa': 100});
  });

  test('January starts clean and an even balance carries nothing', () {
    expect(
      computeCarryOver(
        month: 1,
        rolloverCategoryIds: {'ropa'},
        budgets: const {},
        transactions: const [],
      ),
      isEmpty,
    );
    expect(
      computeCarryOver(
        month: 2,
        rolloverCategoryIds: {'ropa'},
        budgets: {1: {'ropa': 100}},
        transactions: [_spend('ropa', 1, 100)],
      ),
      isEmpty,
    );
  });
}
