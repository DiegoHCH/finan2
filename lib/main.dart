import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_providers.dart';
import 'core/widgets/auth_gate.dart';
import 'firebase_options.dart';
import 'core/observability/error_reporter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ErrorReporter.install();
  await initializeDateFormatting('es');
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
    return MaterialApp(
      title: 'Finan2',
      debugShowCheckedModeBanner: false,
      theme: Finan2Theme.light,
      darkTheme: Finan2Theme.dark,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
