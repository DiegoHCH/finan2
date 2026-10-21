import 'package:shared_preferences/shared_preferences.dart';

/// Whether this device was already asked about notifications, and what it
/// answered. «Ahora no» has to stick: registering the push token on a later
/// launch would otherwise raise the bare system prompt on its own.
abstract final class NotificationOptIn {
  static const _askedKey = 'notif_primer_shown';
  static const _optedInKey = 'notif_opt_in';

  static Future<void> record({required bool optedIn}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
    await prefs.setBool(_optedInKey, optedIn);
  }

  static Future<bool> wasAsked() async =>
      (await SharedPreferences.getInstance()).getBool(_askedKey) ?? false;

  /// Null when asked before this was recorded (it behaves as a yes, as it
  /// always did).
  static Future<bool?> optedIn() async =>
      (await SharedPreferences.getInstance()).getBool(_optedInKey);
}
