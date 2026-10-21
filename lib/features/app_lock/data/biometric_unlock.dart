import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// The phone's fingerprint or face, behind an interface so tests (and the
/// web, which has neither) never reach the platform plugin.
abstract class BiometricUnlock {
  /// True when the phone has a fingerprint or face enrolled.
  Future<bool> available();

  /// Shows the system prompt; true only on a match. Cancelling, a lockout
  /// or any platform error is a plain false - the PIN is always there.
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometricUnlock implements BiometricUnlock {
  LocalAuthBiometricUnlock({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> available() async {
    if (kIsWeb) return false;
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true);
    } on Exception {
      return false;
    }
  }
}
