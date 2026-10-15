import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_reauth.dart';
import '../../../../l10n/l10n.dart';
import '../../data/household_model.dart';
import '../viewmodels/household_providers.dart';

/// Generates the household's recovery phrase, shows it once and saves the
/// key wrapped under it. Returns true once it's saved. Used from Ajustes and
/// from the setup after creating a household.
///
/// Requires reauth (see [reauthenticate]) since anyone holding the phrase
/// can later use it, from any device, to read every amount in the
/// household. [askFirst]: explain and confirm before - the setup already
/// explains it on screen.
Future<bool> createRecoveryPhrase(
  BuildContext context,
  WidgetRef ref,
  Household household, {
  bool askFirst = true,
}) async {
  final confirmed =
      !askFirst ||
      await showFinan2ConfirmSheet(
        context,
        title: context.l10n.householdRecoveryPhraseTitle,
        message: context.l10n.householdRecoveryConfirmMessage,
        confirmLabel: context.l10n.householdGeneratePhrase,
      );
  if (!confirmed || !context.mounted) return false;

  final reauthenticated = await reauthenticate(context, ref);
  if (!reauthenticated || !context.mounted) return false;

  final controller = ref.read(householdControllerProvider.notifier);
  try {
    final (phrase, wrapped) = await controller.prepareRecoveryPhrase(household.id);
    if (!context.mounted) return false;
    await showRecoveryPhrase(context, phrase.words);
    await controller.saveRecoveryPhrase(household.id, wrapped);
    if (!context.mounted) return true;
    await showFinan2InfoSheet(
      context,
      title: context.l10n.householdRecoverySavedTitle,
      message: context.l10n.householdRecoverySavedMessage,
    );
    return true;
  } on Finan2CryptoException catch (e) {
    if (context.mounted) await showFinan2ErrorSheet(context, message: e.message);
  } catch (error) {
    if (context.mounted) {
      await showFinan2ErrorSheet(
        context,
        message: context.l10n.householdRecoverySaveFailed(friendlyErrorMessage(error)),
      );
    }
  }
  return false;
}

/// Shows the freshly generated phrase once. Deliberately no copy button -
/// the clipboard is readable by other apps and synced histories.
Future<void> showRecoveryPhrase(BuildContext context, List<String> words) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
      final textTheme = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sheetContext.l10n.householdRecoveryShowTitle, style: textTheme.titleMedium),
              const SizedBox(height: Finan2Space.sm),
              Text(
                sheetContext.l10n.householdRecoveryShowMessage,
                style: TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45),
              ),
              const SizedBox(height: Finan2Space.md),
              Wrap(
                spacing: Finan2Space.sm,
                runSpacing: Finan2Space.sm,
                children: [
                  for (var i = 0; i < words.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Finan2Space.sm,
                        vertical: Finan2Space.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brandTint,
                        borderRadius: BorderRadius.circular(Finan2Radius.card),
                      ),
                      child: Text(
                        '${i + 1}. ${words[i]}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Finan2Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(sheetContext.l10n.householdRecoveryShowDone),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
