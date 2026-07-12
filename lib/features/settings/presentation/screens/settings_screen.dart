import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pwa/pwa_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../annual_summary/presentation/screens/annual_summary_screen.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../budget/presentation/screens/budget_screen.dart';
import '../../../budget/presentation/viewmodels/budget_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../investments/presentation/screens/investments_screen.dart';
import '../../../investments/presentation/viewmodels/investment_providers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_providers.dart';
import 'account_settings_screen.dart';
import 'financial_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({required this.household, super.key});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final members = household.members;
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
                        icon: Icons.tune,
                        label: 'Ajustes financieros',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FinancialSettingsScreen(household: household),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.manage_accounts_outlined,
                        label: 'Ajustes de la cuenta',
                        value: 'Hogar y notificaciones',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AccountSettingsScreen(household: household),
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
