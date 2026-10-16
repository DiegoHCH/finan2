import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_progress.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../debts/domain/debt_plan.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../savings_challenge/domain/challenge_progress.dart';
import '../../../savings_challenge/presentation/screens/savings_challenge_screen.dart';
import '../../../savings_challenge/presentation/viewmodels/savings_challenge_providers.dart';
import '../../data/savings_goal_model.dart';
import '../../domain/goal_plan.dart';
import '../goal_style.dart';
import '../screens/edit_savings_goal_screen.dart';
import '../screens/savings_goal_detail_screen.dart';
import '../viewmodels/savings_goal_providers.dart';

/// Plan · Metas: what both have saved, then one ring per goal saying how
/// much is missing, the debts in one line, and the savings challenge.
class GoalsSection extends ConsumerWidget {
  const GoalsSection({this.onOpenDebts, super.key});

  /// Tapping the debts line - Plan switches to its Deudas segment.
  final VoidCallback? onOpenDebts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final l10n = context.l10n;

    return goalsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Finan2SkeletonList(top: Finan2SkeletonFigure(), rows: 3),
      error: (error, _) => Finan2AsyncErrorView(error: error),
      data: (goals) {
        if (goals.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Finan2EmptyState(
                  icon: Finan2Icons.metas,
                  tone: Finan2Tone.of(context, Finan2Palette.ahorro),
                  title: l10n.savingsGoalsEmptyTitle,
                  description: l10n.savingsGoalsEmptyDescription,
                  actionLabel: l10n.savingsGoalsEmptyAction,
                  onAction: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => const EditSavingsGoalScreen())),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(Finan2Space.lg, 0, Finan2Space.lg, Finan2Space.lg),
                child: _ChallengeLink(),
              ),
            ],
          );
        }
        return _GoalsList(goals: goals, onOpenDebts: onOpenDebts);
      },
    );
  }
}

class _GoalsList extends ConsumerWidget {
  const _GoalsList({required this.goals, required this.onOpenDebts});

  final List<SavingsGoal> goals;
  final VoidCallback? onOpenDebts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final totalSaved = ref.watch(totalSavedProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final now = DateTime.now();
    final onTime = goalsOnTime(goals.map((g) => g.onTrackAsOf(now)));
    final toGo = goals.fold<int>(
      0,
      (sum, g) => sum + (g.targetAmount - g.currentAmountAsOf(now)).clamp(0, g.targetAmount),
    );
    const gap = SizedBox(height: Finan2Space.lg);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xxl * 2,
      ),
      children: [
        Finan2Figure(
          label: (household?.members.length ?? 1) > 1
              ? l10n.goalsSavedTogether
              : l10n.savingsGoalsTotalSaved,
          amountText: formatMoney(totalSaved),
          fontSize: 38,
          subtitle: onTime.dated > 0
              ? Text(l10n.goalsOnTime(onTime.onTime, onTime.dated))
              : (toGo > 0 ? Text(l10n.goalsToGo(formatMoney(toGo))) : null),
        ),
        gap,
        Finan2Sheet(
          children: [
            for (final goal in goals)
              _GoalRow(
                goal: goal,
                color: goalTone(context, goals, goal.id).color,
                now: now,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => SavingsGoalDetailScreen(goal: goal)),
                ),
              ),
          ],
        ),
        _DebtsLine(onTap: onOpenDebts),
        const _ChallengeLink(),
      ],
    );
  }
}

/// A goal as `.row`: the ring in the goal's color, its name, and saved of
/// target with when - «va atrasada» in red, as a fact, not an alarm.
class _GoalRow extends ConsumerWidget {
  const _GoalRow({required this.goal, required this.color, required this.now, required this.onTap});

  final SavingsGoal goal;
  final Color color;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final compact = ref.watch(compactMoneyFormatterProvider);
    final fraction = goal.progressFractionAsOf(now);
    final saved = goal.currentAmountAsOf(now);
    final reached = saved >= goal.targetAmount && goal.targetAmount > 0;
    final onTrack = goal.onTrackAsOf(now);
    final date = goal.targetDate;
    final (String whenText, Color? whenColor) = switch ((reached, date, onTrack)) {
      (true, _, _) => (l10n.goalReached, colors.income),
      (_, null, _) => (l10n.savingsGoalsNoDate, null),
      (_, _, false) => (l10n.savingsGoalsBehind, colors.expense),
      (_, final date?, _) => (l10n.goalFor(goalDateLabel(date, now)), null),
    };
    final line = l10n.goalRowLine(compact(saved), compact(goal.targetAmount), whenText);
    final at = line.lastIndexOf(whenText);
    final style = TextStyle(
      fontSize: 11.5,
      color: colors.inkFaint,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Finan2Ring(fraction: fraction, color: color, label: '${(fraction * 100).floor()}%'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: line.substring(0, at)),
                        TextSpan(
                          text: whenText,
                          style: whenColor == null
                              ? null
                              : TextStyle(color: whenColor, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: line.substring(at + whenText.length)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
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

/// The debts in one sentence - «libres en marzo 2027» and the order - with
/// the detail one tap away.
class _DebtsLine extends ConsumerWidget {
  const _DebtsLine({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider).value ?? const [];
    final owed = avalancheOrder(debts).where((d) => d.balance > 0).toList();
    if (owed.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final freeDate = ref.watch(avalancheResultProvider).freeDate;
    return Padding(
      padding: const EdgeInsets.only(top: Finan2Space.lg),
      child: Finan2Notice(
        kind: Finan2NoticeKind.calm,
        icon: Icons.credit_card_outlined,
        title: freeDate == null
            ? l10n.goalsDebtsStuck
            : l10n.goalsDebtsFree(DateFormat('MMMM y').format(freeDate)),
        message: owed.length == 1
            ? l10n.goalsDebtsOnly(owed.first.name)
            : l10n.goalsDebtsOrder(owed[0].name, owed[1].name),
        actionLabel: onTap == null ? null : '›',
        onTap: onTap,
      ),
    );
  }
}

/// The way into the savings challenge, with how far along it is.
class _ChallengeLink extends ConsumerWidget {
  const _ChallengeLink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(savingsChallengeProvider).value;
    final progress = challenge == null
        ? null
        : challengeProgress(challenge.cellAmounts, challenge.done);
    return Padding(
      padding: const EdgeInsets.only(top: Finan2Space.lg),
      child: Finan2ListCard(
        children: [
          Finan2ListRow(
            icon: Icons.grid_view_rounded,
            label: context.l10n.savingsGoalsChallengeLink,
            value: progress == null ? null : '${progress.doneCount}/${progress.cellCount}',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const SavingsChallengeScreen())),
          ),
        ],
      ),
    );
  }
}
