import '../../transactions/domain/entities/movement.dart';

/// A year's totals, computed client-side from every movement in the year -
/// no separate Firestore aggregate needed.
class AnnualSummary {
  const AnnualSummary({
    required this.ganado,
    required this.gastado,
    required this.gastoPorMes,
    this.pendingMonths = const {},
    this.average,
    this.highestMonth,
    this.highestReason,
  });

  final int ganado;
  final int gastado;
  int get ahorrado => ganado - gastado;

  /// Non-income spend per month, index 0 = enero.
  final List<int> gastoPorMes;

  /// Months (1-12) still to come - shown as a gap, not as a zero.
  final Set<int> pendingMonths;

  /// Average spend over the months that have any; null with none.
  final int? average;

  /// The month (1-12) that spent the most, once there are two months to
  /// compare.
  final int? highestMonth;

  /// Why [highestMonth] was high: the category that spent the most above
  /// its own usual that month, and by how much.
  final ({String categoryId, int extra})? highestReason;

  /// Whether month (1-12) has spending to draw.
  bool hasData(int month) => !pendingMonths.contains(month) && gastoPorMes[month - 1] > 0;
}

/// [transactions] is every movement of [year]; [now] decides which months
/// haven't happened yet.
AnnualSummary computeAnnualSummary({
  required int year,
  required List<Movement> transactions,
  required DateTime now,
}) {
  var ganado = 0;
  var gastado = 0;
  final perMonth = List<int>.filled(12, 0);
  final byCategory = <int, Map<String, int>>{};
  for (final tx in transactions) {
    if (tx.isIncome) {
      ganado += tx.amount;
      continue;
    }
    gastado += tx.amount;
    final month = tx.date.month;
    perMonth[month - 1] += tx.amount;
    final categories = byCategory.putIfAbsent(month, () => {});
    categories[tx.categoryId] = (categories[tx.categoryId] ?? 0) + tx.amount;
  }

  final pending = {
    for (var m = 1; m <= 12; m++)
      if (year > now.year || (year == now.year && m > now.month)) m,
  };
  final withData = [
    for (var m = 1; m <= 12; m++)
      if (!pending.contains(m) && perMonth[m - 1] > 0) m,
  ];
  final average = withData.isEmpty
      ? null
      : (withData.fold(0, (sum, m) => sum + perMonth[m - 1]) / withData.length).round();

  int? highest;
  ({String categoryId, int extra})? reason;
  if (withData.length >= 2) {
    highest = withData.reduce((a, b) => perMonth[b - 1] > perMonth[a - 1] ? b : a);
    final others = withData.where((m) => m != highest).toList();
    for (final MapEntry(key: id, value: spent) in byCategory[highest]!.entries) {
      final usual = others.fold(0, (sum, m) => sum + (byCategory[m]?[id] ?? 0)) / others.length;
      final extra = (spent - usual).round();
      if (extra > 0 && (reason == null || extra > reason.extra)) {
        reason = (categoryId: id, extra: extra);
      }
    }
  }

  return AnnualSummary(
    ganado: ganado,
    gastado: gastado,
    gastoPorMes: perMonth,
    pendingMonths: pending,
    average: average,
    highestMonth: highest,
    highestReason: reason,
  );
}
