import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_stat_box.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_goal_model.dart';
import '../viewmodels/savings_goal_providers.dart';
import 'edit_savings_goal_screen.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  const SavingsGoalDetailScreen({required this.goal, super.key});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final goals = ref.watch(savingsGoalsProvider).value ?? const <SavingsGoal>[];
    final current = goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);
    final now = DateTime.now();

    final currentAmount = current.currentAmountAsOf(now);
    final interestEarned = current.interestEarnedAsOf(now);
    final falta = (current.targetAmount - currentAmount).clamp(0, current.targetAmount);
    final onTrack = current.onTrackAsOf(now);
    final fraction = current.progressFractionAsOf(now);

    final sortedContributions = [...current.contributions]
      ..sort((a, b) => a.date.compareTo(b.date));
    var running = 0;
    final runningTotals = <int>[];
    for (final c in sortedContributions) {
      running += c.amount;
      runningTotals.add(running);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'savingsGoalDetailFab',
        backgroundColor: colors.saving,
        onPressed: () => _addContribution(context, ref, current.id),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2BackHead(
              title: current.name,
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined, size: 20, color: colors.inkSoft),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditSavingsGoalScreen(goal: current),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Container(
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
                          falta > 0
                              ? 'Ahorrado · falta ${formatMoney(falta)}'
                              : 'Ahorrado · meta cumplida',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatMoney(currentAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Finan2StatBox(
                          dense: true,
                          label: 'Aporte',
                          value: '${formatMoney(current.monthlyContribution)}/mes',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Finan2StatBox(
                          dense: true,
                          label: 'Interés ganado',
                          value: current.interestRate > 0
                              ? '+${formatMoney(interestEarned.round())}'
                              : '—',
                          valueColor: current.interestRate > 0 ? brand : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Finan2StatBox(
                          dense: true,
                          label: 'Falta',
                          value: formatMoney(falta),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${(fraction * 100).round()}% de ${formatMoney(current.targetAmount)}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  current.targetDate == null
                                      ? 'sin fecha'
                                      : 'meta ${_monthYearLabel(current.targetDate!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.inkFaint,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 9,
                            backgroundColor: colors.surfaceAlt,
                            valueColor: AlwaysStoppedAnimation(brand),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${formatMoney(current.monthlyContribution)}/mes',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.inkFaint,
                                  ),
                                ),
                              ),
                            ),
                            if (onTrack != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    onTrack ? 'a tiempo ✓' : 'atrasado',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: onTrack ? colors.income : colors.expense,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
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
                            'Aportes',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        if (sortedContributions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Aún no registras aportes.',
                              style: TextStyle(fontSize: 12, color: colors.inkSoft),
                            ),
                          )
                        else
                          for (var i = sortedContributions.length - 1; i >= 0; i--)
                            _ContributionRow(
                              contribution: sortedContributions[i],
                              runningTotal: runningTotals[i],
                              memberName:
                                  household?.memberInfo[sortedContributions[i].createdBy]
                                          ?.name ??
                                      '?',
                              memberIndex: household?.members.indexOf(
                                    sortedContributions[i].createdBy,
                                  ) ??
                                  0,
                              formatMoney: formatMoney,
                              showDivider: i > 0,
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

Future<void> _addContribution(BuildContext context, WidgetRef ref, String goalId) async {
  final controller = TextEditingController();
  final currencySymbol = currencySymbolFor(ref.read(currentCurrencyProvider));
  var submitting = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        Finan2Space.xl,
        Finan2Space.lg,
        Finan2Space.xl,
        MediaQuery.of(sheetContext).viewInsets.bottom + Finan2Space.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nuevo aporte', style: Theme.of(sheetContext).textTheme.titleMedium),
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
                        final amount = int.tryParse(controller.text) ?? 0;
                        if (amount > 0) {
                          await ref
                              .read(savingsGoalControllerProvider.notifier)
                              .addContribution(goalId, amount);
                        }
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      },
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              );
            },
          ),
        ],
      ),
    ),
  );
  controller.dispose();
}

class _ContributionRow extends StatelessWidget {
  const _ContributionRow({
    required this.contribution,
    required this.runningTotal,
    required this.memberName,
    required this.memberIndex,
    required this.formatMoney,
    required this.showDivider,
  });

  final Contribution contribution;
  final int runningTotal;
  final String memberName;
  final int memberIndex;
  final String Function(num) formatMoney;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: showDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: colors.line)))
          : null,
      child: Row(
        children: [
          Finan2Avatar(
            label: memberName.isEmpty ? '?' : memberName.substring(0, 1).toUpperCase(),
            memberIndex: memberIndex < 0 ? 0 : memberIndex,
            size: 20,
            borderWidth: 0,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aporte',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Total → ${formatMoney(runningTotal)}',
                  style: TextStyle(fontSize: 10.5, color: colors.inkFaint),
                ),
              ],
            ),
          ),
          Text(
            '+${formatMoney(contribution.amount)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: brand),
          ),
        ],
      ),
    );
  }
}

String _monthYearLabel(DateTime date) {
  final month = DateFormat('MMM', 'es').format(date).replaceAll('.', '');
  return '$month ${date.year}';
}
