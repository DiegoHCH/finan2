import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/dev/mock_data_seeder.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final members = household.members;
    final categoryCount = ref.watch(categoriesProvider).value?.length ?? 0;
    final memberNames = members
        .map((uid) => household.memberInfo[uid]?.name ?? '?')
        .join(', ');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Finan2AppTop(label: 'Ajustes', title: 'Configuración'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(Finan2Radius.card),
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: household.inviteCode),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado')),
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
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await MockDataSeeder(ref).seed();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Datos de ejemplo cargados'),
                          ),
                        );
                      } catch (error) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Cargar datos de ejemplo'),
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
                    child: const Text('Cerrar sesión'),
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
