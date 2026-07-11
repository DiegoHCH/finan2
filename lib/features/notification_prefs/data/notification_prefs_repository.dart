import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_prefs.dart';

/// Notification preferences are stored on-device, not in Firestore - see
/// [NotificationPrefs] for why.
class NotificationPrefsRepository {
  static const _keyDailyReminder = 'notif_daily_reminder';
  static const _keyDailyReminderHour = 'notif_daily_reminder_hour';
  static const _keyDailyReminderMinute = 'notif_daily_reminder_minute';
  static const _keyDebtPayments = 'notif_debt_payments';
  static const _keyGoalProgress = 'notif_goal_progress';
  static const _keyBudgetExceeded = 'notif_budget_exceeded';
  static const _keyPartnerActivity = 'notif_partner_activity';
  static const _keyWeeklySummary = 'notif_weekly_summary';

  Future<NotificationPrefs> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = NotificationPrefs.defaults;
    return NotificationPrefs(
      dailyReminder: prefs.getBool(_keyDailyReminder) ?? defaults.dailyReminder,
      dailyReminderTime: TimeOfDay(
        hour: prefs.getInt(_keyDailyReminderHour) ?? defaults.dailyReminderTime.hour,
        minute:
            prefs.getInt(_keyDailyReminderMinute) ?? defaults.dailyReminderTime.minute,
      ),
      debtPayments: prefs.getBool(_keyDebtPayments) ?? defaults.debtPayments,
      goalProgress: prefs.getBool(_keyGoalProgress) ?? defaults.goalProgress,
      budgetExceeded: prefs.getBool(_keyBudgetExceeded) ?? defaults.budgetExceeded,
      partnerActivity: prefs.getBool(_keyPartnerActivity) ?? defaults.partnerActivity,
      weeklySummary: prefs.getBool(_keyWeeklySummary) ?? defaults.weeklySummary,
    );
  }

  Future<void> save(NotificationPrefs value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyReminder, value.dailyReminder);
    await prefs.setInt(_keyDailyReminderHour, value.dailyReminderTime.hour);
    await prefs.setInt(_keyDailyReminderMinute, value.dailyReminderTime.minute);
    await prefs.setBool(_keyDebtPayments, value.debtPayments);
    await prefs.setBool(_keyGoalProgress, value.goalProgress);
    await prefs.setBool(_keyBudgetExceeded, value.budgetExceeded);
    await prefs.setBool(_keyPartnerActivity, value.partnerActivity);
    await prefs.setBool(_keyWeeklySummary, value.weeklySummary);
  }
}
