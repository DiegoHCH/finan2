import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pwa/pwa_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../annual_summary/presentation/screens/annual_summary_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart' show authErrorMessage;
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../budget/presentation/screens/budget_screen.dart';
import '../../../budget/presentation/viewmodels/budget_providers.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../investments/presentation/screens/investments_screen.dart';
import '../../../investments/presentation/viewmodels/investment_providers.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_providers.dart';

const _currencies = {'COP': 'Peso COP · \$', 'USD': 'Dólar USD · US\$'};
const _weekStarts = {'monday': 'Lunes', 'sunday': 'Domingo'};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({required this.household, super.key});

  final Household household;

  Future<void> _saveSettings(
    BuildContext context,
    WidgetRef ref, {
    String? currency,
    int? startYear,
    String? weekStartsOn,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(householdRepositoryProvider).updateSettings(
            household.id,
            currency: currency,
            startYear: startYear,
            weekStartsOn: weekStartsOn,
          );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> _pickFromOptions(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, String> options,
    required String current,
    required void Function(String value) onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in options.entries)
              ListTile(
                title: Text(entry.value),
                trailing:
                    entry.key == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _pickYear(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(household.startYear),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Selecciona el año activo',
    );
    if (picked != null && context.mounted) {
      await _saveSettings(context, ref, startYear: picked.year);
    }
  }

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
    final brand = Theme.of(context).colorScheme.primary;
    final members = household.members;
    final categoryCount = ref.watch(categoriesProvider).value?.length ?? 0;
    final memberNames = members
        .map((uid) => household.memberInfo[uid]?.name ?? '?')
        .join(', ');
    final formatMoney = ref.watch(moneyFormatterProvider);
    final totalPlanned = (ref.watch(currentMonthBudgetProvider).value ?? const {})
        .values
        .fold(0, (sum, v) => sum + v);
    final totalInvestments = ref.watch(totalInvestmentValueProvider);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Finan2AppTop(label: 'Ajustes', title: 'Configuración'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
                children: [
                  if (kIsWeb && ref.watch(persistentStorageStatusProvider) == false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Finan2Space.md),
                      child: Container(
                        padding: const EdgeInsets.all(Finan2Space.md),
                        decoration: BoxDecoration(
                          color: colors.savingTint,
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                          border: Border.all(color: colors.saving),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: colors.saving),
                            const SizedBox(width: Finan2Space.sm),
                            Expanded(
                              child: Text(
                                'Tu navegador no garantizó que los datos de Finan2 '
                                'se conserven. Si no abres la app por varios días, '
                                'podrías perder el acceso a los montos cifrados de '
                                'este dispositivo. Toca la tarjeta del hogar abajo '
                                'para copiar el código completo y guárdalo en un '
                                'lugar seguro.',
                                style: TextStyle(color: colors.ink, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(Finan2Radius.card),
                    onTap: () async {
                      final key = await ref
                          .read(householdCryptoProvider)
                          .exportKey(household.id);
                      final shareCode = key == null
                          ? household.inviteCode
                          : '${household.inviteCode}.$key';
                      await Clipboard.setData(ClipboardData(text: shareCode));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              key == null
                                  ? 'Código copiado (sin llave: este '
                                      'dispositivo no puede ver montos)'
                                  : 'Código copiado',
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Finan2Space.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [brand, colors.brandDeep],
                        ),
                        borderRadius: BorderRadius.circular(Finan2Radius.card),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: members.isEmpty
                                ? 0
                                : (30.0 + (members.length - 1) * 21),
                            height: 30,
                            child: Stack(
                              children: [
                                for (var i = 0; i < members.length; i++)
                                  Positioned(
                                    left: i * 21.0,
                                    child: Finan2Avatar(
                                      label: _initial(
                                        household.memberInfo[members[i]]?.name,
                                      ),
                                      memberIndex: i,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Finan2Space.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  household.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${members.length} miembro'
                                  '${members.length == 1 ? '' : 's'} · '
                                  'código ${household.inviteCode}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2ListCard(
                    children: [
                      Finan2ListRow(
                        icon: Finan2Icons.moneda,
                        label: 'Moneda',
                        value: _currencies[household.currency] ??
                            household.currency,
                        onTap: () => _pickFromOptions(
                          context,
                          ref,
                          options: _currencies,
                          current: household.currency,
                          onSelected: (value) =>
                              _saveSettings(context, ref, currency: value),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.anio,
                        label: 'Año activo',
                        value: '${household.startYear}',
                        onTap: () => _pickYear(context, ref),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.semana,
                        label: 'La semana inicia en',
                        value: _weekStarts[household.weekStartsOn] ??
                            household.weekStartsOn,
                        onTap: () => _pickFromOptions(
                          context,
                          ref,
                          options: _weekStarts,
                          current: household.weekStartsOn,
                          onSelected: (value) => _saveSettings(
                            context,
                            ref,
                            weekStartsOn: value,
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.categorias,
                        label: 'Categorías',
                        value: '$categoryCount',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CategoriesScreen(),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.cuentas,
                        label: 'Cuentas',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AccountsScreen(),
                          ),
                        ),
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
                        icon: Icons.ios_share_outlined,
                        label: 'Exportar reporte',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ExportScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2ListCard(
                    children: [
                      Finan2ListRow(
                        icon: Icons.donut_large_outlined,
                        label: 'Presupuesto',
                        value: '${formatMoney(totalPlanned)} planeado',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BudgetScreen()),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.bar_chart_outlined,
                        label: 'Resumen anual',
                        value: '${DateTime.now().year}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AnnualSummaryScreen(household: household),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.trending_up,
                        label: 'Inversiones',
                        value: formatMoney(totalInvestments),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InvestmentsScreen()),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.notifications_none_outlined,
                        label: 'Centro de notificaciones',
                        value: unreadNotifications > 0 ? '$unreadNotifications' : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
                    child: const Text('Cerrar sesión'),
                  ),
                  const SizedBox(height: Finan2Space.sm),
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
                  const SizedBox(height: Finan2Space.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initial(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  return name.trim().substring(0, 1).toUpperCase();
}
