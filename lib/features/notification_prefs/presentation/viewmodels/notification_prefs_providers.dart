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

  Future<void> updatePrefs(NotificationPrefs Function(NotificationPrefs current) updater) async {
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

  Future<void> _syncSchedulingPrefs(NotificationPrefs prefs) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return;
    await ref.read(notificationPrefsRepositoryProvider).syncToHousehold(householdId, uid, prefs);
  }
}

final notificationPrefsControllerProvider =
    AsyncNotifierProvider<NotificationPrefsController, NotificationPrefs>(
      NotificationPrefsController.new,
    );
