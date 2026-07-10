/// Password policy: at least 8 characters, at least one uppercase and one
/// lowercase letter. Digits and special characters (., -, etc.) are allowed
/// but not required.
final RegExp passwordPolicy = RegExp(r'^(?=.*[A-Z])(?=.*[a-z]).{8,}$');

const String passwordPolicyMessage =
    'Mínimo 8 caracteres, con una mayúscula y una minúscula';

String? validateNewPassword(String? value) {
  if (value == null || !passwordPolicy.hasMatch(value)) {
    return passwordPolicyMessage;
  }
  return null;
}
