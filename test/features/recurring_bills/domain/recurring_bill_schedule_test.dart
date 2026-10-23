import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/recurring_bills/domain/entities/recurring_bill.dart';
import 'package:finan2/features/recurring_bills/domain/recurring_schedule.dart';
import 'package:finan2/features/recurring_bills/presentation/recurring_schedule_label.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

RecurringBill _bill({
  RecurringFrequency frequency = RecurringFrequency.monthly,
  DateTime? start,
  DateTime? end,
  DateTime? resumedOn,
  int? dayOfMonth,
  int amount = 120000,
}) => RecurringBill(
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

    test('quincenal from after the 15th pairs with 15 days earlier, not 15 later', () {
      // Starting the 22nd: the 7th and the 22nd, never «the 37th» clamped to
      // the month's last day. Nothing before the start.
      final bill = _bill(frequency: RecurringFrequency.semimonthly, start: DateTime(2026, 10, 22));
      expect(bill.occurrencesBetween(DateTime(2026, 10, 1), DateTime(2026, 11, 30)), [
        DateTime(2026, 10, 22),
        DateTime(2026, 11, 7),
        DateTime(2026, 11, 22),
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

  test('describeSchedule says the calendar as it would be out loud', () {
    final monday = DateTime(2026, 10, 5);
    final saturday = DateTime(2026, 10, 10);
    String say(RecurringFrequency f, DateTime start, {DateTime? until}) =>
        describeSchedule(scheduleOf(f, start, until: until), today: DateTime(2026, 10, 14));
    expect(say(RecurringFrequency.weekly, monday), 'Cada lunes');
    expect(say(RecurringFrequency.weekly, saturday), 'Cada sábado');
    expect(say(RecurringFrequency.biweekly, saturday), 'Cada 2 semanas, los sábados');
    expect(say(RecurringFrequency.semimonthly, DateTime(2026, 10, 15)), 'Días 15 y 30');
    expect(say(RecurringFrequency.semimonthly, DateTime(2026, 10, 22)), 'Días 7 y 22');
    expect(say(RecurringFrequency.semimonthly, DateTime(2026, 10, 16)), 'Días 1 y 16');
    expect(say(RecurringFrequency.semimonthly, DateTime(2026, 10, 5)), 'Días 5 y 20');
    expect(say(RecurringFrequency.monthly, monday), 'Cada mes, día 5');
    expect(say(RecurringFrequency.yearly, DateTime(2026, 3, 3)), 'Cada año, 3 de marzo');
    expect(
      say(RecurringFrequency.weekly, monday, until: DateTime(2026, 12, 15)),
      'Cada lunes, hasta el 15 dic',
    );
    expect(
      say(RecurringFrequency.weekly, monday, until: DateTime(2027, 1, 15)),
      'Cada lunes, hasta el 15 ene 2027',
    );
  });

  test('describeSchedule, the monthly cost and frequencyLabel follow the language', () {
    final en = lookupAppLocalizations(const Locale('en'));
    String say(RecurringFrequency f, DateTime start) =>
        describeSchedule(scheduleOf(f, start), l10n: en);
    expect(say(RecurringFrequency.weekly, DateTime(2026, 10, 5)), 'Every Monday');
    expect(say(RecurringFrequency.biweekly, DateTime(2026, 10, 10)), 'Every other Saturday');
    expect(say(RecurringFrequency.semimonthly, DateTime(2026, 10, 15)), 'Days 15 and 30');
    expect(say(RecurringFrequency.yearly, DateTime(2026, 3, 3)), 'Every year, March 3');
    expect(frequencyLabel(RecurringFrequency.semimonthly, l10n: en), 'Twice a month');
    expect(frequencyLabel(RecurringFrequency.semimonthly), 'Quincenal');

    String money(num v) => '\$${v.round()}';
    expect(describeMonthlyCost(60000, RecurringFrequency.weekly, money), 'Unos \$260000 al mes');
    expect(describeMonthlyCost(94000, RecurringFrequency.monthly, money), '\$94000 al mes');
    expect(
      describeMonthlyCost(60000, RecurringFrequency.weekly, money, l10n: en),
      'About \$260000 a month',
    );
  });

  test('every 2 weeks says why it comes to more than two payments a month', () {
    String money(num v) => '\$${v.round()}';
    // The tester's case: 800.000 every 2 weeks read like a wrong sum.
    expect(
      describeMonthlyCost(800000, RecurringFrequency.biweekly, money, withReason: true),
      'Unos \$1733333 al mes. 26 pagos al año: algunos meses caen 3.',
    );
    expect(
      describeMonthlyCost(800000, RecurringFrequency.semimonthly, money, withReason: true),
      '\$1600000 al mes',
    );
    expect(frequencyHint(RecurringFrequency.biweekly), contains('Cada 14 días'));
    expect(frequencyHint(RecurringFrequency.semimonthly), contains('2 veces al mes'));
    expect(frequencyHint(RecurringFrequency.monthly), isNull);
  });
}
