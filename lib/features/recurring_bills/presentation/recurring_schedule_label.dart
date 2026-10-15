import 'package:intl/intl.dart';

import '../data/recurring_bill_model.dart';

/// "cada lunes", "días 15 y 30", "cada año, 3 de marzo"... for the list and
/// the edit form.
String describeSchedule({required RecurringFrequency frequency, required DateTime start}) {
  final weekday = DateFormat.EEEE().format(start);
  final day = start.day;
  return switch (frequency) {
    RecurringFrequency.weekly => 'cada $weekday',
    RecurringFrequency.biweekly => 'cada 2 semanas, los $weekday',
    RecurringFrequency.semimonthly => 'días $day y ${day + 15}',
    RecurringFrequency.monthly => 'cada mes, día ${day.toString().padLeft(2, '0')}',
    RecurringFrequency.yearly => 'cada año, ${DateFormat.MMMMd().format(start)}',
  };
}

/// The date a bill's schedule is described from: its start, or for bills
/// saved before frequencies existed, its day in the current month.
DateTime scheduleAnchor(RecurringBill bill, {DateTime? now}) {
  if (bill.startDate != null) return bill.startDate!;
  now ??= DateTime.now();
  final last = DateTime(now.year, now.month + 1, 0).day;
  return DateTime(now.year, now.month, bill.dayOfMonth.clamp(1, last));
}
