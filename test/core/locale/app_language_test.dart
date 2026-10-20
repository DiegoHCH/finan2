import 'package:finan2/core/locale/app_language.dart';
import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/settings/presentation/language_picker.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // resolveAppLocale sets Intl's default; the other tests expect Spanish.
  tearDown(() => resolveAppLocale(const [Locale('es')]));

  test('follows the phone until a language is saved, then remembers it', () async {
    final repository = AppLanguageRepository();
    expect(await repository.load(), AppLanguage.system);
    expect(AppLanguage.system.locale, isNull);

    await repository.save(AppLanguage.en);
    expect(await repository.load(), AppLanguage.en);
    expect(AppLanguage.en.locale, const Locale('en'));
  });

  testWidgets('choosing Español overrides an English phone and is kept', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: Finan2Theme.light,
            // As in main.dart.
            locale: ref.watch(appLanguageControllerProvider).value?.locale,
            supportedLocales: supportedAppLocales,
            localeListResolutionCallback: (locales, _) => resolveAppLocale(locales),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => TextButton(
                  onPressed: () => pickAppLanguage(context, ref, AppLanguage.system),
                  child: Text(context.l10n.settingsLanguage),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The test device is in English, so the app starts in English.
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.text('Same as the phone'), findsOneWidget);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Idioma'), findsOneWidget); // re-rendered in Spanish
    expect(await AppLanguageRepository().load(), AppLanguage.es);
  });
}
