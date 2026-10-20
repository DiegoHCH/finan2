import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_split.dart';
import '../../../../l10n/l10n.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../viewmodels/annual_summary_providers.dart';

/// Plan · año: what came in, went out and stayed, one bar per month - the
/// highest in violet with why it was high underneath, the months still to
/// come as gaps. Reached from Plan's header.
class AnnualSummaryScreen extends ConsumerStatefulWidget {
  const AnnualSummaryScreen({super.key});

  @override
  ConsumerState<AnnualSummaryScreen> createState() => _AnnualSummaryScreenState();
}

class _AnnualSummaryScreenState extends ConsumerState<AnnualSummaryScreen> {
  final _currentYear = DateTime.now().year;
  late var _year = _currentYear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final summary = ref.watch(annualSummaryProvider(_year));
    final compact = ref.watch(compactMoneyFormatterProvider);
    final startYear = ref.watch(currentHouseholdProvider).value?.startYear ?? _currentYear;
    // Three years at a time, ending one after the chosen year: picking the
    // oldest shown slides the window back, down to the household's start.
    final lastShown = (_year + 1).clamp(startYear, _currentYear);
    final years = [
      for (var y = lastShown - 2; y <= lastShown; y++)
        if (y >= startYear) y,
    ];
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final highest = summary.highestMonth;
    final reason = summary.highestReason;
    final reasonCategory = reason == null
        ? null
        : categories.where((c) => c.id == reason.categoryId).firstOrNull;
    const gap = SizedBox(height: Finan2Space.lg);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.coreHomeTabPlan,
              title: l10n.annualTitleYear(_year),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.xs,
                  Finan2Space.lg,
                  Finan2Space.xl,
                ),
                children: [
                  if (years.length > 1) ...[
                    Finan2SegmentedControl<int>(
                      options: {for (final y in years) y: '$y'},
                      selected: _year,
                      onChanged: (y) => setState(() => _year = y),
                    ),
                    gap,
                  ],
                  Finan2Split(
                    children: [
                      Finan2SplitBlock(
                        tone: Finan2Tone(colors.income, colors.incomeTint),
                        label: l10n.annualSummaryEarned,
                        value: compact(summary.ganado),
                        valueSize: 16,
                      ),
                      Finan2SplitBlock(
                        tone: Finan2Tone(colors.inkSoft, Theme.of(context).colorScheme.surface),
                        label: l10n.annualSummarySpent,
                        value: compact(summary.gastado),
                        valueSize: 16,
                      ),
                      Finan2SplitBlock(
                        tone: Finan2Tone(colors.saving, colors.savingTint),
                        label: l10n.annualSummarySaved,
                        value: compact(summary.ahorrado),
                        valueSize: 16,
                      ),
                    ],
                  ),
                  gap,
                  Container(
                    padding: const EdgeInsets.all(Finan2Space.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.annualSummarySpendByMonth,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            if (summary.average case final average?)
                              Text(
                                l10n.annualAverage(compact(average)),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _YearBars(summary: summary),
                      ],
                    ),
                  ),
                  if (highest != null) ...[
                    gap,
                    Finan2Notice(
                      kind: Finan2NoticeKind.calm,
                      icon: Finan2Icons.resumen,
                      title: l10n.annualHighestTitle(_monthName(highest)),
                      message: reason == null
                          ? null
                          : l10n.annualHighestReason(
                              reasonCategory?.name ?? '?',
                              compact(reason.extra),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The `.ybars`: one bar per month in Casa's color, the highest in the
/// accent, months without spending (or still to come) as a sunken stub.
class _YearBars extends StatelessWidget {
  const _YearBars({required this.summary});

  final AnnualSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final barColor = Finan2Tone.of(context, Finan2Palette.casa).color;
    final max = summary.gastoPorMes.fold(0, (m, v) => v > m ? v : m);
    const height = 120.0;
    const labelSpace = 17.0;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var month = 1; month <= 12; month++) ...[
            if (month > 1) const SizedBox(width: 5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: summary.hasData(month) && max > 0
                        ? ((height - labelSpace) * summary.gastoPorMes[month - 1] / max).clamp(
                            4.0,
                            height - labelSpace,
                          )
                        : (height - labelSpace) * 0.3,
                    decoration: BoxDecoration(
                      color: !summary.hasData(month)
                          ? colors.surfaceAlt
                          : (month == summary.highestMonth ? accent : barColor),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                        bottom: Radius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _monthInitial(month),
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.33,
                      fontWeight: FontWeight.w600,
                      color: colors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _monthName(int month) {
  final name = DateFormat.MMMM().format(DateTime(2000, month));
  return '${name[0].toUpperCase()}${name.substring(1)}';
}

String _monthInitial(int month) => _monthName(month)[0];
