/// How far back a report goes, counting the current month.
enum ExportPeriod { thisMonth, quarter, year }

/// The months [period] covers as of [now], oldest first: this month, the
/// last 3 or the last 12.
List<({int year, int month})> exportMonths(ExportPeriod period, DateTime now) {
  final count = switch (period) {
    ExportPeriod.thisMonth => 1,
    ExportPeriod.quarter => 3,
    ExportPeriod.year => 12,
  };
  return [
    for (var i = count - 1; i >= 0; i--)
      (
        year: DateTime(now.year, now.month - i).year,
        month: DateTime(now.year, now.month - i).month,
      ),
  ];
}
