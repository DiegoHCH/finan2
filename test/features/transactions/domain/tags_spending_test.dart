import 'package:finan2/features/categories/domain/category_type.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/domain/tags.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx(int amount, List<String> tags, {CategoryType type = CategoryType.gasto}) => Movement(
  id: '$amount',
  amount: amount,
  type: type,
  categoryId: 'c',
  accountId: 'a',
  description: '',
  date: DateTime(2026, 10, 1),
  createdBy: 'u',
  tags: tags,
);

void main() {
  test('spending adds up per tag, biggest first, without income', () {
    expect(
      spendingByTag([
        _tx(15000, ['gasolina']),
        _tx(20000, ['gasolina', 'viaje']),
        _tx(600000, ['remesa']),
        _tx(3000000, ['gasolina'], type: CategoryType.ingreso),
        _tx(5000, const []),
      ]),
      [('remesa', 600000), ('gasolina', 35000), ('viaje', 20000)],
    );
  });
}
