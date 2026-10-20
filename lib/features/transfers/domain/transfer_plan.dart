/// What the two balances become when [amount] goes from one account to the
/// other - shown before confirming. [overdrawn] when the source ends below
/// zero.
({int from, int to, bool overdrawn}) balancesAfterTransfer({
  required int fromBalance,
  required int toBalance,
  required int amount,
}) {
  final from = fromBalance - amount;
  return (from: from, to: toBalance + amount, overdrawn: from < 0);
}

/// [items] grouped by calendar month, newest month first and newest item
/// first inside each - the history's «Octubre», «Septiembre» headings.
List<({DateTime month, List<T> items})> groupByMonth<T>(
  Iterable<T> items,
  DateTime Function(T) dateOf,
) {
  final sorted = [...items]..sort((a, b) => dateOf(b).compareTo(dateOf(a)));
  final groups = <({DateTime month, List<T> items})>[];
  for (final item in sorted) {
    final date = dateOf(item);
    final month = DateTime(date.year, date.month);
    if (groups.isEmpty || groups.last.month != month) {
      groups.add((month: month, items: <T>[]));
    }
    groups.last.items.add(item);
  }
  return groups;
}
