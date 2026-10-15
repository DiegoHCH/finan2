import 'package:flutter/material.dart';

import '../../features/household/data/household_model.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Bottom sheet shown when this device doesn't have [household]'s data
/// encryption key yet (reinstall, new device, or it joined pasting only the
/// short invite code). Explains what's missing and, if the user taps the
/// only action, takes them to Ajustes - where the "pegar código" action that
/// actually imports the key lives.
Future<void> showMissingKeySheet(BuildContext context, Household household) async {
  final goToSettings = await showModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.coreMissingKeyTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: Finan2Space.sm),
              Text(
                l10n.coreMissingKeyBody,
                style: TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45),
              ),
              const SizedBox(height: Finan2Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.coreGoToSettings),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (goToSettings == true && context.mounted) {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => SettingsScreen(household: household)));
  }
}
