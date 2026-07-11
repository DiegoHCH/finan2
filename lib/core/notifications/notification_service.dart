import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/debts/data/debt_model.dart';

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
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // Unknown/unsupported timezone name - fall back to UTC rather than crash.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Requests OS notification permission (and, on Android, exact-alarm
  /// permission needed for reminders to fire at the exact chosen time).
  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    var granted = true;
    if (androidImpl != null) {
      granted = await androidImpl.requestNotificationsPermission() ?? granted;
      await androidImpl.requestExactAlarmsPermission();
    }
    if (iosImpl != null) {
      granted = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          granted;
    }
    return granted;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) {
    return _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'Registra tus gastos de hoy',
      body: 'No olvides anotar lo que ingresó o gastó el hogar hoy.',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('daily_reminder', 'Recordatorio diario'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(id: _dailyReminderId);

  Future<void> scheduleWeeklySummary() {
    return _plugin.zonedSchedule(
      id: _weeklySummaryId,
      title: 'Resumen semanal listo',
      body: 'Revisa cómo le fue al hogar esta semana en Finan2.',
      scheduledDate: _nextInstanceOfWeekdayTime(_weeklySummaryWeekday, _weeklySummaryTime),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('weekly_summary', 'Resumen semanal'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelWeeklySummary() => _plugin.cancel(id: _weeklySummaryId);

  /// (Re)schedules one reminder per active debt, 2 days before its
  /// `paymentDay`, repeating monthly. Paid-off debts get their reminder
  /// cancelled.
  Future<void> scheduleDebtPaymentReminders(List<Debt> debts) async {
    for (final debt in debts) {
      final id = _debtNotificationId(debt.id);
      if (debt.balance <= 0) {
        await _plugin.cancel(id: id);
        continue;
      }
      final reminderDay = debt.paymentDay - 2 < 1 ? 1 : debt.paymentDay - 2;
      await _plugin.zonedSchedule(
        id: id,
        title: 'Pago de ${debt.name} pronto',
        body: 'La cuota de ${debt.name} vence pronto.',
        scheduledDate: _nextInstanceOfMonthDayTime(reminderDay, _debtReminderTime),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('debt_reminders', 'Pagos de deudas'),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  Future<void> cancelDebtPaymentReminder(String debtId) =>
      _plugin.cancel(id: _debtNotificationId(debtId));

  int _debtNotificationId(String debtId) => 1000 + (debtId.hashCode & 0xFFFF);
}

tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
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
  var scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, day, time.hour, time.minute);
  if (scheduled.isBefore(now)) {
    scheduled = tz.TZDateTime(tz.local, now.year, now.month + 1, day, time.hour, time.minute);
  }
  return scheduled;
}
