import '../../transactions/data/transaction_model.dart';

/// What each rollover category brings into [month] of a year: the chain of
/// "planned minus spent" from January up to the month before. Positive is
/// money left over, negative is overspending to make up. The chain starts
/// over every January, so one bad month doesn't follow the budget forever.
///
/// [budgets] maps month (1-12) -> categoryId -> planned amount;
/// [transactions] is every movement of the year.
Map<String, int> computeCarryOver({
  required int month,
  required Set<String> rolloverCategoryIds,
  required Map<int, Map<String, int>> budgets,
  required List<Movement> transactions,
}) {
  if (rolloverCategoryIds.isEmpty || month <= 1) return const {};

  final spent = <int, Map<String, int>>{};
  for (final tx in transactions) {
    if (tx.isIncome || !rolloverCategoryIds.contains(tx.categoryId)) continue;
    final byCategory = spent.putIfAbsent(tx.date.month, () => {});
    byCategory[tx.categoryId] = (byCategory[tx.categoryId] ?? 0) + tx.amount;
  }

  final carry = <String, int>{};
  for (var m = 1; m < month; m++) {
    for (final id in rolloverCategoryIds) {
      final planned = budgets[m]?[id] ?? 0;
      final used = spent[m]?[id] ?? 0;
      carry[id] = (carry[id] ?? 0) + planned - used;
    }
  }
  carry.removeWhere((_, amount) => amount == 0);
  return carry;
}
