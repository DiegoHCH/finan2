import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// The app's languages. Spanish first: it's the default, and what any device
/// in a language we don't support gets.
const supportedAppLocales = [Locale('es'), Locale('en')];

/// Picks the app's language from the device's and makes it the default for
/// every `DateFormat` and `NumberFormat` that doesn't name one.
Locale resolveAppLocale(List<Locale>? deviceLocales) {
  final codes = supportedAppLocales.map((l) => l.languageCode).toSet();
  final match = deviceLocales?.firstWhere(
    (l) => codes.contains(l.languageCode),
    orElse: () => supportedAppLocales.first,
  );
  final locale = Locale(match?.languageCode ?? supportedAppLocales.first.languageCode);
  Intl.defaultLocale = locale.languageCode;
  return locale;
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// For code with no BuildContext - repositories, notification texts, error
/// messages. Follows the language [resolveAppLocale] picked.
AppLocalizations get currentL10n =>
    lookupAppLocalizations(Locale(Intl.defaultLocale ?? supportedAppLocales.first.languageCode));
