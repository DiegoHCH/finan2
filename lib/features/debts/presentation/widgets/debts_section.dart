import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_progress.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/debt_plan.dart';
import '../../domain/entities/debt.dart';
import '../debt_style.dart';
import '../screens/debt_detail_screen.dart';
import '../screens/edit_debt_screen.dart';
import '../viewmodels/debt_providers.dart';

/// Plan · Deudas: when they're over on top - a date, not a percentage -
/// then each debt in the Avalancha order with the ring of what's paid, and
/// the next payment due.
class DebtsSection extends ConsumerWidget {
  const DebtsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final l10n = context.l10n;

    return debtsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Finan2SkeletonList(top: Finan2SkeletonFigure(), rows: 3),
      error: (error, _) => Finan2AsyncErrorView(error: error),
      data: (debts) {
        if (debts.isEmpty) {
          return Finan2EmptyState(
            icon: Finan2Icons.check,
            title: l10n.debtsEmptyTitle,
            description: l10n.debtsEmptyDescription,
            actionLabel: l10n.debtsEmptyAction,
            celebrates: true,
            onAction: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const EditDebtScreen())),
          );
        }
        return _DebtsList(debts: debts);
      },
    );
  }
}

class _DebtsList extends ConsumerWidget {
  const _DebtsList({required this.debts});

  final List<Debt> debts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final total = ref.watch(totalDebtProvider);
    final avalanche = ref.watch(avalancheResultProvider);
    final freeDate = avalanche.freeDate;
    final ordered = avalancheOrder(debts);
    final firstOwed = ordered.where((d) => d.balance > 0).firstOrNull;
    final soonest = soonestPayment(debts, avalanche, DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xxl * 2,
      ),
      children: [
        Finan2Figure(
          label: freeDate != null ? l10n.debtsFreeDateLabel : l10n.debtsCurrentPaymentsLabel,
          amountText: freeDate != null
              ? DateFormat('MMMM y').format(freeDate)
              : l10n.debtsCannotPayOff,
          money: false,
          fontSize: freeDate != null ? 38 : 28,
          subtitle: Text(l10n.debtsLeftAvalanche(formatMoney(total))),
        ),
        const SizedBox(height: Finan2Space.lg),
        Finan2Sheet(
          children: [
            for (final debt in ordered)
              _DebtRow(
                debt: debt,
                color: debtTone(context, debts, debt.id).color,
                first: debt.id == firstOwed?.id && ordered.length > 1,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => DebtDetailScreen(debt: debt))),
              ),
          ],
        ),
        if (soonest != null) ...[
          const SizedBox(height: Finan2Space.lg),
          Finan2Notice(
            kind: Finan2NoticeKind.calm,
            icon: Icons.event_outlined,
            title: l10n.debtsNextTitle(
              soonest.debt.name,
              DateFormat('EEEE d').format(soonest.date),
            ),
            message: soonest.suggested > debtMinimum(soonest.debt)
                ? l10n.debtsNextMinSuggested(
                    formatMoney(debtMinimum(soonest.debt)),
                    formatMoney(soonest.suggested),
                  )
                : l10n.debtsNextMin(formatMoney(debtMinimum(soonest.debt))),
          ),
        ],
      ],
    );
  }
}

/// A debt as `.row`: the ring of what's paid in its color, the name (the
/// first of the Avalancha order with its «1.º»), rate · minimum · day, and
/// the balance.
class _DebtRow extends ConsumerWidget {
  const _DebtRow({
    required this.debt,
    required this.color,
    required this.first,
    required this.onTap,
  });

  final Debt debt;
  final Color color;
  final bool first;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final accent = Theme.of(context).colorScheme.primary;
    final rate = ratePercent(debt.rate);
    final sub = debt.balance <= 0
        ? l10n.debtsStatusPaidOff
        : debt.type.isCard
        ? l10n.debtsRowCard(rate, formatMoney(debt.minPayment), debt.paymentDay)
        : l10n.debtsRowLoan(rate, formatMoney(debt.monthlyPayment), debt.paymentDay);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Finan2Ring(
              fraction: debt.paidFraction,
              color: color,
              label: '${(debt.paidFraction * 100).floor()}%',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          debt.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                      if (first) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.brandTint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.debtsFirst,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.inkFaint,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatMoney(debt.balance),
              style: Finan2Type.money.copyWith(
                fontSize: 15,
                letterSpacing: -0.15,
                color: colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
