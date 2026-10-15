import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/recurring_bills/data/recurring_bill_model.dart';
import 'package:finan2/features/recurring_bills/presentation/recurring_schedule_label.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

RecurringBill _bill({
  RecurringFrequency frequency = RecurringFrequency.monthly,
  DateTime? start,
  DateTime? end,
  DateTime? resumedOn,
  int? dayOfMonth,
  int amount = 120000,
}) =>
    RecurringBill(
      id: 'b',
      name: 'Bill',
      type: CategoryType.factura,
      categoryId: 'c',
      accountId: 'a',
      amount: amount,
      dayOfMonth: dayOfMonth ?? start?.day ?? 1,
      frequency: frequency,
      startDate: start,
      endDate: end,
      resumedOn: resumedOn,
    );

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('occurrencesBetween', () {
    test('weekly counts from the start date', () {
      // Monday 2026-10-05.
      final bill = _bill(frequency: RecurringFrequency.weekly, start: DateTime(2026, 10, 5));
      expect(bill.occurrencesBetween(DateTime(2026, 10, 1), DateTime(2026, 10, 31)), [
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 12),
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 26),
      ]);
    });

    test('every 2 weeks keeps its cadence across months', () {
      final bill = _bill(frequency: RecurringFrequency.biweekly, start: DateTime(2026, 9, 25));
      expect(bill.occurrencesBetween(DateTime(2026, 10, 1), DateTime(2026, 10, 31)), [
        DateTime(2026, 10, 9),
        DateTime(2026, 10, 23),
      ]);
    });

    test('quincenal falls on the day and 15 days later, clamped in February', () {
      final bill = _bill(frequency: RecurringFrequency.semimonthly, start: DateTime(2026, 1, 15));
      expect(bill.occurrencesBetween(DateTime(2026, 2, 1), DateTime(2026, 3, 31)), [
        DateTime(2026, 2, 15),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 15),
        DateTime(2026, 3, 30),
      ]);
    });

    test('yearly repeats the start month and day', () {
      final bill = _bill(frequency: RecurringFrequency.yearly, start: DateTime(2025, 3, 3));
      expect(bill.occurrencesBetween(DateTime(2026, 1, 1), DateTime(2027, 12, 31)), [
        DateTime(2026, 3, 3),
        DateTime(2027, 3, 3),
      ]);
      expect(bill.occurrencesBetween(DateTime(2026, 4, 1), DateTime(2026, 12, 31)), isEmpty);
    });

    test('nothing before the start date', () {
      final bill = _bill(start: DateTime(2026, 10, 20));
      expect(bill.occurrencesBetween(DateTime(2026, 10, 1), DateTime(2026, 10, 31)), [
        DateTime(2026, 10, 20),
      ]);
      expect(bill.occurrencesBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 30)), isEmpty);
    });

    test('nothing after the end date', () {
      final bill = _bill(
        frequency: RecurringFrequency.weekly,
        start: DateTime(2026, 10, 5),
        end: DateTime(2026, 10, 15),
      );
      expect(bill.occurrencesBetween(DateTime(2026, 10, 1), DateTime(2026, 10, 31)), [
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 12),
      ]);
      expect(bill.hasEndedBy(DateTime(2026, 10, 15, 23)), isFalse);
      expect(bill.hasEndedBy(DateTime(2026, 10, 16)), isTrue);
    });

    test('dates skipped by a pause stay skipped', () {
      final bill = _bill(
        frequency: RecurringFrequency.weekly,
        start: DateTime(2026, 10, 5),
        resumedOn: DateTime(2026, 10, 20),
      );
      expect(bill.occurrencesBetween(DateTime(2026, 10, 1), DateTime(2026, 10, 31)), [
        DateTime(2026, 10, 26),
      ]);
    });

    test('a bill saved before frequencies existed still works monthly', () {
      final bill = _bill(dayOfMonth: 31);
      expect(bill.occurrencesBetween(DateTime(2026, 2, 1), DateTime(2026, 2, 28)), [
        DateTime(2026, 2, 28),
      ]);
    });
  });

  test('monthlyAmount averages weekly and yearly bills', () {
    expect(_bill(frequency: RecurringFrequency.weekly, amount: 12000).monthlyAmount, 52000);
    expect(_bill(frequency: RecurringFrequency.semimonthly, amount: 1000).monthlyAmount, 2000);
    expect(_bill(frequency: RecurringFrequency.yearly, amount: 1200000).monthlyAmount, 100000);
  });

  test('describeSchedule reads naturally', () {
    final monday = DateTime(2026, 10, 5);
    expect(describeSchedule(frequency: RecurringFrequency.weekly, start: monday), 'cada lunes');
    expect(describeSchedule(frequency: RecurringFrequency.semimonthly, start: DateTime(2026, 10, 15)),
        'días 15 y 30');
    expect(describeSchedule(frequency: RecurringFrequency.monthly, start: monday), 'cada mes, día 05');
    expect(describeSchedule(frequency: RecurringFrequency.yearly, start: DateTime(2026, 3, 3)),
        'cada año, 3 de marzo');
  });
}
