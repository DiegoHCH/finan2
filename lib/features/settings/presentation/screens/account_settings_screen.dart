import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_providers.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_option_card.dart';
import '../../../../core/widgets/finan2_reauth.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';

const _themeModeLabels = <ThemeMode, String>{
  ThemeMode.light: 'Claro',
  ThemeMode.dark: 'Oscuro',
  ThemeMode.system: 'Sistema',
};

const _themeModeSubtitles = <ThemeMode, String>{
  ThemeMode.light: 'Siempre fondo claro.',
  ThemeMode.dark: 'Siempre fondo oscuro.',
  ThemeMode.system: 'Sigue el ajuste de tu dispositivo.',
};

const _themeModeIcons = <ThemeMode, IconData>{
  ThemeMode.light: Icons.light_mode_outlined,
  ThemeMode.dark: Icons.dark_mode_outlined,
  ThemeMode.system: Icons.brightness_auto_outlined,
};

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({required this.household, super.key});

  final Household household;

  Future<void> _leaveHousehold(BuildContext context, WidgetRef ref) async {
    final isSolo = household.members.length <= 1;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: 'Salir del hogar',
      message: isSolo
          ? 'Eres el único miembro de "${household.name}". Si sales, se '
              'borrarán para siempre todos sus datos: cuentas, movimientos, '
              'presupuestos, deudas y metas.'
          : 'Vas a salir de "${household.name}". Tus cuentas, movimientos y '
              'demás datos seguirán disponibles para el resto del hogar. '
              'Podrás crear o unirte a otro hogar después.',
      confirmLabel: isSolo ? 'Salir y borrar' : 'Salir',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final reauthenticated = await reauthenticate(context, ref);
      if (!reauthenticated || !context.mounted) return;
      await ref.read(householdControllerProvider.notifier).leaveHousehold(household.id);
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  Future<void> _editMyName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showFinan2InputSheet(
      context,
      title: 'Mi nombre',
      fieldLabel: 'Nombre',
      controller: controller,
    );
    final name = toTitleCase(result ?? '');
    if (name.isEmpty || name == currentName) return;
    await ref.read(householdControllerProvider.notifier).updateMyName(name);
  }

  /// Requires reauth (see [reauthenticate]) since anyone holding the phrase
  /// can later use it, from any device, to read every amount in the
  /// household.
  Future<void> _createRecoveryPhrase(BuildContext context, WidgetRef ref) async {
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: 'Frase de recuperación',
      message: 'Si algún día ninguno de los dos tiene la llave del hogar en su '
          'dispositivo, estas 12 palabras permiten recuperar los montos. Vas a '
          'verlas una sola vez: anótalas en papel y guárdalas con tu pareja. '
          'Si ya había una frase o un PIN, dejarán de servir.',
      confirmLabel: 'Generar frase',
    );
    if (!confirmed || !context.mounted) return;

    final reauthenticated = await reauthenticate(context, ref);
    if (!reauthenticated || !context.mounted) return;

    final controller = ref.read(householdControllerProvider.notifier);
    try {
      final (phrase, wrapped) = await controller.prepareRecoveryPhrase(household.id);
      if (!context.mounted) return;
      await _showRecoveryPhrase(context, phrase.words);
      await controller.saveRecoveryPhrase(household.id, wrapped);
      if (!context.mounted) return;
      await showFinan2InfoSheet(
        context,
        title: 'Frase guardada',
        message: 'Desde ahora esta frase permite recuperar los montos del '
            'hogar en cualquier dispositivo.',
      );
    } on Finan2CryptoException catch (e) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: e.message);
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(
        context,
        message: 'No se pudo guardar la frase nueva, así que no sirve: la '
            'anterior sigue siendo la válida. ${friendlyErrorMessage(error)}',
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final isSolo = household.members.length <= 1;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: 'Eliminar mi cuenta',
      message: isSolo
          ? 'Perderás el acceso a Finan2 de forma permanente y no se puede '
              'deshacer. Como eres el único miembro, también se borrarán '
              'todos los datos de "${household.name}".'
          : 'Perderás el acceso a Finan2 de forma permanente y no se puede '
              'deshacer. También saldrás de tu hogar - sus datos seguirán '
              'disponibles para el otro miembro.',
      confirmLabel: 'Continuar',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final reauthenticated = await reauthenticate(context, ref);
      if (!reauthenticated || !context.mounted) return;
      await ref.read(householdControllerProvider.notifier).deleteAccount();
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  Future<void> _pickThemeMode(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tema', style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: Finan2Space.md),
              for (final mode in ThemeMode.values) ...[
                Finan2OptionCard(
                  icon: _themeModeIcons[mode]!,
                  title: _themeModeLabels[mode]!,
                  subtitle: _themeModeSubtitles[mode]!,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household.members;
    final memberNames = members
        .map((uid) => household.memberInfo[uid]?.name ?? '?')
        .join(', ');
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final myUid = ref.watch(authStateChangesProvider).value?.uid;
    final myName = myUid == null ? '' : (household.memberInfo[myUid]?.name ?? '');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Finan2AppTop(
              label: 'Ajustes de la cuenta',
              title: 'Hogar y notificaciones',
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Finan2ListCard(
                    children: [
                      if (myUid != null)
                        Finan2ListRow(
                          icon: Icons.badge_outlined,
                          label: 'Mi nombre',
                          value: myName,
                          onTap: () => _editMyName(context, ref, myName),
                        ),
                      Finan2ListRow(
                        icon: Finan2Icons.miembros,
                        label: 'Miembros del hogar',
                        value: memberNames,
                      ),
                      Finan2ListRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notificaciones',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationPreferencesScreen(),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: _themeModeIcons[themeMode]!,
                        label: 'Tema',
                        value: _themeModeLabels[themeMode],
                        onTap: () => _pickThemeMode(context, ref, themeMode),
                      ),
                      Finan2ListRow(
                        icon: Icons.vpn_key_outlined,
                        label: 'Frase de recuperación',
                        value: 'Recuperar montos si pierden la llave',
                        onTap: () => _createRecoveryPhrase(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  OutlinedButton(
                    onPressed: () => _leaveHousehold(context, ref),
                    style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
                    child: const Text('Salir del hogar'),
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  TextButton(
                    onPressed: () => _deleteAccount(context, ref),
                    style: TextButton.styleFrom(foregroundColor: colors.inkFaint),
                    child: const Text('Eliminar mi cuenta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the freshly generated phrase once. Deliberately no copy button -
/// the clipboard is readable by other apps and synced histories.
Future<void> _showRecoveryPhrase(BuildContext context, List<String> words) {
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
