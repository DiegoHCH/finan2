import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_prefs.dart';

/// Notification preferences are stored on-device, not in Firestore - see
/// [NotificationPrefs] for why.
class NotificationPrefsRepository {
  NotificationPrefsRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

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
        minute: prefs.getInt(_keyDailyReminderMinute) ?? defaults.dailyReminderTime.minute,
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

  /// Mirrors every toggle the server-side reminder cron needs (see
  /// cloudflare/finan2-notifications/worker.js) to
  /// `households/{householdId}/memberPrefs/{uid}` - only the on-device
  /// local-notification scheduling stays purely client-side. A server cron
  /// can't fire the reminders `NotificationService` schedules locally on
  /// native (there's no client there to run `flutter_local_notifications`),
  /// nor detect partner activity/budget/goal conditions without a client's
  /// decryption key open at some point - this is the piece that fills both
  /// gaps. A missing doc means "use NotificationPrefs.defaults", so a member
  /// who never opens notification settings still gets reminders.
  Future<void> syncToHousehold(String householdId, String uid, NotificationPrefs prefs) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('memberPrefs')
        .doc(uid)
        .set({
          'dailyReminder': prefs.dailyReminder,
          'dailyReminderHour': prefs.dailyReminderTime.hour,
          'dailyReminderMinute': prefs.dailyReminderTime.minute,
          'weeklySummary': prefs.weeklySummary,
          'debtPayments': prefs.debtPayments,
          'goalProgress': prefs.goalProgress,
          'budgetExceeded': prefs.budgetExceeded,
          'partnerActivity': prefs.partnerActivity,
        });
  }
}
