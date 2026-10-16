/// Calendar months from [now]'s month to [date]'s month, at least 1: a goal
/// for December seen in October has two months to go (November and
/// December's contributions).
int monthsUntil(DateTime date, DateTime now) {
  final months = (date.year - now.year) * 12 + date.month - now.month;
  return months < 1 ? 1 : months;
}

/// What has to go in each month to reach [target] by [targetDate] from
/// [saved] - the figure that says whether a goal is realistic. Null without
/// a date; 0 once the goal is reached. Rounded up, so following it gets
/// there.
int? monthlyNeeded({
  required int target,
  required int saved,
  required DateTime? targetDate,
  required DateTime now,
}) {
  if (targetDate == null) return null;
  final remaining = target - saved;
  if (remaining <= 0) return 0;
  final months = monthsUntil(targetDate, now);
  return (remaining + months - 1) ~/ months;
}

/// How much each person put in: [contributions] as (who, amount) pairs,
/// summed by who.
Map<String, int> contributedBy(Iterable<(String, int)> contributions) {
  final totals = <String, int>{};
  for (final (who, amount) in contributions) {
    totals[who] = (totals[who] ?? 0) + amount;
  }
  return totals;
}

/// Of goals that have a date ([onTrack] non-null), how many are on time -
/// «van a tiempo en 2 de 3 metas».
({int onTime, int dated}) goalsOnTime(Iterable<bool?> onTrack) {
  var onTime = 0;
  var dated = 0;
  for (final value in onTrack) {
    if (value == null) continue;
    dated++;
    if (value) onTime++;
  }
  return (onTime: onTime, dated: dated);
}
