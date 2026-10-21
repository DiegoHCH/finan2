import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';
import 'push_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService();
});

/// Pushes that arrive while the app is in the foreground - a provider so
/// tests without Firebase can replace it.
final foregroundPushesProvider = Provider<Stream<RemoteMessage>>((ref) {
  return FirebaseMessaging.onMessage;
});

/// Whether the OS lets the app show notifications on this device -
/// invalidated after asking, so screens see the answer.
final notificationsAllowedProvider = FutureProvider<bool>(
  (ref) => ref.watch(pushServiceProvider).notificationsAllowed(),
);
