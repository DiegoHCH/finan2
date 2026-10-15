import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_progress_card.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/debt_model.dart';
import '../debt_status_color.dart';
import '../viewmodels/debt_providers.dart';
import 'debt_detail_screen.dart';
import 'edit_debt_screen.dart';

const _debtTypeIcons = <DebtType, IconData>{
  DebtType.tarjeta: Icons.credit_card_outlined,
  DebtType.credito: Icons.account_balance_outlined,
  DebtType.hipoteca: Icons.home_outlined,
  DebtType.vehiculo: Icons.directions_car_outlined,
};

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final debtsAsync = ref.watch(debtsProvider);
    final total = ref.watch(totalDebtProvider);
    final formatMoney = ref.watch(moneyFormatterProvider);

    return Scaffold(
      floatingActionButton: debtsAsync.value?.isEmpty ?? true
          ? null
          : FloatingActionButton(
              heroTag: 'debtsFab',
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const EditDebtScreen())),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Deudas',
              title: formatMoney(total),
              trailing: debtsAsync.value?.isNotEmpty == true
                  ? _AvalancheBadge(colors: colors)
                  : null,
            ),
            Expanded(
              child: debtsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (debts) {
                  if (debts.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.celebration_outlined,
                      title: '¡Libres de deudas!',
                      description:
                          'No tienes deudas registradas. Si adquieres una, '
                          'agrégala para seguir su pago con la estrategia '
                          'Avalancha.',
                      actionLabel: '+ Agregar una deuda',
                      gold: true,
                      onAction: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (_) => const EditDebtScreen())),
                    );
                  }

                  final avalanche = ref.watch(avalancheResultProvider);

                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      _FreeDateBanner(freeDate: avalanche.freeDate),
                      const SizedBox(height: Finan2Space.lg),
                      for (final debt in debts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Finan2Space.md),
                          child: _DebtCard(
                            debt: debt,
                            formatMoney: formatMoney,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => DebtDetailScreen(debt: debt)),
                            ),
                          ),
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

class _AvalancheBadge extends StatelessWidget {
  const _AvalancheBadge({required this.colors});

  final Finan2Colors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: colors.brandTint, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 12, color: colors.brandDeep),
          const SizedBox(width: 4),
          Text(
            'Estrategia Avalancha',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: colors.brandDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeDateBanner extends StatelessWidget {
  const _FreeDateBanner({required this.freeDate});

  final DateTime? freeDate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final String label;
    final String value;
    if (freeDate != null) {
      final formatted = DateFormat.yMMMM('es').format(freeDate!);
      label = '¡Libre de deudas en!';
      value = '${formatted[0].toUpperCase()}${formatted.substring(1)}';
    } else {
      label = 'Con los pagos actuales';
      value = 'No alcanza a pagar';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.primary, colors.brandDeep],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt, required this.formatMoney, required this.onTap});

  final Debt debt;
  final String Function(num) formatMoney;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = debt.status.of(colors);
    final displayMinPayment = debt.type.isCard ? debt.minPayment : debt.monthlyPayment;
    final ratePct = debt.rate == debt.rate.roundToDouble()
        ? debt.rate.toStringAsFixed(0)
        : debt.rate.toStringAsFixed(1);

    return Finan2ProgressCard(
      icon: _debtTypeIcons[debt.type] ?? Icons.credit_card_outlined,
      iconBackground: accent.withValues(alpha: 0.14),
      iconColor: accent,
      title: debt.name,
      subtitle: 'Tasa $ratePct% · mín. ${formatMoney(displayMinPayment)}/mes',
      percentText: '${(debt.paidFraction * 100).round()}%',
      percentColor: accent,
      progressFraction: debt.paidFraction,
      progressColor: accent,
      footLeft: 'Pagado ${formatMoney(debt.paidAmount)}',
      footRight: 'Saldo ${formatMoney(debt.balance)}',
      onTap: onTap,
    );
  }
}
