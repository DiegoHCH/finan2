import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../auth/presentation/screens/login_screen.dart' show authErrorMessage;
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({required this.household, super.key});

  final Household household;

  Future<void> _leaveHousehold(BuildContext context, WidgetRef ref) async {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isSolo = household.members.length <= 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del hogar'),
        content: Text(
          isSolo
              ? 'Eres el único miembro de "${household.name}". Si sales, nadie '
                  'podrá volver a acceder a esta información: se vuelve '
                  'permanentemente inaccesible.'
              : 'Vas a salir de "${household.name}". Tus cuentas, movimientos y '
                  'demás datos seguirán disponibles para el resto del hogar. '
                  'Podrás crear o unirte a otro hogar después.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Salir', style: TextStyle(color: colors.expense)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    try {
      await ref.read(householdRepositoryProvider).leaveHousehold(household.id, uid);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<String?> _askPassword(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirma tu contraseña'),
        content: Finan2Field(
          label: 'Contraseña',
          controller: controller,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return (result == null || result.isEmpty) ? null : result;
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mi cuenta'),
        content: const Text(
          'Perderás el acceso a Finan2 de forma permanente y no se puede '
          'deshacer. También saldrás de tu hogar - sus datos seguirán '
          'disponibles para el otro miembro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Continuar', style: TextStyle(color: colors.expense)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final authRepo = ref.read(authRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (authRepo.signedInWithGoogle) {
        await authRepo.reauthenticateWithGoogle();
      } else {
        final password = await _askPassword(context);
        if (password == null) return;
        if (!context.mounted) return;
        await authRepo.reauthenticateWithPassword(password);
      }
      final uid = authRepo.currentUser?.uid;
      if (uid != null) {
        await ref.read(householdRepositoryProvider).leaveHousehold(household.id, uid);
      }
      await authRepo.deleteAccount();
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household.members;
    final memberNames = members
        .map((uid) => household.memberInfo[uid]?.name ?? '?')
        .join(', ');

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
