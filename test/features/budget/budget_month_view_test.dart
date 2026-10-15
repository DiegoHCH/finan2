import 'package:finan2/core/utils/year_month.dart';
import 'package:finan2/features/budget/presentation/viewmodels/budget_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const YearMonth _month = (year: 2026, month: 7);

Category _category(String id, CategoryType type) => Category(
      id: id,
      name: id,
      type: type,
      iconSlug: 'tag',
      color: 0,
    );

Movement _spend(String categoryId, int amount) => Movement(
      id: 'tx-$categoryId',
      amount: amount,
      type: CategoryType.gasto,
      categoryId: categoryId,
      accountId: 'acc',
      description: '',
      date: DateTime(2026, 7, 9),
      createdBy: 'u1',
    );

Future<BudgetMonthView> _view({
  required Map<String, int> budget,
  Map<String, int> previous = const {},
  Map<String, int> carry = const {},
  List<Movement> movements = const [],
}) async {
  final container = ProviderContainer(overrides: [
    budgetOfMonthProvider(_month).overrideWith((ref) => Stream.value(budget)),
    budgetOfMonthProvider(_month.plusMonths(-1)).overrideWith((ref) => Stream.value(previous)),
    categoriesProvider.overrideWith((ref) => Stream.value([
          _category('mercado', CategoryType.gasto),
          _category('ocio', CategoryType.gasto),
          _category('casa', CategoryType.gasto),
          _category('sueldo', CategoryType.ingreso),
        ])),
    transactionsOfMonthProvider(_month).overrideWith((ref) => Stream.value(movements)),
    carryOverProvider(_month).overrideWith((ref) => carry),
  ]);
  addTearDown(container.dispose);
  final sub = container.listen(budgetMonthViewProvider(_month), (_, _) {});
  await container.read(budgetOfMonthProvider(_month).future);
  await container.read(budgetOfMonthProvider(_month.plusMonths(-1)).future);
  await container.read(categoriesProvider.future);
  await container.read(transactionsOfMonthProvider(_month).future);
  return sub.read();
}

void main() {
  test('rows are the budgeted or carrying categories, biggest spend first', () async {
    final view = await _view(
      budget: {'mercado': 500, 'ocio': 200},
      carry: {'casa': 50},
      movements: [_spend('mercado', 100), _spend('ocio', 150)],
    );

    expect(view.rows.map((c) => c.id), ['ocio', 'mercado', 'casa']);
    expect(view.unbudgeted, isEmpty);
    expect(view.offerCopy, isFalse);
  });

  test('income categories are never budgetable', () async {
    final view = await _view(budget: {'mercado': 500});

    expect(view.unbudgeted.map((c) => c.id), ['ocio', 'casa']);
  });

  test('an empty month offers to copy a non-empty previous one', () async {
    final view = await _view(budget: const {}, previous: {'mercado': 500, 'ocio': 1});

    expect(view.offerCopy, isTrue);
    expect(view.previousMonthCategories, 2);
  });
}
