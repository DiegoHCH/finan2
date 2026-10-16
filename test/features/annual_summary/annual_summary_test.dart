import 'package:finan2/features/annual_summary/domain/annual_summary.dart';
import 'package:finan2/features/categories/domain/category_type.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx(int amount, String category, DateTime date, {bool income = false}) => Movement(
  id: '$amount-${date.month}-$category',
  amount: amount,
  type: income ? CategoryType.ingreso : CategoryType.gasto,
  categoryId: category,
  accountId: 'a',
  description: '',
  date: date,
  createdBy: 'u1',
);

void main() {
  final now = DateTime(2026, 10, 15);

  test('months to come are pending, and the average skips empty months', () {
    final summary = computeAnnualSummary(
      year: 2026,
      now: now,
      transactions: [
        _tx(2000000, 'casa', DateTime(2026, 1, 5)),
        _tx(1000000, 'casa', DateTime(2026, 3, 5)),
        _tx(9000000, 'salario', DateTime(2026, 3, 30), income: true),
      ],
    );
    expect(summary.ganado, 9000000);
    expect(summary.gastado, 3000000);
    expect(summary.pendingMonths, {11, 12});
    expect(summary.average, 1500000);
    expect(summary.hasData(1), isTrue);
    expect(summary.hasData(2), isFalse);
    expect(summary.hasData(11), isFalse);
  });

  test('the highest month says which category ran above its usual', () {
    final summary = computeAnnualSummary(
      year: 2026,
      now: now,
      transactions: [
        for (final month in [4, 5, 6, 7]) ...[
          _tx(1300000, 'casa', DateTime(2026, month, 2)),
          _tx(800000, 'mercado', DateTime(2026, month, 9)),
        ],
        _tx(1200000, 'casa', DateTime(2026, 6, 20)),
        _tx(100000, 'mercado', DateTime(2026, 6, 21)),
      ],
    );
    expect(summary.highestMonth, 6);
    expect(summary.highestReason, (categoryId: 'casa', extra: 1200000));
  });

  test('one month alone has nothing to compare with', () {
    final summary = computeAnnualSummary(
      year: 2026,
      now: now,
      transactions: [_tx(100, 'casa', DateTime(2026, 2, 2))],
    );
    expect(summary.highestMonth, isNull);
    expect(summary.highestReason, isNull);
  });

  test('a past year has no pending months', () {
    final summary = computeAnnualSummary(year: 2025, now: now, transactions: const []);
    expect(summary.pendingMonths, isEmpty);
    expect(summary.average, isNull);
  });
}
