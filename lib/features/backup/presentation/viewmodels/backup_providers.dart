import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(crypto: ref.watch(householdCryptoProvider));
});

/// Backup and restore of the current household. Errors are thrown, not kept
/// in state: the screen shows each one in an error sheet.
class BackupController extends Notifier<void> {
  @override
  void build() {}

  /// The sealed backup of the current household, or null without one.
  Future<List<int>?> create() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return null;
    return ref.read(backupRepositoryProvider).create(householdId);
  }

  /// Reads a backup's header without opening it - to confirm before
  /// [restore].
  BackupInfo inspect(List<int> bytes) => ref.read(backupRepositoryProvider).inspect(bytes);

  /// Null when there's no household or no signed-in user.
  Future<RestoreResult?> restore(List<int> bytes) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return null;
    return ref.read(backupRepositoryProvider).restore(householdId, bytes, currentUid: uid);
  }
}

final backupControllerProvider = NotifierProvider<BackupController, void>(BackupController.new);
