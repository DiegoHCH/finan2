import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] with the app's real theme (widgets rely on
/// `Theme.of(context).extension<Finan2Colors>()`), the app's localizations
/// in Spanish and a Scaffold, then pumps it - the one bit of boilerplate
/// every Finan2* widget test needs.
Future<void> pumpFinan2(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: Finan2Theme.light,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
