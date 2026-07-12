import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/notification_prefs.dart';
import '../../data/notification_prefs_repository.dart';

final notificationPrefsRepositoryProvider = Provider<NotificationPrefsRepository>((ref) {
  return NotificationPrefsRepository();
});

class NotificationPrefsController extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() {
    return ref.read(notificationPrefsRepositoryProvider).load();
  }

  Future<void> updatePrefs(
    NotificationPrefs Function(NotificationPrefs current) updater,
  ) async {
    final current = state.value ?? NotificationPrefs.defaults;
    final next = updater(current);
    state = AsyncData(next);
    await ref.read(notificationPrefsRepositoryProvider).save(next);
    await _syncSchedulingPrefs(next);

    final service = ref.read(notificationServiceProvider);
    if (next.dailyReminder != current.dailyReminder ||
        next.dailyReminderTime != current.dailyReminderTime) {
      if (next.dailyReminder) {
        await service.requestPermission();
        await service.scheduleDailyReminder(next.dailyReminderTime);
      } else {
        await service.cancelDailyReminder();
      }
    }
    if (next.weeklySummary != current.weeklySummary) {
      if (next.weeklySummary) {
        await service.requestPermission();
        await service.scheduleWeeklySummary();
      } else {
        await service.cancelWeeklySummary();
      }
    }
  }

  /// Mirrors just the fields the server-side reminder cron needs (see
  /// cloudflare/finan2-notifications/worker.js) to Firestore. Everything
  /// else about [NotificationPrefs] stays purely on-device - a server cron
  /// can't fire the debt/daily/weekly reminders `NotificationService`
  /// schedules locally on native, since there's no client there to run
  /// `flutter_local_notifications`; this is the piece that fills that gap on
  /// the web target. A missing doc means "use NotificationPrefs.defaults",
  /// so a member who never opens notification settings still gets reminders.
  Future<void> _syncSchedulingPrefs(NotificationPrefs prefs) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return;
    await FirebaseFirestore.instance
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
    });
  }
}

final notificationPrefsControllerProvider =
    AsyncNotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);
