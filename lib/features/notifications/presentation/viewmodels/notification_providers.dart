import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/notification_model.dart';
import '../../data/notification_repository.dart';
import '../../data/notification_scanner.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationScannerProvider = Provider<NotificationScanner>((ref) {
  return NotificationScanner(ref.watch(notificationRepositoryProvider));
});

final notificationsProvider = StreamProvider<List<HouseholdNotification>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).watchNotifications(householdId);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? const [];
  return notifications.where((n) => !n.read).length;
});

class NotificationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> markAllRead() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final unreadIds = (ref.read(notificationsProvider).value ?? const [])
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).markAllRead(householdId, unreadIds),
    );
  }
}

final notificationControllerProvider = AsyncNotifierProvider<NotificationController, void>(
  NotificationController.new,
);
