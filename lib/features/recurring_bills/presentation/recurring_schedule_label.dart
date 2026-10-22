import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../domain/entities/recurring_bill.dart';
import '../domain/recurring_schedule.dart';

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

const _weekdayKeys = {
  DateTime.monday: 'monday',
  DateTime.tuesday: 'tuesday',
  DateTime.wednesday: 'wednesday',
  DateTime.thursday: 'thursday',
  DateTime.friday: 'friday',
  DateTime.saturday: 'saturday',
  DateTime.sunday: 'sunday',
};

/// The schedule said as it would be out loud - «Cada lunes», «Días 15 y
/// 30», «Cada mes, día 5», «Cada año, 3 de marzo» - and «, hasta el 15 dic»
/// after it when [RecurringSchedule.until] is set and [withUntil].
String describeSchedule(
  RecurringSchedule schedule, {
  AppLocalizations? l10n,
  bool withUntil = true,
  DateTime? today,
}) {
  l10n ??= currentL10n;
  final locale = l10n.localeName;
  final weekday = _weekdayKeys[schedule.weekday]!;
  final text = switch (schedule.frequency) {
    RecurringFrequency.weekly => l10n.recurringBillsScheduleWeekly(weekday),
    RecurringFrequency.biweekly => l10n.recurringBillsScheduleBiweekly(weekday),
    RecurringFrequency.semimonthly => switch (semimonthlyDays(schedule.day)) {
      (final first, final second) => l10n.recurringBillsScheduleSemimonthly(first, second),
    },
    RecurringFrequency.monthly => l10n.recurringBillsScheduleMonthly(schedule.day),
    RecurringFrequency.yearly => l10n.recurringBillsScheduleYearly(
      DateFormat.MMMMd(locale).format(DateTime(2000, schedule.month, schedule.day)),
    ),
  };
  final until = schedule.until;
  if (!withUntil || until == null) return text;
  final year = (today ?? DateTime.now()).year;
  final date = until.year == year
      ? DateFormat.MMMd(locale).format(until)
      : DateFormat.yMMMd(locale).format(until);
  return l10n.recurringBillsScheduleUntil(text, date.replaceAll('.', ''));
}

/// «Unos $260.000 al mes» for a weekly $60.000; «$94.000 al mes» for a
/// monthly one.
String describeMonthlyCost(
  int amount,
  RecurringFrequency frequency,
  String Function(num) formatMoney, {
  AppLocalizations? l10n,
}) {
  l10n ??= currentL10n;
  return l10n.recurringBillsMonthlyCost(
    isAveraged(frequency) ? 'average' : 'exact',
    formatMoney(monthlyCost(amount, frequency)),
  );
}
