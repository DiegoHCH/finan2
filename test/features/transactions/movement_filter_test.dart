import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/movement_filter.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx({
  String id = 'tx',
  int amount = 50000,
  CategoryType type = CategoryType.gasto,
  String categoryId = 'mercado',
  String description = '',
  String createdBy = 'ana',
  String paidBy = '',
}) => Movement(
  id: id,
  amount: amount,
  type: type,
  categoryId: categoryId,
  accountId: 'cuenta',
  description: description,
  date: DateTime(2026, 7, 10),
  createdBy: createdBy,
  paidBy: paidBy,
);

void main() {
  test('an empty filter keeps everything', () {
    const filter = MovementFilter();
    expect(filter.isEmpty, isTrue);
    expect(filter.matches(_tx()), isTrue);
  });

  test('the query ignores case and accents', () {
    const filter = MovementFilter(query: 'cafe');
    expect(filter.matches(_tx(description: 'Café De La Mañana')), isTrue);
    expect(filter.matches(_tx(description: 'Almuerzo')), isFalse);
    expect(const MovementFilter(query: 'MAÑANA').matches(_tx(description: 'manana')), isTrue);
  });

  test('the query matches the category name', () {
    const filter = MovementFilter(query: 'merc');
    expect(filter.matches(_tx(), categoryName: 'Mercado'), isTrue);
    expect(filter.matches(_tx(), categoryName: 'Ocio'), isFalse);
  });

  test('a numeric query matches the amount with or without separators', () {
    expect(const MovementFilter(query: '50000').matches(_tx()), isTrue);
    expect(const MovementFilter(query: '50.000').matches(_tx()), isTrue);
    expect(const MovementFilter(query: '\$ 50.000').matches(_tx()), isTrue);
    expect(const MovementFilter(query: '70000').matches(_tx()), isFalse);
  });

  test('types, category and payer narrow together', () {
    final filter = MovementFilter(
      types: const {CategoryType.gasto, CategoryType.factura},
      categoryId: 'mercado',
      payer: 'ben',
    );
    expect(filter.activeFilterCount, 3);
    expect(filter.matches(_tx(paidBy: 'ben')), isTrue);
    expect(filter.matches(_tx(createdBy: 'ben')), isTrue, reason: 'payer falls back to createdBy');
    expect(filter.matches(_tx()), isFalse);
    expect(filter.matches(_tx(paidBy: 'ben', categoryId: 'ocio')), isFalse);
    expect(filter.matches(_tx(paidBy: 'ben', type: CategoryType.ingreso)), isFalse);
  });

  test('the source matches an account or a credit card', () {
    const filter = MovementFilter(sourceId: 'visa');
    expect(filter.matches(_tx()), isFalse);
    expect(
      filter.matches(
        Movement(
          id: 'c',
          amount: 1,
          type: CategoryType.gasto,
          categoryId: 'mercado',
          accountId: '',
          cardDebtId: 'visa',
          description: '',
          date: DateTime(2026),
          createdBy: 'ana',
        ),
      ),
      isTrue,
    );
    expect(const MovementFilter(sourceId: 'cuenta').matches(_tx()), isTrue);
  });

  test('copyWith can clear a nullable field', () {
    const filter = MovementFilter(categoryId: 'mercado', payer: 'ana');
    final cleared = filter.copyWith(categoryId: () => null);
    expect(cleared.categoryId, isNull);
    expect(cleared.payer, 'ana');
    expect(filter.copyWith(query: 'x').categoryId, 'mercado');
  });

  test('withoutFilters keeps only the query', () {
    final filter = const MovementFilter(
      query: 'luz',
      types: {CategoryType.factura},
      payer: 'ana',
    ).withoutFilters();
    expect(filter.query, 'luz');
    expect(filter.activeFilterCount, 0);
  });

  test('apply looks up each movement category name', () {
    final result = const MovementFilter(query: 'ocio').apply(
      [_tx(id: 'a'), _tx(id: 'b', categoryId: 'ocio')],
      {'mercado': 'Mercado', 'ocio': 'Ocio'},
    );
    expect(result.map((t) => t.id), ['b']);
  });
}
