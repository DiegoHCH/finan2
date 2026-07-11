import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_stat_box.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/avalanche_calculator.dart';
import '../../data/debt_model.dart';
import '../viewmodels/debt_providers.dart';
import 'edit_debt_screen.dart';

class DebtDetailScreen extends ConsumerWidget {
  const DebtDetailScreen({required this.debt, super.key});

  final Debt debt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    final current = debts.firstWhere((d) => d.id == debt.id, orElse: () => debt);
    final avalanche = ref.watch(avalancheResultProvider);
    final schedule = avalanche.scheduleByDebtId[current.id] ?? const [];
    final accent = current.type.isCard ? colors.expense : colors.saving;

    final ratePct = current.rate == current.rate.roundToDouble()
        ? current.rate.toStringAsFixed(0)
        : current.rate.toStringAsFixed(1);

    final String statusText;
    if (current.balance <= 0) {
      statusText = 'deuda pagada';
    } else if (schedule.isNotEmpty && schedule.last.endingBalance <= 0) {
      final formatted = DateFormat.yMMMM('es').format(schedule.last.month);
      statusText = 'libre en ${formatted[0].toUpperCase()}${formatted.substring(1)}';
    } else {
      statusText = 'no alcanza a pagar con los abonos actuales';
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2BackHead(
              title: current.name,
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined, size: 20, color: colors.inkSoft),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditDebtScreen(debt: current),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Saldo actual',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.inkFaint,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatMoney(current.balance),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: colors.expense,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tasa $ratePct% E.A. · $statusText',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, color: colors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Row(
                    children: current.type.isCard
                        ? [
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: 'Pago mín.',
                                value: formatMoney(current.minPayment),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: 'Abono extra',
                                value: formatMoney(current.extraPayment),
                                valueColor: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: 'Pagado',
                                value: '${(current.paidFraction * 100).round()}%',
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: 'Cuota mensual',
                                value: formatMoney(current.monthlyPayment),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: 'Cuotas restantes',
                                value:
                                    '${(current.termMonths - current.paidInstallments).clamp(0, current.termMonths)}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: 'Pagado',
                                value: '${(current.paidFraction * 100).round()}%',
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Text(
                            'Calendario de pagos',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        if (schedule.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              current.balance <= 0
                                  ? 'Esta deuda ya está pagada.'
                                  : 'No hay una proyección disponible.',
                              style: TextStyle(fontSize: 12, color: colors.inkSoft),
                            ),
                          )
                        else
                          for (var i = 0; i < schedule.length.clamp(0, 6); i++)
                            _ScheduleRow(
                              entry: schedule[i],
                              paymentDay: current.paymentDay,
                              label: i == 0 ? 'Próximo pago' : 'Programado',
                              accent: accent,
                              showDivider: i < schedule.length.clamp(0, 6) - 1,
                            ),
                      ],
                    ),
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

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({
    required this.entry,
    required this.paymentDay,
    required this.label,
    required this.accent,
    required this.showDivider,
  });

  final DebtScheduleEntry entry;
  final int paymentDay;
  final String label;
  final Color accent;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: showDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: colors.line)))
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Text(
                  _monthAbbrev(entry.month),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: colors.inkFaint,
                  ),
                ),
                Text(
                  paymentDay.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Saldo → ${formatMoney(entry.endingBalance)}',
                  style: TextStyle(fontSize: 10.5, color: colors.inkFaint),
                ),
              ],
            ),
          ),
          Text(
            formatMoney(entry.payment),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

String _monthAbbrev(DateTime date) {
  final raw = DateFormat('MMM', 'es').format(date).replaceAll('.', '');
  return raw.isEmpty ? raw : '${raw[0].toUpperCase()}${raw.substring(1)}';
}
