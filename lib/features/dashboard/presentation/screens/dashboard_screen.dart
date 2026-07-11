import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_stat_box.dart';
import '../../../annual_summary/presentation/screens/annual_summary_screen.dart';
import '../../../budget/presentation/screens/budget_screen.dart';
import '../../../budget/presentation/viewmodels/budget_providers.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../investments/presentation/screens/investments_screen.dart';
import '../../../investments/presentation/viewmodels/investment_providers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_providers.dart';
import '../../../transactions/presentation/screens/edit_transaction_screen.dart';
import '../../../transactions/presentation/viewmodels/transaction_providers.dart';

/// "Inicio": the household's pulse for the current month - income vs.
/// expenses and where the money is going by category. Patrimonio neto is
/// deliberately left out until Deudas/Ahorros (Fase 4/5) exist to feed it.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.household, super.key});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final transactionsAsync = ref.watch(transactionsForMonthProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final formatMoney = ref.watch(moneyFormatterProvider);
    final categoryById = {for (final c in categories) c.id: c};
    final totalPlanned = (ref.watch(currentMonthBudgetProvider).value ?? const {})
        .values
        .fold(0, (sum, v) => sum + v);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final totalInvestments = ref.watch(totalInvestmentValueProvider);

    final monthLabel = DateFormat.MMMM('es').format(DateTime.now());
    final monthLabelCap = '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Hogar',
              title: household.name,
              household: household,
            ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'Aún no hay movimientos',
                      description:
                          'Registra ingresos y gastos en Movimientos para ver '
                          'aquí el resumen del mes.',
                      actionLabel: '+ Agregar el primero',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditTransactionScreen(),
                        ),
                      ),
                    );
                  }

                  var income = 0;
                  var expense = 0;
                  final byCategory = <String, int>{};
                  for (final tx in transactions) {
                    if (tx.isIncome) {
                      income += tx.amount;
                    } else {
                      expense += tx.amount;
                      byCategory[tx.categoryId] =
                          (byCategory[tx.categoryId] ?? 0) + tx.amount;
                    }
                  }
                  final topCategories = byCategory.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final shown = topCategories.take(4).toList();
                  final maxAmount =
                      shown.isEmpty ? 1 : shown.first.value;

                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Finan2StatBox(
                              dotColor: colors.income,
                              label: 'Ingresos',
                              value: formatMoney(income),
                              valueColor: colors.income,
                            ),
                          ),
                          const SizedBox(width: Finan2Space.sm),
                          Expanded(
                            child: Finan2StatBox(
                              dotColor: colors.expense,
                              label: 'Gastos',
                              value: formatMoney(expense),
                              valueColor: colors.expense,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Finan2Space.lg),
                      Container(
                        padding: const EdgeInsets.all(Finan2Space.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: colors.line),
                          borderRadius:
                              BorderRadius.circular(Finan2Radius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'A dónde va el dinero',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  monthLabelCap,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.inkFaint,
                                  ),
                                ),
                              ],
                            ),
                            if (shown.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'No hay gastos categorizados este mes.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.inkSoft,
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  children: [
                                    for (final entry in shown)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 9),
                                        child: _CategoryBar(
                                          name: categoryById[entry.key]
                                                  ?.name ??
                                              '?',
                                          amountText: formatMoney(entry.value),
                                          fraction: entry.value / maxAmount,
                                          color: categoryById[entry.key] !=
                                                  null
                                              ? Color(
                                                  categoryById[entry.key]!
                                                      .color,
                                                )
                                              : colors.inkSoft,
                                          trackColor: colors.surfaceAlt,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Finan2Space.lg),
                      Finan2ListCard(
                        children: [
                          Finan2ListRow(
                            icon: Icons.donut_large_outlined,
                            label: 'Presupuesto',
                            value: '${formatMoney(totalPlanned)} planeado',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BudgetScreen(),
                              ),
                            ),
                          ),
                          Finan2ListRow(
                            icon: Icons.bar_chart_outlined,
                            label: 'Resumen anual',
                            value: '${DateTime.now().year}',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AnnualSummaryScreen(household: household),
                              ),
                            ),
                          ),
                          Finan2ListRow(
                            icon: Icons.notifications_outlined,
                            label: 'Notificaciones',
                            value: unreadNotifications > 0 ? '$unreadNotifications' : null,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                          ),
                          Finan2ListRow(
                            icon: Icons.trending_up,
                            label: 'Inversiones',
                            value: formatMoney(totalInvestments),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const InvestmentsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.name,
    required this.amountText,
    required this.fraction,
    required this.color,
    required this.trackColor,
  });

  final String name;
  final String amountText;
  final double fraction;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).extension<Finan2Colors>()!.inkSoft,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          amountText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).extension<Finan2Colors>()!.inkFaint,
          ),
        ),
      ],
    );
  }
}
