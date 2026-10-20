/// Where a category stands against its plan for the month.
enum BudgetLineState {
  /// Some of the plan is still there to spend.
  left,

  /// Spent exactly what was planned.
  complete,

  /// Spent past the plan: the only time the row turns red.
  over,

  /// Spending with nothing planned or carried - not "over" anything.
  unplanned,
}

/// One `.bud` row of Presupuesto: what's left reads on the right, what was
/// spent goes to the small line.
class BudgetLine {
  const BudgetLine({
    required this.categoryId,
    required this.spent,
    required this.planned,
    this.carry = 0,
  });

  final String categoryId;
  final int spent;

  /// This month's own plan.
  final int planned;

  /// Brought in from earlier months: + left over, - overspent.
  final int carry;

  /// The plan plus whatever was carried in (may be negative).
  int get limit => planned + carry;

  /// What's still there to spend; negative once over.
  int get left => limit - spent;

  BudgetLineState get state {
    if (planned == 0 && carry == 0) return BudgetLineState.unplanned;
    if (left < 0) return BudgetLineState.over;
    if (left == 0) return BudgetLineState.complete;
    return BudgetLineState.left;
  }

  /// How full the bar is; past 1 once over (the bar turns red then). An
  /// unplanned line has no bar to fill.
  double get fraction {
    if (limit > 0) return spent / limit;
    return state == BudgetLineState.over ? 2.0 : 0.0;
  }
}

/// [planned] is the month's own plan per category, [carry] what rollover
/// categories bring in, [spent] what each category spent. Returns a line
/// per [categoryIds], in that order.
List<BudgetLine> computeBudgetLines({
  required List<String> categoryIds,
  required Map<String, int> planned,
  required Map<String, int> carry,
  required Map<String, int> spent,
}) => [
  for (final id in categoryIds)
    BudgetLine(
      categoryId: id,
      spent: spent[id] ?? 0,
      planned: planned[id] ?? 0,
      carry: carry[id] ?? 0,
    ),
];

/// The lines that went over, the biggest overspend first - what the notice
/// on top of Presupuesto talks about.
List<BudgetLine> overspentLines(List<BudgetLine> lines) =>
    lines.where((l) => l.state == BudgetLineState.over).toList()
      ..sort((a, b) => a.left.compareTo(b.left));
