import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's language: the phone's, or one chosen in Ajustes.
enum AppLanguage {
  system(null),
  es('es'),
  en('en');

  const AppLanguage(this.languageCode);

  /// Null follows the phone.
  final String? languageCode;

  /// The locale to force on the app, or null to follow the phone.
  Locale? get locale => switch (languageCode) {
    final code? => Locale(code),
    null => null,
  };

  /// A language's own name, the same in every language of the app - so
  /// whoever can't read the current one still finds theirs.
  String? get nativeName => switch (this) {
    AppLanguage.system => null,
    AppLanguage.es => 'Español',
    AppLanguage.en => 'English',
  };
}

/// Per device, like the theme: each person picks their own, so it lives in
/// shared_preferences, not Firestore.
class AppLanguageRepository {
  static const _key = 'app_language';

  Future<AppLanguage> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    return AppLanguage.values.firstWhere((l) => l.name == stored, orElse: () => AppLanguage.system);
  }

  Future<void> save(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
  }
}

final appLanguageRepositoryProvider = Provider<AppLanguageRepository>(
  (ref) => AppLanguageRepository(),
);

class AppLanguageController extends AsyncNotifier<AppLanguage> {
  @override
  Future<AppLanguage> build() => ref.read(appLanguageRepositoryProvider).load();

  Future<void> setLanguage(AppLanguage language) async {
    state = AsyncData(language);
    await ref.read(appLanguageRepositoryProvider).save(language);
  }
}

final appLanguageControllerProvider = AsyncNotifierProvider<AppLanguageController, AppLanguage>(
  AppLanguageController.new,
);
