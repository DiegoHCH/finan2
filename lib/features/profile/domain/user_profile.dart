/// Who the account is, kept in `users/{uid}` and not in any household: the
/// name (copied into the household for the partner to see), the sign-in
/// email, and the preferences that follow the account to every phone.
class UserProfile {
  const UserProfile({required this.name, required this.email, this.language, this.theme});

  final String name;
  final String email;

  /// `system`, `es` or `en` - the app language's name; null until chosen.
  final String? language;

  /// `system`, `light` or `dark` - the theme's name; null until chosen.
  final String? theme;
}
