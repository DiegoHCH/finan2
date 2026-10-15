import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_period_picker.dart';
import '../../../../core/widgets/finan2_stat_box.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../viewmodels/annual_summary_providers.dart';

/// "Resumen anual": the whole year at a glance - reached from Inicio, not
/// its own bottom-nav tab, matching the mockup (its nav always highlights
/// "Inicio"). The year's savings-goal card is left out on purpose: Metas
/// (Fase 5) doesn't exist yet to feed it, same call already made for the
/// Dashboard's patrimonio neto card.
class AnnualSummaryScreen extends ConsumerStatefulWidget {
  const AnnualSummaryScreen({required this.household, super.key});

  final Household household;

  @override
  ConsumerState<AnnualSummaryScreen> createState() => _AnnualSummaryScreenState();
}

class _AnnualSummaryScreenState extends ConsumerState<AnnualSummaryScreen> {
  final _currentYear = DateTime.now().year;
  late var _year = _currentYear;

  @override
  Widget build(BuildContext context) {
    final household = widget.household;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final summary = ref.watch(annualSummaryProvider(_year));
    final formatMoney = ref.watch(moneyFormatterProvider);
    final year = _year;
    // Only the current year has a month in progress to highlight.
    final currentMonthIndex = year == _currentYear ? DateTime.now().month - 1 : -1;
    final maxSpend = summary.gastoPorMes.fold(0, (m, v) => v > m ? v : m);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Resumen anual',
              title: '$year',
              household: household,
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Finan2PeriodPicker(
                    label: '$year',
                    previousTooltip: 'Año anterior',
                    nextTooltip: 'Año siguiente',
                    onPrevious: () => setState(() => _year--),
                    // Future years have nothing to show yet.
                    onNext: year >= _currentYear ? null : () => setState(() => _year++),
                    onReset: year == _currentYear
                        ? null
                        : () => setState(() => _year = _currentYear),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Finan2StatBox(
                          dense: true,
                          label: 'Ganado',
                          value: formatMoney(summary.ganado),
                          valueColor: colors.income,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Finan2StatBox(
                          dense: true,
                          label: 'Gastado',
                          value: formatMoney(summary.gastado),
                          valueColor: colors.expense,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Finan2StatBox(
                          dense: true,
                          label: 'Ahorrado',
                          value: formatMoney(summary.ahorrado),
                          valueColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Container(
                    padding: const EdgeInsets.all(Finan2Space.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gasto por mes',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 104,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < 12; i++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: i == 11 ? 0 : 4,
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                              widthFactor: 1,
                                              heightFactor: maxSpend == 0
                                                  ? 0.04
                                                  : (0.04 +
                                                          (summary.gastoPorMes[i] /
                                                                  maxSpend) *
                                                              0.96)
                                                      .clamp(0.04, 1.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: i == currentMonthIndex
                                                      ? colors.saving
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    topRight: Radius.circular(4),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _monthInitial(i + 1),
                                          style: TextStyle(
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.w600,
                                            color: colors.inkFaint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}

String _monthInitial(int month) {
  final name = DateFormat.MMMM('es').format(DateTime(2000, month));
  return name[0].toUpperCase();
}
