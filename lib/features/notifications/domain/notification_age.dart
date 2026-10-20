/// How long ago a notification arrived, in the unit it's said in: «hace 5
/// min», «hace 2 h», «ayer», or its date once it's older.
enum NotificationAgeUnit { minutes, hours, yesterday, date }

class NotificationAge {
  const NotificationAge(this.unit, [this.count = 0]);

  final NotificationAgeUnit unit;

  /// The minutes or hours; 0 for the other units.
  final int count;
}

NotificationAge notificationAge(DateTime at, DateTime now) {
  final diff = now.difference(at);
  if (diff.inMinutes < 60) {
    return NotificationAge(NotificationAgeUnit.minutes, diff.inMinutes.clamp(1, 59));
  }
  final days = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime.utc(at.year, at.month, at.day)).inDays;
  if (days <= 0) return NotificationAge(NotificationAgeUnit.hours, diff.inHours.clamp(1, 23));
  if (days == 1) return const NotificationAge(NotificationAgeUnit.yesterday);
  return const NotificationAge(NotificationAgeUnit.date);
}
