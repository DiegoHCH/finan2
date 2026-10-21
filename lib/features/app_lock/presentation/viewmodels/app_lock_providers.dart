import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';

import '../../data/app_lock_cloud.dart';
import '../../data/app_lock_repository.dart';
import '../../data/biometric_unlock.dart';
import '../../domain/app_lock_policy.dart';

/// The lock of whoever is signed in, on this phone.
final appLockRepositoryProvider = Provider<AppLockRepository>(
  (ref) => AppLockRepository(
    account: ref.watch(authStateChangesProvider).value?.uid,
    cloud: FirestoreAppLockCloud(),
  ),
);

final biometricUnlockProvider = Provider<BiometricUnlock>((ref) => LocalAuthBiometricUnlock());

/// Whether this phone has a fingerprint or face enrolled - the biometrics
/// switch only shows when it does.
final biometricsAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricUnlockProvider).available(),
);

class AppLockSettingsController extends AsyncNotifier<AppLockSettings> {
  @override
  Future<AppLockSettings> build() => ref.watch(appLockRepositoryProvider).load();

  AppLockRepository get _repository => ref.read(appLockRepositoryProvider);

  AppLockSettings get _current => state.value ?? AppLockSettings.off;

  /// Sets or changes the account's PIN. Whoever set it is already in, so
  /// it doesn't lock them out on the spot.
  Future<void> setPin(String pin) async {
    await _repository.setPin(pin);
    ref.read(appLockedProvider.notifier).unlock();
    state = AsyncData(_current.copyWith(enabled: true));
  }

  /// The onboarding's end, all written together so the app moves on once:
  /// [pin] when the account had none yet, and this phone's biometrics.
  Future<void> setUp({required String? pin, required bool biometrics}) async {
    if (pin != null) await _repository.setPin(pin);
    await _repository.setBiometrics(biometrics);
    await _repository.markOnboarded();
    ref.read(appLockedProvider.notifier).unlock();
    state = AsyncData(_current.copyWith(enabled: true, biometrics: biometrics, onboarded: true));
  }

  Future<void> setBiometrics(bool on) async {
    await _repository.setBiometrics(on);
    state = AsyncData(_current.copyWith(biometrics: on));
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
