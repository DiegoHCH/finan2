import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_providers.dart';
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
}

final notificationPrefsControllerProvider =
    AsyncNotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);
