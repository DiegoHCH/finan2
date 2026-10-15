import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/debts/domain/entities/debt.dart';
import '../../l10n/l10n.dart';
import '../utils/local_timezone.dart';
import '../observability/error_reporter.dart';

/// Thin wrapper around flutter_local_notifications for the reminders that
/// must fire even when the app isn't open: daily reminder, weekly summary,
/// and per-debt payment reminders. The in-app notification center
/// (households/{hid}/notifications) is separate and only updates while the
/// app is running - see notification_scanner.dart.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _dailyReminderId = 1;
  static const _weeklySummaryId = 2;
  static const _weeklySummaryWeekday = DateTime.sunday;
  static const _weeklySummaryTime = TimeOfDay(hour: 19, minute: 0);
  static const _debtReminderTime = TimeOfDay(hour: 9, minute: 0);

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    final timezoneId = await getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneId));
    } catch (e, st) {
      // Unknown/unsupported timezone name - fall back to UTC rather than crash.
      ErrorReporter.recoverable(e, st, reason: 'timezone $timezoneId not found, using UTC');
    }

    const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_finan2');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Requests OS notification permission (and, on Android, exact-alarm
  /// permission needed for reminders to fire at the exact chosen time).
  Future<bool> requestPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    var granted = true;
    if (androidImpl != null) {
      granted = await androidImpl.requestNotificationsPermission() ?? granted;
      await androidImpl.requestExactAlarmsPermission();
    }
    if (iosImpl != null) {
      granted = await iosImpl.requestPermissions(alert: true, badge: true, sound: true) ?? granted;
    }
    return granted;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) {
    final l10n = currentL10n;
    return _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: l10n.reminderDailyTitle,
      body: l10n.reminderDailyBody,
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('daily_reminder', l10n.reminderDailyChannel),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(id: _dailyReminderId);

  Future<void> scheduleWeeklySummary() {
    final l10n = currentL10n;
    return _plugin.zonedSchedule(
      id: _weeklySummaryId,
      title: l10n.reminderWeeklyTitle,
      body: l10n.reminderWeeklyBody,
      scheduledDate: _nextInstanceOfWeekdayTime(_weeklySummaryWeekday, _weeklySummaryTime),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('weekly_summary', l10n.reminderWeeklyChannel),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelWeeklySummary() => _plugin.cancel(id: _weeklySummaryId);

  /// The reminder countdown: one local notification per day, starting 3 days
  /// before `paymentDay` through the day itself (day 0).
  static const _debtReminderDaysBefore = [3, 2, 1, 0];

  /// (Re)schedules the 4-day reminder countdown for every active debt,
  /// repeating monthly. Paid-off debts get all 4 cancelled.
  Future<void> scheduleDebtPaymentReminders(List<Debt> debts) async {
    final l10n = currentL10n;
    for (final debt in debts) {
      for (final daysBefore in _debtReminderDaysBefore) {
        final id = _debtNotificationId(debt.id, daysBefore);
        if (debt.balance <= 0) {
          await _plugin.cancel(id: id);
          continue;
        }
        final isToday = daysBefore == 0;
        final reminderDay = debt.paymentDay - daysBefore < 1 ? 1 : debt.paymentDay - daysBefore;
        await _plugin.zonedSchedule(
          id: id,
          title: isToday
              ? l10n.reminderDebtTodayTitle(debt.name)
              : l10n.reminderDebtSoonTitle(debt.name),
          body: isToday
              ? l10n.reminderDebtTodayBody(debt.name)
              : l10n.reminderDebtSoonBody(debt.name, daysBefore),
          scheduledDate: _nextInstanceOfMonthDayTime(reminderDay, _debtReminderTime),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails('debt_reminders', l10n.reminderDebtChannel),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
      }
    }
  }

  Future<void> cancelDebtPaymentReminder(String debtId) async {
    for (final daysBefore in _debtReminderDaysBefore) {
      await _plugin.cancel(id: _debtNotificationId(debtId, daysBefore));
    }
  }

  /// Shows a push immediately - used for FCM messages that arrive while the
  /// app is in the foreground, since Android/iOS don't surface those in the
  /// system tray on their own the way they do for background/terminated.
  Future<void> showNow({required String title, required String body}) {
    return _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('finan2_activity', currentL10n.reminderActivityChannel),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  int _debtNotificationId(String debtId, int daysBefore) =>
      1000 + ('$debtId:$daysBefore'.hashCode & 0xFFFF);
}

tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
  if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
  return scheduled;
}

tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, TimeOfDay time) {
  var scheduled = _nextInstanceOfTime(time);
  while (scheduled.weekday != weekday) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

tz.TZDateTime _nextInstanceOfMonthDayTime(int day, TimeOfDay time) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, day, time.hour, time.minute);
  if (scheduled.isBefore(now)) {
    scheduled = tz.TZDateTime(tz.local, now.year, now.month + 1, day, time.hour, time.minute);
  }
  return scheduled;
}
