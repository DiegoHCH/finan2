import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_progress_card.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../savings_challenge/presentation/screens/savings_challenge_screen.dart';
import '../../data/savings_goal_model.dart';
import '../viewmodels/savings_goal_providers.dart';
import 'edit_savings_goal_screen.dart';
import 'savings_goal_detail_screen.dart';

const _goalIcons = <String, IconData>{
  'viaje': Icons.flight_outlined,
  'emergencia': Icons.shield_outlined,
  'casa': Icons.home_outlined,
  'estudio': Icons.school_outlined,
  'otro': Icons.card_giftcard_outlined,
};

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final totalSaved = ref.watch(totalSavedProvider);
    final formatMoney = ref.watch(moneyFormatterProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final now = DateTime.now();

    return Scaffold(
      floatingActionButton: goalsAsync.value?.isEmpty ?? true
          ? null
          : FloatingActionButton(
              heroTag: 'savingsGoalsFab',
              backgroundColor: colors.saving,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const EditSavingsGoalScreen())),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Metas de ahorro',
              title: formatMoney(totalSaved),
              household: household,
            ),
            Expanded(
              child: goalsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (goals) {
                  final falta = goals.fold<int>(
                    0,
                    (sum, g) =>
                        sum + (g.targetAmount - g.currentAmountAsOf(now)).clamp(0, g.targetAmount),
                  );

                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      if (goals.isNotEmpty) ...[
                        _Banner(
                          label: falta > 0
                              ? 'Total ahorrado · falta ${formatMoney(falta)}'
                              : 'Total ahorrado',
                          value: formatMoney(totalSaved),
                        ),
                        const SizedBox(height: Finan2Space.lg),
                      ],
                      if (goals.isEmpty)
                        Finan2EmptyState(
                          icon: Icons.savings_outlined,
                          title: 'Aún no tienes metas',
                          description:
                              'Crea una meta de ahorro para llevarle el pulso '
                              'con tu pareja.',
                          actionLabel: '+ Nueva meta',
                          onAction: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const EditSavingsGoalScreen()),
                          ),
                        )
                      else
                        for (final goal in goals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Finan2Space.md),
                            child: _GoalCard(
                              goal: goal,
                              formatMoney: formatMoney,
                              now: now,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SavingsGoalDetailScreen(goal: goal),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: Finan2Space.lg),
                      Finan2ListCard(
                        children: [
                          Finan2ListRow(
                            icon: Icons.emoji_events_outlined,
                            label: 'Reto de ahorro',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SavingsChallengeScreen(),
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

class _Banner extends StatelessWidget {
  const _Banner({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF9A6817), colors.saving],
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.formatMoney,
    required this.now,
    required this.onTap,
  });

  final SavingsGoal goal;
  final String Function(num) formatMoney;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final dateLabel = goal.targetDate == null ? 'sin fecha' : _monthYearLabel(goal.targetDate!);
    final current = goal.currentAmountAsOf(now);

    return Finan2ProgressCard(
      icon: _goalIcons[goal.iconSlug] ?? Icons.card_giftcard_outlined,
      iconBackground: colors.brandTint,
      iconColor: brand,
      title: goal.name,
      subtitle: 'Meta ${formatMoney(goal.targetAmount)} · $dateLabel',
      percentText: '${(goal.progressFractionAsOf(now) * 100).round()}%',
      percentColor: brand,
      progressFraction: goal.progressFractionAsOf(now),
      progressColor: brand,
      footLeft: '${formatMoney(goal.monthlyContribution)}/mes',
      footRight: 'Ahorrado ${formatMoney(current)}',
      onTap: onTap,
    );
  }
}

String _monthYearLabel(DateTime date) {
  final month = DateFormat('MMM').format(date).replaceAll('.', '');
  return '$month ${date.year}';
}
