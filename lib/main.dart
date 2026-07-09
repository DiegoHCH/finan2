import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finan2',
      theme: Finan2Theme.light,
      darkTheme: Finan2Theme.dark,
      themeMode: ThemeMode.system,
      home: const _PlaceholderScreen(),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Finan2', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: Finan2Space.sm),
            Text(
              'Finanzas del hogar · para dos',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
