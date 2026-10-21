import 'package:finan2/features/app_lock/data/biometric_unlock.dart';

/// Fingerprint/face without the platform: [enrolled] says whether the phone
/// has one, [matches] whether the next prompt succeeds. Counts the prompts.
class FakeBiometricUnlock implements BiometricUnlock {
  FakeBiometricUnlock({this.enrolled = false, this.matches = false});

  bool enrolled;
  bool matches;
  var prompts = 0;

  @override
  Future<bool> available() async => enrolled;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return matches;
  }
}
