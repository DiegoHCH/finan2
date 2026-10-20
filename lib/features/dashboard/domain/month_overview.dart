import '../../transactions/domain/entities/movement.dart';

/// One category's slice of the month's spending, for Inicio's stacked bar.
class SpendSlice {
  const SpendSlice({required this.categoryId, required this.amount});

  /// null for the slice that groups every category past the biggest ones.
  final String? categoryId;
  final int amount;
}

/// What one member paid this month.
class PayerTotal {
  const PayerTotal({required this.amount, required this.count});

  final int amount;
  final int count;
}

/// Everything Inicio answers about the month, worked out without a widget:
/// how much of the plan is left, how much that is per remaining day, where
/// the money went and who paid it.
class MonthOverview {
  const MonthOverview({
    required this.planned,
    required this.spent,
    required this.income,
    required this.daysLeft,
    required this.slices,
    required this.byPayer,
  });

  /// The month's budget, carry-overs included. 0 means there's no plan.
  final int planned;

  /// Everything that went out this month (gastos, facturas, ahorro).
  final int spent;
  final int income;

  /// Whole days after today until the month ends.
  final int daysLeft;

  /// Biggest categories first; the last one may group the rest.
  final List<SpendSlice> slices;

  /// uid -> what that member paid this month.
  final Map<String, PayerTotal> byPayer;

  bool get hasPlan => planned > 0;

  /// Negative once the month went over the plan.
  int get left => planned - spent;

  /// What can go out each remaining day and still keep to the plan; null
  /// when there's nothing left or no day to spread it over.
  int? get perDay => (!hasPlan || left <= 0 || daysLeft <= 0) ? null : left ~/ daysLeft;

  /// What the stacked bar measures against: the plan, or the spending if it
  /// went past it.
  int get scale => planned > spent ? planned : spent;
}

/// [budget] is categoryId -> planned for the month, [carryOver] what rollover
/// categories bring into it, [transactions] the month's movements and
/// [today] the day it's being looked at.
MonthOverview computeMonthOverview({
  required Map<String, int> budget,
  required Map<String, int> carryOver,
  required List<Movement> transactions,
  required DateTime today,
  int maxSlices = 4,
}) {
  var income = 0;
  var spent = 0;
  final byCategory = <String, int>{};
  final byPayer = <String, PayerTotal>{};
  for (final tx in transactions) {
    if (tx.isIncome) {
      income += tx.amount;
      continue;
    }
    spent += tx.amount;
    byCategory[tx.categoryId] = (byCategory[tx.categoryId] ?? 0) + tx.amount;
    final previous = byPayer[tx.payer];
    byPayer[tx.payer] = PayerTotal(
      amount: (previous?.amount ?? 0) + tx.amount,
      count: (previous?.count ?? 0) + 1,
    );
  }

  final ranked = byCategory.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final slices = [
    for (final entry in ranked.take(maxSlices))
      SpendSlice(categoryId: entry.key, amount: entry.value),
  ];
  final rest = ranked.skip(maxSlices).fold(0, (sum, e) => sum + e.value);
  if (rest > 0) slices.add(SpendSlice(categoryId: null, amount: rest));

  final planned = [...budget.values, ...carryOver.values].fold(0, (sum, amount) => sum + amount);
  final lastDay = DateTime(today.year, today.month + 1, 0).day;

  return MonthOverview(
    planned: planned < 0 ? 0 : planned,
    spent: spent,
    income: income,
    daysLeft: lastDay - today.day,
    slices: slices,
    byPayer: byPayer,
  );
}
