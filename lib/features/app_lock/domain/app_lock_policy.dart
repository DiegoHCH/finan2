/// How the app lock is set for this account on this phone: the account's
/// 4-digit PIN (the same on all its phones) and, optionally, this phone's
/// fingerprint or face to skip typing it.
class AppLockSettings {
  const AppLockSettings({required this.enabled, required this.biometrics, required this.onboarded});

  static const off = AppLockSettings(enabled: false, biometrics: false, onboarded: false);

  /// The account has a PIN.
  final bool enabled;

  /// Only meaningful while [enabled]: the PIN always works as well.
  final bool biometrics;

  /// This phone went through the first-time steps (notifications, PIN,
  /// fingerprint) for this account.
  final bool onboarded;

  AppLockSettings copyWith({bool? enabled, bool? biometrics, bool? onboarded}) => AppLockSettings(
    enabled: enabled ?? this.enabled,
    biometrics: biometrics ?? this.biometrics,
    onboarded: onboarded ?? this.onboarded,
  );
}

/// The rules of the lock, kept apart from where they're stored or shown.
abstract final class AppLockPolicy {
  static const pinLength = 4;

  /// Wrong PINs allowed before the pad stops answering for a while.
  static const freeAttempts = 5;

  /// Away from the app this long, it asks again on return. Short enough
  /// that a phone left on the table locks; long enough that sharing a file
  /// or answering a message doesn't.
  static const backgroundGrace = Duration(seconds: 30);

  static bool isValidPin(String pin) =>
      pin.length == pinLength && pin.codeUnits.every((c) => c >= 0x30 && c <= 0x39);

  /// How long the pad waits after [failures] wrong PINs in a row: nothing
  /// for the first [freeAttempts], then 30 s, doubling on every further
  /// miss up to 5 minutes.
  static Duration lockoutAfter(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final doublings = failures - freeAttempts;
    final seconds = 30 * (1 << (doublings > 4 ? 4 : doublings));
    return Duration(seconds: seconds > 300 ? 300 : seconds);
  }

  /// Wrong PINs left before the first wait, for the hint under the dots.
  static int attemptsLeft(int failures) => failures >= freeAttempts ? 0 : freeAttempts - failures;
}
