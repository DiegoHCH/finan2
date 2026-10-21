import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/locale/app_language.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_providers.dart';
import 'core/widgets/auth_gate.dart';
import 'features/app_lock/presentation/app_lock_gate.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'core/observability/error_reporter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ErrorReporter.install();
  // On by default on Android and iOS but not on the web, so a web session
  // started offline saw nothing. Amounts stay encrypted in the cache - it
  // holds the same documents Firestore does. Multi-tab so two open tabs
  // share one cache instead of the second failing to open it.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024,
    webPersistentTabManager: WebPersistentMultipleTabManager(),
  );
  await initializeDateFormatting();
  resolveAppLocale(WidgetsBinding.instance.platformDispatcher.locales);
  await NotificationService().initialize();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Falls back to system while the saved preference is still loading (the
    // very first frame only) - ThemeModeRepository persists it on-device.
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    // Null follows the phone; a language chosen in Ajustes overrides it. Either
    // way localeListResolutionCallback runs and sets Intl's default.
    final language = ref.watch(appLanguageControllerProvider).value ?? AppLanguage.system;
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: language.locale,
      supportedLocales: supportedAppLocales,
      localeListResolutionCallback: (locales, _) => resolveAppLocale(locales),
      debugShowCheckedModeBanner: false,
      theme: Finan2Theme.light,
      darkTheme: Finan2Theme.dark,
      themeMode: themeMode,
      home: const AuthGate(),
      // Above the Navigator, so the lock covers whatever screen is open.
      builder: (context, child) => AppLockGate(child: child!),
    );
  }
}
