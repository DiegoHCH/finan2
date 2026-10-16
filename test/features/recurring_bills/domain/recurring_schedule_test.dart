import 'package:finan2/features/categories/domain/category_type.dart';
import 'package:finan2/features/recurring_bills/domain/entities/recurring_bill.dart';
import 'package:finan2/features/recurring_bills/domain/recurring_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

RecurringBill _bill({
  CategoryType type = CategoryType.factura,
  RecurringFrequency frequency = RecurringFrequency.monthly,
  int amount = 100000,
  DateTime? start,
  DateTime? end,
  bool paused = false,
  int dayOfMonth = 5,
}) => RecurringBill(
  id: 'b',
  name: 'Bill',
  type: type,
  categoryId: 'c',
  accountId: 'a',
  amount: amount,
  dayOfMonth: dayOfMonth,
  frequency: frequency,
  startDate: start,
  endDate: end,
  paused: paused,
);

void main() {
  final today = DateTime(2026, 10, 14);

  test('scheduleOf takes the weekday, the days and the month from the start', () {
    // Monday 6 October 2026.
    final schedule = scheduleOf(
      RecurringFrequency.weekly,
      DateTime(2026, 10, 6),
      until: DateTime(2026, 12, 15),
    );
    expect(schedule.weekday, DateTime.tuesday);
    expect(schedule.day, 6);
    expect(schedule.secondDay, 21);
    expect(schedule.month, 10);
    expect(schedule.until, DateTime(2026, 12, 15));
    expect(scheduleOf(RecurringFrequency.weekly, DateTime(2026, 10, 5)).weekday, DateTime.monday);
  });

  test('scheduleAnchor falls back to the day in this month for old bills', () {
    expect(scheduleAnchor(_bill(start: DateTime(2026, 3, 3)), today), DateTime(2026, 3, 3));
    expect(scheduleAnchor(_bill(dayOfMonth: 31), DateTime(2026, 2, 10)), DateTime(2026, 2, 28));
  });

  test('monthlyCost says what a frequency costs in an average month', () {
    expect(monthlyCost(60000, RecurringFrequency.weekly), 260000);
    expect(monthlyCost(60000, RecurringFrequency.biweekly), 130000);
    expect(monthlyCost(700000, RecurringFrequency.semimonthly), 1400000);
    expect(monthlyCost(94000, RecurringFrequency.monthly), 94000);
    expect(monthlyCost(1200000, RecurringFrequency.yearly), 100000);
    expect(isAveraged(RecurringFrequency.weekly), isTrue);
    expect(isAveraged(RecurringFrequency.yearly), isTrue);
    expect(isAveraged(RecurringFrequency.monthly), isFalse);
    expect(isAveraged(RecurringFrequency.semimonthly), isFalse);
  });

  test('billStatus tells paused from ended', () {
    expect(billStatus(_bill(), today), RecurringBillStatus.active);
    expect(billStatus(_bill(paused: true), today), RecurringBillStatus.paused);
    expect(billStatus(_bill(end: DateTime(2026, 10, 1)), today), RecurringBillStatus.ended);
  });

  test('monthlyCommitment adds the active bills, not income, by their average', () {
    final commitment = monthlyCommitment([
      _bill(amount: 1300000),
      _bill(amount: 60000, frequency: RecurringFrequency.weekly),
      _bill(amount: 1400000, type: CategoryType.ingreso),
      _bill(amount: 180000, paused: true),
      _bill(amount: 50000, end: DateTime(2026, 9, 30)),
    ], today);
    expect(commitment.amount, 1560000);
    expect(commitment.count, 2);
    expect(commitment.averaged, isTrue);

    final monthlyOnly = monthlyCommitment([_bill(amount: 94000)], today);
    expect(monthlyOnly.averaged, isFalse);
    expect(monthlyCommitment(const [], today).count, 0);
  });

  test('billsInListOrder puts the active ones first, then paused, then ended', () {
    RecurringBill named(String name, {bool paused = false, DateTime? end}) => RecurringBill(
      id: name,
      name: name,
      type: CategoryType.factura,
      categoryId: 'c',
      accountId: 'a',
      amount: 1,
      dayOfMonth: 1,
      paused: paused,
      endDate: end,
    );
    final ordered = billsInListOrder([
      named('parqueadero', paused: true),
      named('gym', end: DateTime(2026, 1, 1)),
      named('arriendo'),
      named('internet'),
    ], today);
    expect([for (final b in ordered) b.id], ['arriendo', 'internet', 'parqueadero', 'gym']);
  });
}
