import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';
import 'push_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService();
});
