import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_person_tag.dart';
import '../../../../core/widgets/finan2_progress.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_split.dart';
import '../../../../core/widgets/finan2_tile.dart';
import '../../../../core/widgets/finan2_with_text_controller.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../data/savings_goal_model.dart';
import '../../domain/goal_plan.dart';
import '../goal_style.dart';
import '../viewmodels/savings_goal_providers.dart';
import 'edit_savings_goal_screen.dart';

/// Metas · aportes: the big ring for how far along the goal is, whether
/// they're on time and at what monthly pace, what each one put in, and
/// every contribution.
class SavingsGoalDetailScreen extends ConsumerWidget {
  const SavingsGoalDetailScreen({required this.goal, super.key});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final memberLabel = ref.watch(memberLabelProvider);
    final goals = ref.watch(savingsGoalsProvider).value ?? const <SavingsGoal>[];
    final current = goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);
    final tone = goalTone(context, goals, current.id);
    final now = DateTime.now();
    final l10n = context.l10n;

    final saved = current.currentAmountAsOf(now);
    final fraction = current.progressFractionAsOf(now);
    final interest = current.interestEarnedAsOf(now).round();
    final date = current.targetDate;
    final when = date == null ? l10n.savingsGoalsNoDate : l10n.goalFor(goalDateLabel(date, now));
    final needed = monthlyNeeded(
      target: current.targetAmount,
      saved: saved,
      targetDate: date,
      now: now,
    );
    final onTrack = current.onTrackAsOf(now);
    final (String? pace, Color paceColor) = switch ((saved >= current.targetAmount, onTrack)) {
      (true, _) => (l10n.goalReached, colors.income),
      (_, true) => (l10n.goalOnTimePace(formatMoney(current.monthlyContribution)), colors.income),
      (_, false) => (l10n.goalBehindPace(formatMoney(needed ?? 0)), colors.expense),
      (_, null) =>
        current.monthlyContribution > 0
            ? (l10n.savingsGoalsPerMonth(formatMoney(current.monthlyContribution)), colors.inkSoft)
            : (null, colors.inkSoft),
    };

    final byMember = contributedBy(current.contributions.map((c) => (c.createdBy, c.amount)));
    final members = household?.members.take(2).toList() ?? const <String>[];
    final contributions = [...current.contributions]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: Finan2FormTop(
        title: current.name,
        backIcon: true,
        saveLabel: l10n.commonEdit,
        onSave: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => EditSavingsGoalScreen(goal: current))),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.md,
                  Finan2Space.lg,
                  Finan2Space.xl,
                ),
                children: [
                  Row(
                    children: [
                      Finan2Ring(
                        fraction: fraction,
                        color: tone.color,
                        label: '${(fraction * 100).floor()}%',
                        size: 76,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formatMoney(saved),
                                style: Finan2Type.money.copyWith(
                                  fontSize: 30,
                                  letterSpacing: -0.9,
                                  color: colors.ink,
                                ),
                              ),
                            ),
                            Text(
                              l10n.goalOfFor(formatMoney(current.targetAmount), when),
                              style: TextStyle(fontSize: 12.5, color: colors.inkSoft),
                            ),
                            if (pace != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  pace,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: paceColor,
                                  ),
                                ),
                              ),
                            if (interest > 0)
                              Text(
                                l10n.goalInterest(formatMoney(interest)),
                                style: TextStyle(fontSize: 11.5, color: colors.inkFaint),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (members.isNotEmpty) ...[
                    const SizedBox(height: Finan2Space.lg),
                    Finan2Split(
                      children: [
                        for (final (i, uid) in members.indexed)
                          Finan2SplitBlock(
                            tone: Finan2Tone.member(context, i),
                            label: memberLabel(uid).firstName,
                            value: formatMoney(byMember[uid] ?? 0),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: Finan2Space.xl),
                  Text(
                    l10n.savingsGoalsContributions,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  Finan2Sheet(
                    children: [
                      if (contributions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Finan2Space.md),
                          child: Text(
                            l10n.savingsGoalsNoContributions,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      else
                        for (final c in contributions)
                          _ContributionRow(
                            contribution: c,
                            tone: tone,
                            icon: goalIcon(current.iconSlug),
                            who: memberLabel(c.createdBy),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Finan2Space.lg,
                Finan2Space.sm,
                Finan2Space.lg,
                Finan2Space.lg,
              ),
              child: FilledButton(
                onPressed: () => _addContribution(context, ref, current.id),
                child: Text(l10n.savingsGoalsNewContribution),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionRow extends ConsumerWidget {
  const _ContributionRow({
    required this.contribution,
    required this.tone,
    required this.icon,
    required this.who,
  });

  final Contribution contribution;
  final Finan2Tone tone;
  final IconData icon;
  final MemberLabel who;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Finan2Tile(icon: icon, tone: tone),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.goalContributionOf(DateFormat.MMMM().format(contribution.date)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Finan2PersonTag(label: who.firstName, memberIndex: who.index),
                    Text(
                      ' · ${DateFormat.MMMd().format(contribution.date)}',
                      style: TextStyle(fontSize: 11.5, color: colors.inkFaint),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${formatMoney(contribution.amount)}',
            style: Finan2Type.money.copyWith(fontSize: 15, letterSpacing: -0.15, color: colors.ink),
          ),
        ],
      ),
    );
  }
}

Future<void> _addContribution(BuildContext context, WidgetRef ref, String goalId) async {
  final currencySymbol = currencySymbolFor(ref.read(currentCurrencyProvider));
  var submitting = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Finan2WithTextController(
      builder: (_, controller) => Padding(
        padding: EdgeInsets.fromLTRB(
          Finan2Space.xl,
          Finan2Space.lg,
          Finan2Space.xl,
          MediaQuery.of(sheetContext).viewInsets.bottom + Finan2Space.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sheetContext.l10n.savingsGoalsNewContribution,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2AmountInput(
              controller: controller,
              autofocus: true,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: Finan2Space.lg),
            StatefulBuilder(
              builder: (sheetContext, setSheetState) {
                return FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setSheetState(() => submitting = true);
                          final amount = Finan2AmountInput.parse(controller.text) ?? 0;
                          if (amount > 0) {
                            await ref
                                .read(savingsGoalControllerProvider.notifier)
                                .addContribution(goalId, amount);
                          }
                          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          final result = ref.read(savingsGoalControllerProvider);
                          if (result.hasError && context.mounted) {
                            await showFinan2ErrorSheet(
                              context,
                              message: friendlyErrorMessage(result.error!),
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(sheetContext.l10n.commonSave),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
