import 'package:finan2/core/utils/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  test('plusMonths rolls over year boundaries', () {
    const january = (year: 2026, month: 1);
    expect(january.plusMonths(-1), (year: 2025, month: 12));
    expect((year: 2025, month: 12).plusMonths(1), january);
    expect(january.plusMonths(14), (year: 2027, month: 3));
  });

  test('labels are capitalized Spanish month names', () {
    const july = (year: 2026, month: 7);
    expect(july.label, 'Julio 2026');
    expect(july.monthLabel, 'Julio');
  });

  test('isCurrent only for this month', () {
    expect(currentYearMonth().isCurrent, isTrue);
    expect(currentYearMonth().plusMonths(-1).isCurrent, isFalse);
  });
}
