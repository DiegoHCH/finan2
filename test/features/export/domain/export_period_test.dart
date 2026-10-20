import 'package:finan2/features/export/domain/export_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exportMonths counts back from the current month, oldest first', () {
    final now = DateTime(2026, 2, 10);
    expect(exportMonths(ExportPeriod.thisMonth, now), [(year: 2026, month: 2)]);
    expect(exportMonths(ExportPeriod.quarter, now), [
      (year: 2025, month: 12),
      (year: 2026, month: 1),
      (year: 2026, month: 2),
    ]);
    final year = exportMonths(ExportPeriod.year, now);
    expect(year, hasLength(12));
    expect(year.first, (year: 2025, month: 3));
    expect(year.last, (year: 2026, month: 2));
  });
}
