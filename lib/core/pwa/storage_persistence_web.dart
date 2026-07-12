import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// iOS Safari respects the Persistent Storage API much more reliably once
/// notification permission has been granted - ask for that first.
Future<void> requestNotificationPermissionForPersistence() async {
  try {
    await web.Notification.requestPermission().toDart;
  } catch (_) {
    // Notification API unavailable/denied - persistence request below still
    // runs, just with lower odds of being honored by Safari.
  }
}

/// Asks the browser not to evict this origin's storage under pressure.
/// Returns whether the browser granted persistent storage - the caller
/// decides whether to warn the user based on this.
Future<bool> requestPersistentStorage() async {
  try {
    final granted = await web.window.navigator.storage.persist().toDart;
    return granted.toDart;
  } catch (_) {
    return false;
  }
}
