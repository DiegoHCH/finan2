import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          ? 'Eres el único miembro de "${household.name}". Si sales, nadie '
              'podrá volver a acceder a esta información: se vuelve '
              'permanentemente inaccesible.'
          : 'Vas a salir de "${household.name}". Tus cuentas, movimientos y '
              'demás datos seguirán disponibles para el resto del hogar. '
              'Podrás crear o unirte a otro hogar después.',
      confirmLabel: 'Salir',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final reauthenticated = await reauthenticate(context, ref);
      if (!reauthenticated || !context.mounted) return;
      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      if (uid == null) return;
      await ref.read(householdRepositoryProvider).leaveHousehold(household.id, uid);
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

  /// Requires reauth (see [reauthenticate]) since anyone who can set this
  /// PIN can later use it, from any device, to read every amount in the
  /// household.
  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final reauthenticated = await reauthenticate(context, ref);
    if (!reauthenticated || !context.mounted) return;

    final controller = TextEditingController();
    final pin = await showFinan2InputSheet(
      context,
      title: 'PIN de respaldo',
      message: 'Si algún día ambos pierden el acceso a este hogar, este PIN '
          'permite recuperar los montos desde cualquier dispositivo. Elige '
          '6 dígitos y no los compartas con nadie más que tu pareja.',
      fieldLabel: 'PIN (6 dígitos)',
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      confirmLabel: 'Guardar',
    );
    if (pin == null || pin.isEmpty || !context.mounted) return;

    final error = await ref
        .read(householdControllerProvider.notifier)
        .setPin(householdId: household.id, pin: pin);
    if (!context.mounted) return;

    if (error != null) {
      await showFinan2ErrorSheet(context, message: error);
    } else {
      await showFinan2InfoSheet(
        context,
        title: 'PIN guardado',
        message: 'Ya pueden usarlo para recuperar los montos de este hogar '
            'desde cualquier dispositivo.',
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: 'Eliminar mi cuenta',
      message: 'Perderás el acceso a Finan2 de forma permanente y no se puede '
          'deshacer. También saldrás de tu hogar - sus datos seguirán '
          'disponibles para el otro miembro.',
      confirmLabel: 'Continuar',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final reauthenticated = await reauthenticate(context, ref);
      if (!reauthenticated || !context.mounted) return;
      final authRepo = ref.read(authRepositoryProvider);
      final uid = authRepo.currentUser?.uid;
      if (uid != null) {
        await ref.read(householdRepositoryProvider).leaveHousehold(household.id, uid);
      }
      await authRepo.deleteAccount();
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
                        label: 'PIN de respaldo',
                        value: 'Recuperar montos si pierden la llave',
                        onTap: () => _setPin(context, ref),
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
