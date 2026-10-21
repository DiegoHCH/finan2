import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../../../core/crypto/household_crypto.dart';
import '../domain/app_lock_policy.dart';

/// What came of typing a PIN.
class PinCheck {
  const PinCheck({required this.ok, required this.failures, this.lockedUntil});

  final bool ok;

  /// Wrong PINs in a row so far (0 after a right one).
  final int failures;

  /// Set while the pad has to wait - including when the PIN wasn't even
  /// checked because an earlier wait hadn't run out.
  final DateTime? lockedUntil;
}

/// The app lock lives on this device only, in the same secure storage as
/// the household key (Keystore / Keychain). The PIN is never stored: only a
/// salted PBKDF2 of it. Wrong attempts and the wait they earn are stored
/// too, so closing the app doesn't reset them.
class AppLockRepository {
  AppLockRepository({Finan2KeyStore? store, DateTime Function()? now})
    : _store = store ?? const Finan2SecureKeyStore(),
      _now = now ?? DateTime.now;

  final Finan2KeyStore _store;
  final DateTime Function() _now;

  static const _pinKey = 'app_lock_pin';
  static const _biometricsKey = 'app_lock_biometrics';
  static const _failuresKey = 'app_lock_failures';
  static const _untilKey = 'app_lock_until';

  static final _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 20000, bits: 256);

  Future<AppLockSettings> load() async {
    final enabled = await _store.read(_pinKey) != null;
    if (!enabled) return AppLockSettings.off;
    return AppLockSettings(enabled: true, biometrics: await _store.read(_biometricsKey) == '1');
  }

  /// Turns the lock on, or changes the PIN if it already was.
  Future<void> setPin(String pin) async {
    if (!AppLockPolicy.isValidPin(pin)) throw ArgumentError.value(pin, 'pin');
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _hash(pin, salt);
    await _store.write(_pinKey, '${base64Encode(salt)}:${base64Encode(hash)}');
    await _resetFailures();
  }

  Future<void> setBiometrics(bool on) =>
      on ? _store.write(_biometricsKey, '1') : _store.delete(_biometricsKey);

  /// Turns the lock off and forgets everything about it - also on sign-out,
  /// so the next account on this phone doesn't inherit someone's PIN.
  Future<void> clear() async {
    await _store.delete(_pinKey);
    await _store.delete(_biometricsKey);
    await _resetFailures();
  }

  Future<DateTime?> lockedUntil() async {
    final stored = int.tryParse(await _store.read(_untilKey) ?? '');
    if (stored == null) return null;
    final until = DateTime.fromMillisecondsSinceEpoch(stored);
    return until.isAfter(_now()) ? until : null;
  }

  Future<int> failures() async => int.tryParse(await _store.read(_failuresKey) ?? '') ?? 0;

  Future<PinCheck> verify(String pin) async {
    final failures = await this.failures();
    final waiting = await lockedUntil();
    if (waiting != null) return PinCheck(ok: false, failures: failures, lockedUntil: waiting);

    if (await _matches(pin)) {
      await _resetFailures();
      return const PinCheck(ok: true, failures: 0);
    }
    final next = failures + 1;
    await _store.write(_failuresKey, '$next');
    final wait = AppLockPolicy.lockoutAfter(next);
    if (wait == Duration.zero) return PinCheck(ok: false, failures: next);
    final until = _now().add(wait);
    await _store.write(_untilKey, '${until.millisecondsSinceEpoch}');
    return PinCheck(ok: false, failures: next, lockedUntil: until);
  }

  /// A right fingerprint or face counts as a right PIN.
  Future<void> recordUnlock() => _resetFailures();

  Future<bool> _matches(String pin) async {
    final stored = await _store.read(_pinKey);
    if (stored == null || !AppLockPolicy.isValidPin(pin)) return false;
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    final expected = base64Decode(parts[1]);
    final actual = await _hash(pin, base64Decode(parts[0]));
    if (actual.length != expected.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual[i] ^ expected[i];
    }
    return diff == 0;
  }

  Future<List<int>> _hash(String pin, List<int> salt) async {
    final key = await _kdf.deriveKey(secretKey: SecretKey(utf8.encode(pin)), nonce: salt);
    return key.extractBytes();
  }

  Future<void> _resetFailures() async {
    await _store.delete(_failuresKey);
    await _store.delete(_untilKey);
  }
}
