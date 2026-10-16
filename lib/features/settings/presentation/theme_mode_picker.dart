import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_providers.dart';
import '../../../core/widgets/finan2_option_card.dart';
import '../../../l10n/l10n.dart';

String themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.light => l10n.settingsThemeLight,
  ThemeMode.dark => l10n.settingsThemeDark,
  ThemeMode.system => l10n.settingsThemeSystem,
};

String _themeModeSubtitle(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.light => l10n.settingsThemeLightSubtitle,
  ThemeMode.dark => l10n.settingsThemeDarkSubtitle,
  ThemeMode.system => l10n.settingsThemeSystemSubtitle,
};

const themeModeIcons = <ThemeMode, IconData>{
  ThemeMode.light: Icons.light_mode_outlined,
  ThemeMode.dark: Icons.dark_mode_outlined,
  ThemeMode.system: Icons.brightness_auto_outlined,
};

/// The sheet to choose light, dark or the phone's setting.
Future<void> pickThemeMode(BuildContext context, WidgetRef ref, ThemeMode current) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sheetContext.l10n.settingsTheme,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: Finan2Space.md),
            for (final mode in ThemeMode.values) ...[
              Finan2OptionCard(
                icon: themeModeIcons[mode]!,
                title: themeModeLabel(sheetContext.l10n, mode),
                subtitle: _themeModeSubtitle(sheetContext.l10n, mode),
                selected: current == mode,
                onTap: () {
                  ref.read(themeModeControllerProvider.notifier).setThemeMode(mode);
                  Navigator.of(sheetContext).pop();
                },
              ),
              if (mode != ThemeMode.values.last) const SizedBox(height: Finan2Space.sm),
            ],
          ],
        ),
      ),
    ),
  );
}
