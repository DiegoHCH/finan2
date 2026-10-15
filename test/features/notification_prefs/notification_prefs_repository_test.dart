import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/notification_prefs/data/notification_prefs.dart';
import 'package:finan2/features/notification_prefs/data/notification_prefs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('syncToHousehold writes the toggles the Worker cron reads', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = NotificationPrefsRepository(firestore: firestore);
    final prefs = NotificationPrefs.defaults.copyWith(
      dailyReminder: true,
      dailyReminderTime: const TimeOfDay(hour: 21, minute: 30),
      partnerActivity: false,
    );

    await repository.syncToHousehold('h1', 'u1', prefs);

    final doc = await firestore.doc('households/h1/memberPrefs/u1').get();
    expect(doc.data(), {
      'dailyReminder': true,
      'dailyReminderHour': 21,
      'dailyReminderMinute': 30,
      'weeklySummary': prefs.weeklySummary,
      'debtPayments': prefs.debtPayments,
      'goalProgress': prefs.goalProgress,
      'budgetExceeded': prefs.budgetExceeded,
      'partnerActivity': false,
    });
  });
}
