import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_reauth.dart';
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
  final confirmed = !askFirst ||
      await showFinan2ConfirmSheet(
        context,
        title: 'Frase de recuperación',
        message: 'Si algún día ninguno de los dos tiene la llave del hogar en su '
            'dispositivo, estas 12 palabras permiten recuperar los montos. Vas a '
            'verlas una sola vez: anótalas en papel y guárdalas con tu pareja. '
            'Si ya había una frase o un PIN, dejarán de servir.',
        confirmLabel: 'Generar frase',
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
      title: 'Frase guardada',
      message: 'Desde ahora esta frase permite recuperar los montos del '
          'hogar en cualquier dispositivo.',
    );
    return true;
  } on Finan2CryptoException catch (e) {
    if (context.mounted) await showFinan2ErrorSheet(context, message: e.message);
  } catch (error) {
    if (context.mounted) {
      await showFinan2ErrorSheet(
        context,
        message: 'No se pudo guardar la frase nueva, así que no sirve: la '
            'anterior sigue siendo la válida. ${friendlyErrorMessage(error)}',
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
              Text('Anota estas 12 palabras', style: textTheme.titleMedium),
              const SizedBox(height: Finan2Space.sm),
              Text(
                'En este orden. No se vuelven a mostrar y Finan2 no las guarda.',
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
                  child: const Text('Ya las anoté'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
