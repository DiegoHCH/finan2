import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../../../core/crypto/household_crypto.dart';
import '../domain/app_lock_policy.dart';
import 'app_lock_cloud.dart';

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

/// The PIN is the account's: its record (a salted HMAC-SHA256 - the PIN
/// itself is never stored) is kept in [AppLockCloud] so every phone signed
/// in opens with the same one, and copied to this phone's secure storage
/// (Keystore / Keychain) so it works offline. Fingerprint/face and wrong
/// attempts stay per phone; the attempts and the wait they earn are stored
/// too, so closing the app doesn't reset them.
///
/// Not a slow KDF on purpose: with 10,000 possible PINs it wouldn't stop
/// anyone able to read the record, and in pure Dart it froze the pad for
/// minutes on a debug iPhone. The protection is who can read it (secure
/// storage; the owner alone in Firestore) and the attempts limit.
class AppLockRepository {
  /// [account] scopes everything to one signed-in user: signing out keeps
  /// the PIN for when they're back, and another account on this phone has
  /// its own.
  AppLockRepository({
    String? account,
    AppLockCloud? cloud,
    Finan2KeyStore? store,
    DateTime Function()? now,
  }) : _account = account,
       _cloud = account == null ? null : cloud,
       _store = store ?? const Finan2SecureKeyStore(),
       _now = now ?? DateTime.now,
       _suffix = account == null ? '' : '_$account';

  final String? _account;
  final AppLockCloud? _cloud;
  final Finan2KeyStore _store;
  final DateTime Function() _now;
  final String _suffix;

  /// Long enough for a slow connection; offline, the copy here is used.
  static const _cloudWait = Duration(seconds: 4);

  String get _pinKey => 'app_lock_pin$_suffix';
  String get _biometricsKey => 'app_lock_biometrics$_suffix';
  String get _failuresKey => 'app_lock_failures$_suffix';
  String get _untilKey => 'app_lock_until$_suffix';
  String get _onboardedKey => 'app_lock_onboarded$_suffix';

  /// The record the cloud is known to have: tells a PIN that never got
  /// there from one another phone's «forgot your PIN?» removed.
  String get _syncedKey => 'app_lock_synced$_suffix';

  static final _mac = Hmac.sha256();

  /// Takes the account's PIN from the cloud when there is one - a first
  /// sign-in on this phone, or a PIN changed on another - and otherwise
  /// keeps the copy here. A PIN that never reached the cloud - made before
  /// it synced, or while the write was refused - goes up now, so the next
  /// phone finds it.
  Future<AppLockSettings> load() async {
    var record = await _store.read(_pinKey);
    // A phone that had a PIN before the onboarding flag existed is set up.
    final onboarded = record != null || await _store.read(_onboardedKey) == '1';
    final (reached, remote) = await _fetchRemote();
    if (remote != null) {
      if (remote != record) await _store.write(_pinKey, remote);
      record = remote;
      await _store.write(_syncedKey, remote);
    } else if (reached && record != null && await _store.read(_syncedKey) != record) {
      _upload(record);
    }
    return AppLockSettings(
      enabled: record != null,
      biometrics: record != null && await _store.read(_biometricsKey) == '1',
      onboarded: onboarded,
    );
  }

  /// Whether the cloud answered, and its record. Not reached (offline, no
  /// account) is not the same as reached and empty.
  Future<(bool, String?)> _fetchRemote() async {
    final cloud = _cloud;
    if (cloud == null) return (false, null);
    try {
      return (true, await cloud.fetch(_account!).timeout(_cloudWait));
    } on Object {
      return (false, null);
    }
  }

  /// Not awaited: offline, Firestore only completes the write once back
  /// online, and the lock can't wait for that.
  void _syncRemote(Future<void> Function(AppLockCloud cloud, String account) write) {
    final cloud = _cloud;
    if (cloud == null) return;
    write(cloud, _account!).catchError((Object _) {});
  }

  void _upload(String record) => _syncRemote(
    (cloud, account) => cloud.save(account, record).then((_) => _store.write(_syncedKey, record)),
  );

  Future<void> markOnboarded() => _store.write(_onboardedKey, '1');

  /// Turns the lock on, or changes the PIN if it already was.
  Future<void> setPin(String pin) async {
    if (!AppLockPolicy.isValidPin(pin)) throw ArgumentError.value(pin, 'pin');
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _hash(pin, salt);
    final record = '${base64Encode(salt)}:${base64Encode(hash)}';
    await _store.write(_pinKey, record);
    await _resetFailures();
    _upload(record);
  }

  Future<void> setBiometrics(bool on) =>
      on ? _store.write(_biometricsKey, '1') : _store.delete(_biometricsKey);

  /// Forgets this account's PIN, here and in the cloud, and this phone's
  /// setup - the way out of a forgotten PIN, before signing out: signing
  /// back in runs the onboarding and asks for a new one.
  ///
  /// [waitForCloud] when the account itself is going next: once it's gone
  /// nobody signed in can delete the cloud copy, so it has to be gone first.
  /// Otherwise («forgot your PIN?», maybe offline) it isn't waited for.
  Future<void> clear({bool waitForCloud = false}) async {
    await _store.delete(_pinKey);
    await _store.delete(_biometricsKey);
    await _store.delete(_onboardedKey);
    await _store.delete(_syncedKey);
    await _resetFailures();
    final cloud = _cloud;
    if (waitForCloud && cloud != null) {
      await cloud.delete(_account!);
    } else {
      _syncRemote((cloud, account) => cloud.delete(account));
    }
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
    final mac = await _mac.calculateMac(utf8.encode(pin), secretKey: SecretKey(salt));
    return mac.bytes;
  }

  Future<void> _resetFailures() async {
    await _store.delete(_failuresKey);
    await _store.delete(_untilKey);
  }
}
