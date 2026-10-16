import '../../recurring_bills/domain/entities/recurring_bill.dart';
import '../../transactions/domain/entities/movement.dart';

/// How much a category is used: the movements filed under it and the fijos
/// that log into it.
class CategoryUse {
  const CategoryUse({this.movements = 0, this.recurringBills = 0});

  final int movements;
  final int recurringBills;

  static const none = CategoryUse();
}

/// Each category's [CategoryUse] by its ID, from [movements] and [bills].
/// A category nothing points at is absent - read it as [CategoryUse.none].
Map<String, CategoryUse> categoryUses({
  required Iterable<Movement> movements,
  required Iterable<RecurringBill> bills,
}) {
  final movementCounts = <String, int>{};
  for (final movement in movements) {
    if (movement.categoryId.isEmpty) continue;
    movementCounts.update(movement.categoryId, (n) => n + 1, ifAbsent: () => 1);
  }
  final billCounts = <String, int>{};
  for (final bill in bills) {
    if (bill.categoryId.isEmpty) continue;
    billCounts.update(bill.categoryId, (n) => n + 1, ifAbsent: () => 1);
  }
  return {
    for (final id in {...movementCounts.keys, ...billCounts.keys})
      id: CategoryUse(movements: movementCounts[id] ?? 0, recurringBills: billCounts[id] ?? 0),
  };
}
