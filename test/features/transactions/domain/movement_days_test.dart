import 'package:finan2/features/categories/domain/category_type.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/domain/movement_days.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx(String id, DateTime date, int amount, {bool income = false}) => Movement(
  id: id,
  amount: amount,
  type: income ? CategoryType.ingreso : CategoryType.gasto,
  categoryId: 'c',
  accountId: 'acc',
  description: id,
  date: date,
  createdBy: 'a',
);

void main() {
  test('groups by calendar day, newest day first, with each day net', () {
    final days = groupByDay([
      _tx('lunch', DateTime(2026, 10, 12, 13), 40000),
      _tx('market', DateTime(2026, 10, 14, 9), 318000),
      _tx('salary', DateTime(2026, 10, 12, 8), 3400000, income: true),
      _tx('internet', DateTime(2026, 10, 14, 20), 94000),
    ]);

    expect(days.map((d) => d.date), [DateTime(2026, 10, 14), DateTime(2026, 10, 12)]);
    expect(days.first.movements.map((m) => m.id), ['market', 'internet']);
    expect(days.first.net, -412000);
    expect(days.last.net, 3360000);
  });

  test('net of a list is income minus everything else', () {
    expect(
      netOf([
        _tx('a', DateTime(2026, 10, 1), 100, income: true),
        _tx('b', DateTime(2026, 10, 2), 30),
      ]),
      70,
    );
    expect(groupByDay(const []), isEmpty);
  });
}
