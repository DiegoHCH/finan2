import 'entities/recurring_bill.dart';

/// A fijo's calendar as the parts it's said with - «Cada lunes», «Días 15
/// y 30», «Cada mes, día 5» - so the words can be put together in each
/// language without parsing a date there.
class RecurringSchedule {
  const RecurringSchedule({
    required this.frequency,
    required this.weekday,
    required this.day,
    required this.secondDay,
    required this.month,
    this.until,
  });

  final RecurringFrequency frequency;

  /// [DateTime.monday] to [DateTime.sunday]: the day a weekly or
  /// every-2-weeks one falls on.
  final int weekday;

  /// The day of the month of a monthly, quincenal or yearly one.
  final int day;

  /// A quincenal's second day, 15 after [day].
  final int secondDay;

  /// A yearly one's month, 1 to 12.
  final int month;

  /// Its last possible day, when it has one.
  final DateTime? until;
}

/// How a fijo that starts on [start] repeats.
RecurringSchedule scheduleOf(RecurringFrequency frequency, DateTime start, {DateTime? until}) =>
    RecurringSchedule(
      frequency: frequency,
      weekday: start.weekday,
      day: start.day,
      secondDay: start.day + 15,
      month: start.month,
      until: until,
    );

/// The date a bill's schedule is described from: its start, or for bills
/// saved before frequencies existed, its day in [today]'s month.
DateTime scheduleAnchor(RecurringBill bill, DateTime today) {
  if (bill.startDate case final start?) return start;
  final last = DateTime(today.year, today.month + 1, 0).day;
  return DateTime(today.year, today.month, bill.dayOfMonth.clamp(1, last));
}

/// What [amount] every [frequency] costs in an average month: a weekly
/// $60.000 is about $260.000.
int monthlyCost(int amount, RecurringFrequency frequency) => (amount * frequency.perMonth).round();

/// Whether [frequency]'s monthly cost is an average rather than the amount
/// itself.
bool isAveraged(RecurringFrequency frequency) =>
    frequency != RecurringFrequency.monthly && frequency != RecurringFrequency.semimonthly;

enum RecurringBillStatus { active, paused, ended }

RecurringBillStatus billStatus(RecurringBill bill, DateTime today) {
  if (bill.paused) return RecurringBillStatus.paused;
  if (bill.hasEndedBy(today)) return RecurringBillStatus.ended;
  return RecurringBillStatus.active;
}

/// What the household has committed to pay each month: the active fijos
/// that aren't income, each by its monthly average.
class MonthlyCommitment {
  const MonthlyCommitment({required this.amount, required this.count, required this.averaged});

  final int amount;

  /// How many fijos [amount] adds up.
  final int count;

  /// Whether any of them counts by its average (weekly, yearly...).
  final bool averaged;
}

MonthlyCommitment monthlyCommitment(Iterable<RecurringBill> bills, DateTime today) {
  final counted = [
    for (final bill in bills)
      if (!bill.isIncome && bill.isActiveOn(today)) bill,
  ];
  return MonthlyCommitment(
    amount: counted.fold(0, (sum, bill) => sum + bill.monthlyAmount),
    count: counted.length,
    averaged: counted.any((bill) => isAveraged(bill.frequency)),
  );
}

/// Fijos as the list shows them: the active ones first, then the paused,
/// then the ones that ended, each group in its original order.
List<RecurringBill> billsInListOrder(Iterable<RecurringBill> bills, DateTime today) => [
  for (final status in RecurringBillStatus.values)
    for (final bill in bills)
      if (billStatus(bill, today) == status) bill,
];
