import '../../l10n/l10n.dart';

/// Password policy: at least 8 characters, at least one uppercase and one
/// lowercase letter. Digits and special characters (., -, etc.) are allowed
/// but not required.
final RegExp passwordPolicy = RegExp(r'^(?=.*[A-Z])(?=.*[a-z]).{8,}$');

String get passwordPolicyMessage => currentL10n.validationPasswordPolicy;

String? validateNewPassword(String? value) {
  if (value == null || !passwordPolicy.hasMatch(value)) {
    return passwordPolicyMessage;
  }
  return null;
}
