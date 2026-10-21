import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_lock_repository.dart';
import '../../data/biometric_unlock.dart';
import '../../domain/app_lock_policy.dart';

final appLockRepositoryProvider = Provider<AppLockRepository>((ref) => AppLockRepository());

final biometricUnlockProvider = Provider<BiometricUnlock>((ref) => LocalAuthBiometricUnlock());

/// Whether this phone has a fingerprint or face enrolled - the biometrics
/// switch only shows when it does.
final biometricsAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricUnlockProvider).available(),
);

class AppLockSettingsController extends AsyncNotifier<AppLockSettings> {
  @override
  Future<AppLockSettings> build() => ref.read(appLockRepositoryProvider).load();

  AppLockRepository get _repository => ref.read(appLockRepositoryProvider);

  /// Turns the lock on (or changes the PIN). Whoever set it is already in,
  /// so it doesn't lock them out on the spot.
  Future<void> setPin(String pin) async {
    final wasEnabled = state.value?.enabled ?? false;
    await _repository.setPin(pin);
    ref.read(appLockedProvider.notifier).unlock();
    state = AsyncData(
      AppLockSettings(enabled: true, biometrics: wasEnabled && (state.value?.biometrics ?? false)),
    );
  }

  Future<void> setBiometrics(bool on) async {
    await _repository.setBiometrics(on);
    state = AsyncData(AppLockSettings(enabled: state.value?.enabled ?? false, biometrics: on));
  }

  Future<void> disable() async {
    await _repository.clear();
    state = const AsyncData(AppLockSettings.off);
  }
}

final appLockSettingsProvider = AsyncNotifierProvider<AppLockSettingsController, AppLockSettings>(
  AppLockSettingsController.new,
);

/// Whether the lock screen is up. Starts locked - a cold start with the
/// lock on always asks - and only matters while the lock is enabled.
class AppLockedController extends Notifier<bool> {
  @override
  bool build() => true;

  void lock() => state = true;

  void unlock() => state = false;
}

final appLockedProvider = NotifierProvider<AppLockedController, bool>(AppLockedController.new);
