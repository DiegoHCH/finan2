import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../l10n/l10n.dart';
import 'viewmodels/household_providers.dart';

// The two real ways to get this device the household's key back - from
// Ajustes' banner and from the «sin llave» state wherever amounts can't
// open.

/// Asks for the `<code>.<key>` the partner shared from Ajustes and imports
/// its key.
Future<void> unlockWithCode(BuildContext context, WidgetRef ref, String householdId) async {
  final controller = TextEditingController();
  final pasted = await showFinan2InputSheet(
    context,
    title: context.l10n.settingsUnlockAmountsTitle,
    message: context.l10n.settingsUnlockAmountsMessage,
    fieldLabel: context.l10n.settingsUnlockCodeLabel,
    controller: controller,
    confirmLabel: context.l10n.settingsUnlock,
  );
  if (pasted == null || pasted.trim().isEmpty) return;

  final error = await ref
      .read(householdControllerProvider.notifier)
      .importMissingKey(householdId: householdId, pastedCode: pasted);
  if (!context.mounted) return;

  if (error != null) {
    await showFinan2ErrorSheet(context, message: error);
  } else {
    await showFinan2InfoSheet(
      context,
      title: context.l10n.settingsAmountsUnlockedTitle,
      message: context.l10n.settingsAmountsUnlockedMessage,
    );
  }
}

/// Asks for the household's 12-word recovery phrase and unwraps the key
/// with it.
Future<void> unlockWithPhrase(BuildContext context, WidgetRef ref, String householdId) async {
  final controller = TextEditingController();
  final input = await showFinan2InputSheet(
    context,
    title: context.l10n.householdRecoveryPhraseTitle,
    message: context.l10n.settingsRecoveryPhraseMessage,
    fieldLabel: context.l10n.settingsRecoveryPhraseLabel,
    controller: controller,
    keyboardType: TextInputType.text,
    confirmLabel: context.l10n.settingsUnlock,
  );
  if (input == null || input.trim().isEmpty || !context.mounted) return;

  final error = await ref
      .read(householdControllerProvider.notifier)
      .recoverKeyWithPhrase(householdId: householdId, input: input);
  if (!context.mounted) return;

  if (error != null) {
    await showFinan2ErrorSheet(context, message: error);
  } else {
    await showFinan2InfoSheet(
      context,
      title: context.l10n.settingsAmountsUnlockedTitle,
      message: context.l10n.settingsAmountsUnlockedMessage,
    );
  }
}
