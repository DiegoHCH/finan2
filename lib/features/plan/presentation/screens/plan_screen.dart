import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../l10n/l10n.dart';
import '../../../debts/presentation/screens/debts_screen.dart';
import '../../../savings_goals/presentation/screens/savings_goals_screen.dart';

enum _PlanSection { goals, debts }

/// The «Plan» tab: savings goals and debts under one place (R3), since both
/// answer where the money is going. Each keeps its own screen below a
/// segmented control; R11 redraws them as one section.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  var _section = _PlanSection.goals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Finan2Space.xl, Finan2Space.sm, Finan2Space.xl, 0),
            child: Finan2SegmentedControl<_PlanSection>(
              options: {
                _PlanSection.goals: l10n.coreHomeTabGoals,
                _PlanSection.debts: l10n.coreHomeTabDebts,
              },
              selected: _section,
              onChanged: (section) => setState(() => _section = section),
            ),
          ),
        ),
        Expanded(
          // The control above already took the status bar.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: IndexedStack(
              index: _section.index,
              children: const [SavingsGoalsScreen(), DebtsScreen()],
            ),
          ),
        ),
      ],
    );
  }
}
