import 'package:finan2/features/annual_summary/presentation/viewmodels/annual_summary_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx(int amount, CategoryType type, DateTime date) => Movement(
  id: '$amount-${date.month}',
  amount: amount,
  type: type,
  categoryId: 'c',
  accountId: 'a',
  description: '',
  date: date,
  createdBy: 'u1',
);

void main() {
  test('adds income and spend per year and spend per month', () async {
    final container = ProviderContainer(
      overrides: [
        transactionsForYearProvider(2026).overrideWith(
          (ref) => Stream.value([
            _tx(5000000, CategoryType.ingreso, DateTime(2026, 1, 30)),
            _tx(800000, CategoryType.gasto, DateTime(2026, 1, 5)),
            _tx(200000, CategoryType.gasto, DateTime(2026, 3, 9)),
            _tx(150000, CategoryType.gasto, DateTime(2026, 3, 20)),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(annualSummaryProvider(2026), (_, _) {});
    await container.read(transactionsForYearProvider(2026).future);

    final summary = sub.read();
    expect(summary.ganado, 5000000);
    expect(summary.gastado, 1150000);
    expect(summary.ahorrado, 3850000);
    expect(summary.gastoPorMes.take(3), [800000, 0, 350000]);
  });
}
