import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/investment_model.dart';
import '../viewmodels/investment_providers.dart';
import 'edit_investment_screen.dart';

const _investmentIcons = <InvestmentKind, IconData>{
  InvestmentKind.rentaFija: Icons.account_balance_outlined,
  InvestmentKind.rentaVariable: Icons.trending_up,
  InvestmentKind.cripto: Icons.currency_bitcoin,
};

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final investmentsAsync = ref.watch(investmentsProvider);
    final total = ref.watch(totalInvestmentValueProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final formatMoney = ref.watch(moneyFormatterProvider);

    return Scaffold(
      floatingActionButton: investmentsAsync.value?.isEmpty ?? true
          ? null
          : FloatingActionButton(
              heroTag: 'investmentsFab',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditInvestmentScreen()),
              ),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Inversiones',
              title: formatMoney(total),
              household: household,
              showBackButton: true,
            ),
            Expanded(
              child: investmentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (investments) {
                  if (investments.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.trending_up,
                      title: 'Aún no hay inversiones',
                      description:
                          'Agrega tu CDT, fondo o cripto para llevarle el pulso '
                          'a tu portafolio.',
                      actionLabel: '+ Nueva inversión',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditInvestmentScreen(),
                        ),
                      ),
                    );
                  }

                  final totalReturn = investments.fold<int>(
                    0,
                    (sum, i) => sum + i.returnAmount,
                  );

                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Finan2Space.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              colors.brandDeep,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valor del portafolio',
                              style: TextStyle(color: Colors.white, fontSize: 11.5),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatMoney(total),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  totalReturn >= 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${totalReturn >= 0 ? '+' : ''}${formatMoney(totalReturn)}',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      const TextSpan(text: ' de rendimiento total'),
                                    ],
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Finan2Space.lg),
                      for (final investment in investments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Finan2Space.md),
                          child: _InvestmentCard(
                            investment: investment,
                            formatMoney: formatMoney,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditInvestmentScreen(
                                  investment: investment,
                                ),
                              ),
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

class _InvestmentCard extends StatelessWidget {
  const _InvestmentCard({
    required this.investment,
    required this.formatMoney,
    required this.onTap,
  });

  final Investment investment;
  final String Function(num) formatMoney;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final isCripto = investment.kind == InvestmentKind.cripto;
    final accent = isCripto ? colors.expense : brand;
    final gain = investment.returnAmount >= 0;
    final gainColor = gain ? colors.income : colors.expense;

    final subtitle = investment.kind == InvestmentKind.rentaFija
        ? '${investment.kind.label} · ${_formatRate(investment.rate)}% E.A.'
        : investment.kind.label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Finan2Radius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: colors.line),
          borderRadius: BorderRadius.circular(Finan2Radius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isCripto ? colors.expense.withValues(alpha: 0.14) : colors.brandTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _investmentIcons[investment.kind] ?? Icons.trending_up,
                    size: 16,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: colors.inkFaint),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${gain ? '+' : ''}${formatMoney(investment.returnAmount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: gainColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor actual',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.inkFaint),
                ),
                Text(
                  formatMoney(investment.currentValue),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.inkFaint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRate(double rate) =>
    rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toString();
