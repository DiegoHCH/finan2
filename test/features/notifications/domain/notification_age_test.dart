import 'package:finan2/features/notifications/domain/notification_age.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 15, 14, 30);

  test('notificationAge says minutes, hours, yesterday, then the date', () {
    NotificationAge age(DateTime at) => notificationAge(at, now);
    expect(age(DateTime(2026, 10, 15, 14, 30)).unit, NotificationAgeUnit.minutes);
    expect(age(DateTime(2026, 10, 15, 14, 30)).count, 1);
    expect(age(DateTime(2026, 10, 15, 14, 5)).count, 25);
    expect(age(DateTime(2026, 10, 15, 12, 10)).unit, NotificationAgeUnit.hours);
    expect(age(DateTime(2026, 10, 15, 12, 10)).count, 2);
    expect(age(DateTime(2026, 10, 15, 0, 5)).count, 14);
    expect(age(DateTime(2026, 10, 14, 23, 50)).unit, NotificationAgeUnit.yesterday);
    expect(age(DateTime(2026, 10, 13, 9)).unit, NotificationAgeUnit.date);
  });
}
