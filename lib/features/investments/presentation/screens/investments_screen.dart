import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../core/widgets/finan2_tile.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/investment_model.dart';
import '../../domain/portfolio.dart';
import '../viewmodels/investment_providers.dart';
import 'edit_investment_screen.dart';

const _kindIcons = <InvestmentKind, IconData>{
  InvestmentKind.rentaFija: Icons.account_balance_outlined,
  InvestmentKind.rentaVariable: Icons.trending_up,
  InvestmentKind.cripto: Icons.toll_outlined,
};

const _kindColors = <InvestmentKind, Color>{
  InvestmentKind.rentaFija: Finan2Palette.fixedIncome,
  InvestmentKind.rentaVariable: Finan2Palette.variableIncome,
  InvestmentKind.cripto: Finan2Palette.highRisk,
};

/// Inversiones: what they're worth today, what went in, and the gain or the
/// loss said in pesos - color only on that figure, no arrows and no market
/// percentages. A note says the values are the ones they type in.
class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentsProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.investmentsTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
              action: Finan2HeadAction(
                icon: Finan2Icons.agregar,
                tooltip: l10n.investmentsAdd,
                filled: true,
                onTap: () => _open(context, const EditInvestmentScreen()),
              ),
            ),
            Expanded(
              child: investmentsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(top: Finan2SkeletonFigure()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (investments) {
                  if (investments.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.trending_up,
                      tone: Finan2Tone.of(context, Finan2Palette.ahorro),
                      title: l10n.investmentsEmptyTitle,
                      description: l10n.investmentsEmptyDescription,
                      actionLabel: l10n.investmentsEmptyAction,
                      onAction: () => _open(context, const EditInvestmentScreen()),
                    );
                  }
                  return _InvestmentsList(
                    investments: investments,
                    open: (investment) =>
                        _open(context, EditInvestmentScreen(investment: investment)),
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

class _InvestmentsList extends ConsumerWidget {
  const _InvestmentsList({required this.investments, required this.open});

  final List<Investment> investments;
  final ValueChanged<Investment> open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final totals = portfolioTotals([
      for (final i in investments) (invested: i.investedAmount, value: i.currentValue),
    ]);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xxl,
      ),
      children: [
        Finan2Figure(
          label: l10n.investmentsWorthToday,
          amountText: formatMoney(totals.value),
          fontSize: 38,
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n.investmentsPutIn(formatMoney(totals.invested))),
                if (totals.gain != 0) ...[
                  TextSpan(
                    text:
                        ' · ${totals.gain > 0 ? l10n.investmentsGaining : l10n.investmentsLosing} ',
                  ),
                  TextSpan(
                    text: formatMoney(totals.gain.abs()),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: totals.gain > 0 ? colors.income : colors.expense,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Finan2Space.lg),
        Finan2Sheet(
          children: [
            for (final investment in investments)
              _InvestmentRow(investment: investment, onTap: () => open(investment)),
          ],
        ),
        const SizedBox(height: Finan2Space.md),
        Text(
          l10n.investmentsManualNote,
          style: TextStyle(fontSize: 12, height: 1.5, color: colors.inkFaint),
        ),
      ],
    );
  }
}

/// An investment as `.row`: its kind's tile, the name, the kind (with the
/// rate for fixed income) and the gain or loss in pesos in its color, and
/// what it's worth today.
class _InvestmentRow extends ConsumerWidget {
  const _InvestmentRow({required this.investment, required this.onTap});

  final Investment investment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final gain = investment.returnAmount;
    final kind = investment.kind == InvestmentKind.rentaFija && investment.rate > 0
        ? l10n.investmentsKindWithRate(investment.kind.label, _ratePercent(investment.rate))
        : investment.kind.label;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Finan2Tile(
              icon: _kindIcons[investment.kind]!,
              tone: Finan2Tone.of(context, _kindColors[investment.kind]!),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: kind),
                        if (gain != 0) ...[
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: '${gain > 0 ? '+' : '−'}${formatMoney(gain.abs())}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: gain > 0 ? colors.income : colors.expense,
                            ),
                          ),
                        ],
                      ],
                    ),
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
              formatMoney(investment.currentValue),
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

/// «12» or «12,5»-style rate text without trailing zeros.
String _ratePercent(double rate) =>
    rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toStringAsFixed(1);
