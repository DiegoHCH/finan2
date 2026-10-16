import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_month_nav.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../l10n/l10n.dart';
import '../../../annual_summary/presentation/screens/annual_summary_screen.dart';
import '../../../budget/presentation/widgets/budget_section.dart';
import '../../../connection/presentation/widgets/offline_banner.dart';
import '../../../debts/presentation/screens/edit_debt_screen.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../debts/presentation/widgets/debts_section.dart';
import '../../../savings_goals/presentation/screens/edit_savings_goal_screen.dart';
import '../../../savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import '../../../savings_goals/presentation/widgets/goals_section.dart';

enum PlanSection { budget, goals, debts }

/// The «Plan» tab: the budget, the goals and the debts - the same plan seen
/// from three sides - under one segmented control, with the year's summary
/// one tap away in the header.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({this.initialSection = PlanSection.budget, super.key});

  final PlanSection initialSection;

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  late var _section = widget.initialSection;
  YearMonth _month = currentYearMonth();

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasGoals = ref.watch(savingsGoalsProvider).value?.isNotEmpty ?? false;
    final hasDebts = ref.watch(debtsProvider).value?.isNotEmpty ?? false;

    final (VoidCallback?, String?) add = switch (_section) {
      PlanSection.goals when hasGoals => (
        () => _open(const EditSavingsGoalScreen()),
        l10n.savingsGoalsNewTitle,
      ),
      PlanSection.debts when hasDebts => (() => _open(const EditDebtScreen()), l10n.debtsNewTitle),
      _ => (null, null),
    };

    return Scaffold(
      floatingActionButton: add.$1 == null
          ? null
          : FloatingActionButton(
              heroTag: 'planFab',
              tooltip: add.$2,
              onPressed: add.$1,
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              title: switch (_section) {
                PlanSection.budget => l10n.coreHomeTabPlan,
                PlanSection.goals => l10n.coreHomeTabGoals,
                PlanSection.debts => l10n.coreHomeTabDebts,
              },
              overLabel: _section == PlanSection.budget ? null : l10n.coreHomeTabPlan,
              over: _section != PlanSection.budget
                  ? null
                  : Finan2MonthNav(
                      label: _month.label,
                      previousTooltip: l10n.budgetPreviousMonth,
                      nextTooltip: l10n.budgetNextMonth,
                      onPrevious: () => setState(() => _month = _month.plusMonths(-1)),
                      onNext: () => setState(() => _month = _month.plusMonths(1)),
                      onReset: _month.isCurrent
                          ? null
                          : () => setState(() => _month = currentYearMonth()),
                    ),
              action: Finan2HeadAction(
                icon: Finan2Icons.resumen,
                tooltip: l10n.annualSummaryTitle,
                onTap: () => _open(const AnnualSummaryScreen()),
              ),
            ),
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(Finan2Space.lg, 0, Finan2Space.lg, Finan2Space.md),
              child: Finan2SegmentedControl<PlanSection>(
                options: {
                  PlanSection.budget: l10n.planBudget,
                  PlanSection.goals: l10n.coreHomeTabGoals,
                  PlanSection.debts: l10n.coreHomeTabDebts,
                },
                selected: _section,
                onChanged: (section) => setState(() => _section = section),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _section.index,
                children: [
                  BudgetSection(month: _month),
                  GoalsSection(onOpenDebts: () => setState(() => _section = PlanSection.debts)),
                  const DebtsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
