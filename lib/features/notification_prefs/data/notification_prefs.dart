import 'package:flutter/material.dart';

/// Notification settings live on-device (shared_preferences), not in
/// Firestore - what alerts show up on MY phone is a per-user/per-device
/// choice, not shared household data.
class NotificationPrefs {
  const NotificationPrefs({
    required this.dailyReminder,
    required this.dailyReminderTime,
    required this.debtPayments,
    required this.goalProgress,
    required this.budgetExceeded,
    required this.partnerActivity,
    required this.weeklySummary,
  });

  final bool dailyReminder;
  final TimeOfDay dailyReminderTime;
  final bool debtPayments;
  final bool goalProgress;
  final bool budgetExceeded;
  final bool partnerActivity;
  final bool weeklySummary;

  static const defaults = NotificationPrefs(
    dailyReminder: true,
    dailyReminderTime: TimeOfDay(hour: 20, minute: 0),
    debtPayments: true,
    goalProgress: true,
    budgetExceeded: true,
    partnerActivity: false,
    weeklySummary: true,
  );

  NotificationPrefs copyWith({
    bool? dailyReminder,
    TimeOfDay? dailyReminderTime,
    bool? debtPayments,
    bool? goalProgress,
    bool? budgetExceeded,
    bool? partnerActivity,
    bool? weeklySummary,
  }) {
    return NotificationPrefs(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      debtPayments: debtPayments ?? this.debtPayments,
      goalProgress: goalProgress ?? this.goalProgress,
      budgetExceeded: budgetExceeded ?? this.budgetExceeded,
      partnerActivity: partnerActivity ?? this.partnerActivity,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }
}
