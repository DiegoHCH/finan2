import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app_container.dart';

/// Pumps [screen] the way the app shows it - Spanish unless [locale] says
/// otherwise, light theme - on
/// [app]'s fake household, and lets the first snapshots arrive.
Future<void> pumpScreen(
  WidgetTester tester,
  TestApp app,
  Widget screen, {
  Locale locale = const Locale('es'),
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: app.container,
      child: MaterialApp(
        theme: Finan2Theme.light,
        locale: locale,
        supportedLocales: supportedAppLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  );
  await settle(tester);
}

/// Lets fake Firestore snapshots and decryption land. Not pumpAndSettle:
/// a loading spinner would keep it from ever settling.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}
