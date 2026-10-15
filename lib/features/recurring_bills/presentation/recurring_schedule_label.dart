import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../data/recurring_bill_model.dart';

/// "Semanal", "Quincenal"... for the frequency chips.
String frequencyLabel(RecurringFrequency frequency, {AppLocalizations? l10n}) {
  l10n ??= currentL10n;
  return switch (frequency) {
    RecurringFrequency.weekly => l10n.recurringBillsFrequencyWeekly,
    RecurringFrequency.biweekly => l10n.recurringBillsFrequencyBiweekly,
    RecurringFrequency.semimonthly => l10n.recurringBillsFrequencySemimonthly,
    RecurringFrequency.monthly => l10n.recurringBillsFrequencyMonthly,
    RecurringFrequency.yearly => l10n.recurringBillsFrequencyYearly,
  };
}

/// "cada lunes", "días 15 y 30", "cada año, 3 de marzo"... for the list and
/// the edit form.
String describeSchedule({
  required RecurringFrequency frequency,
  required DateTime start,
  AppLocalizations? l10n,
}) {
  l10n ??= currentL10n;
  final weekday = DateFormat.EEEE().format(start);
  final day = start.day;
  return switch (frequency) {
    RecurringFrequency.weekly => l10n.recurringBillsScheduleWeekly(weekday),
    RecurringFrequency.biweekly => l10n.recurringBillsScheduleBiweekly(weekday),
    RecurringFrequency.semimonthly => l10n.recurringBillsScheduleSemimonthly(day, day + 15),
    RecurringFrequency.monthly => l10n.recurringBillsScheduleMonthly(
      day.toString().padLeft(2, '0'),
    ),
    RecurringFrequency.yearly => l10n.recurringBillsScheduleYearly(
      DateFormat.MMMMd().format(start),
    ),
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
