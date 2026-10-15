import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The chosen theme is per-device, like notification prefs - not shared
/// household data, so it lives in shared_preferences, not Firestore.
class ThemeModeRepository {
  static const _key = 'app_theme_mode';

  Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    return ThemeMode.values.firstWhere((m) => m.name == stored, orElse: () => ThemeMode.system);
  }

  Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
