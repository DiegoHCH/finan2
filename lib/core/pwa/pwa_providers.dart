import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_persistence.dart';

/// Whether the browser granted persistent (eviction-protected) storage.
/// `null` until [PersistentStorageStatus.requestIfNeeded] has run once;
/// always `true` on native platforms, which don't have this problem.
class PersistentStorageStatus extends Notifier<bool?> {
  @override
  bool? build() => kIsWeb ? null : true;

  Future<void> requestIfNeeded() async {
    if (!kIsWeb || state != null) return;
    await requestNotificationPermissionForPersistence();
    state = await requestPersistentStorage();
  }
}

final persistentStorageStatusProvider = NotifierProvider<PersistentStorageStatus, bool?>(
  PersistentStorageStatus.new,
);
