import 'package:finan2/features/categories/domain/category_type.dart';
import 'package:finan2/features/categories/domain/category_use.dart';
import 'package:finan2/features/recurring_bills/domain/entities/recurring_bill.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _movement(String categoryId) => Movement(
  id: '',
  amount: 1000,
  type: CategoryType.gasto,
  categoryId: categoryId,
  accountId: 'a',
  description: '',
  date: DateTime(2026, 10, 1),
  createdBy: 'u1',
);

RecurringBill _bill(String categoryId) => RecurringBill(
  id: '',
  name: 'Arriendo',
  type: CategoryType.factura,
  categoryId: categoryId,
  accountId: 'a',
  amount: 1000,
  dayOfMonth: 5,
);

void main() {
  test('categoryUses counts movements and fijos per category', () {
    final uses = categoryUses(
      movements: [_movement('mercado'), _movement('mercado'), _movement('casa'), _movement('')],
      bills: [_bill('casa'), _bill('servicios')],
    );
    expect(uses['mercado']!.movements, 2);
    expect(uses['mercado']!.recurringBills, 0);
    expect(uses['casa']!.movements, 1);
    expect(uses['casa']!.recurringBills, 1);
    expect(uses['servicios']!.movements, 0);
    expect(uses['servicios']!.recurringBills, 1);
    expect(uses.containsKey(''), isFalse);
    expect(uses['ocio'] ?? CategoryUse.none, same(CategoryUse.none));
  });
}
