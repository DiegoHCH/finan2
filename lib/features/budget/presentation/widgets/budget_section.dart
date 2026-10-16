import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_progress.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_tile.dart';
import '../../../../core/widgets/finan2_with_text_controller.dart';
import '../../../../l10n/l10n.dart';
import '../../../categories/data/category_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/budget_line.dart';
import '../../domain/budget_summary.dart';
import '../viewmodels/budget_providers.dart';

/// Plan · Presupuesto: what's left of each category's plan for [month] -
/// «lo que queda, no lo gastado». The month is chosen in Plan's header.
class BudgetSection extends ConsumerWidget {
  const BudgetSection({required this.month, super.key});

  final YearMonth month;

  Future<void> _copyPreviousMonth(BuildContext context, WidgetRef ref) async {
    await ref.read(budgetControllerProvider.notifier).copyPreviousMonth(month);
    final result = ref.read(budgetControllerProvider);
    if (result.hasError && context.mounted) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error!));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final view = ref.watch(budgetMonthViewProvider(month));
    final formatMoney = ref.watch(moneyFormatterProvider);
    final copying = ref.watch(budgetControllerProvider).isLoading;
    final summary = view.summary;
    final categoryById = {for (final c in view.rows) c.id: c};
    final over = overspentLines(view.lines);
    const gap = SizedBox(height: Finan2Space.lg);

    final planned = formatMoney(summary.totalPlanned);
    final summaryLine = switch (summary.bannerKind) {
      BudgetBannerKind.noIncome => l10n.budgetPlannedNoIncome(planned),
      BudgetBannerKind.overBudgeted => l10n.budgetPlannedOver(
        planned,
        formatMoney(summary.bannerAmount),
      ),
      BudgetBannerKind.remaining => l10n.budgetPlannedRemaining(
        planned,
        formatMoney(summary.bannerAmount),
      ),
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xl,
      ),
      children: [
        if (view.offerCopy) ...[
          Finan2Notice(
            icon: Icons.content_copy_rounded,
            title: l10n.budgetCopyTitle,
            message: l10n.budgetCopyMessage(
              view.previousMonthCategories,
              month.plusMonths(-1).monthLabel,
            ),
            actionLabel: copying ? l10n.budgetCopying : l10n.commonCopy,
            onTap: copying ? null : () => _copyPreviousMonth(context, ref),
          ),
          gap,
        ],
        if (over.isNotEmpty) ...[
          _OverNotice(over: over, categoryById: categoryById, formatMoney: formatMoney),
          gap,
        ],
        Finan2Sheet(
          children: [
            if (view.rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Finan2Space.md),
                child: Text(l10n.budgetEmpty, style: Theme.of(context).textTheme.bodyMedium),
              )
            else
              for (final (i, line) in view.lines.indexed)
                _BudgetLineRow(
                  category: view.rows[i],
                  line: line,
                  onTap: () => _editCategoryBudget(
                    context,
                    ref,
                    month,
                    view.rows[i],
                    view.budget[line.categoryId] ?? 0,
                  ),
                ),
          ],
        ),
        const SizedBox(height: Finan2Space.md),
        Text(
          summaryLine,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: colors.inkFaint,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (view.unbudgeted.isNotEmpty) ...[
          const SizedBox(height: Finan2Space.xs),
          Center(
            child: TextButton(
              onPressed: () => _pickCategoryToBudget(context, ref, month, view.unbudgeted),
              child: Text(l10n.budgetAddCategory),
            ),
          ),
        ],
      ],
    );
  }
}

/// The `.now.over` on top: the only place red shows unless a line is over.
class _OverNotice extends StatelessWidget {
  const _OverNotice({required this.over, required this.categoryById, required this.formatMoney});

  final List<BudgetLine> over;
  final Map<String, Category> categoryById;
  final String Function(num) formatMoney;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final worst = over.first;
    final category = categoryById[worst.categoryId];
    final name = category?.name ?? '?';
    final amount = formatMoney(-worst.left);
    return Finan2Notice(
      kind: Finan2NoticeKind.over,
      icon: category != null ? Finan2Icons.categoria(category.iconSlug) : Finan2Icons.alerta,
      title: over.length == 1
          ? l10n.budgetOverTitle(name, amount)
          : l10n.budgetOverManyTitle(over.length),
      message: over.length == 1 ? l10n.budgetOverMessage : l10n.budgetOverManyMessage(name, amount),
    );
  }
}

/// The `.bud` row: the category's tile and name (with what it carried in),
/// what's left on the right - red once over - the spent-of-plan line, and
/// the thin bar in the category's color.
class _BudgetLineRow extends ConsumerWidget {
  const _BudgetLineRow({required this.category, required this.line, required this.onTap});

  final Category category;
  final BudgetLine line;
  final VoidCallback onTap;

  static const _indent = 41.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final compact = ref.watch(compactMoneyFormatterProvider);
    final tone = Finan2Tone.of(context, Color(category.color));
    final state = line.state;

    final (String right, Color rightColor) = switch (state) {
      BudgetLineState.left => (l10n.budgetLeft(formatMoney(line.left)), colors.ink),
      BudgetLineState.complete => (l10n.budgetComplete, colors.ink),
      BudgetLineState.over => ('−${formatMoney(-line.left)}', colors.expense),
      BudgetLineState.unplanned => (l10n.budgetUnplanned, colors.inkFaint),
    };
    final meta = state == BudgetLineState.unplanned
        ? l10n.budgetSpentNoPlan(formatMoney(line.spent))
        : l10n.budgetSpentOf(formatMoney(line.spent), formatMoney(line.limit));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Finan2Tile(icon: Finan2Icons.categoria(category.iconSlug), tone: tone, size: 32),
                const SizedBox(width: 9),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                      if (line.carry != 0) ...[
                        const SizedBox(width: 6),
                        _CarryBadge(
                          text: line.carry > 0 ? '+${compact(line.carry)}' : compact(line.carry),
                          tooltip: line.carry > 0
                              ? l10n.budgetCarryIncluded(formatMoney(line.carry))
                              : l10n.budgetCarryDeducted(formatMoney(-line.carry)),
                          negative: line.carry < 0,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  right,
                  style: Finan2Type.money.copyWith(
                    fontSize: 13,
                    letterSpacing: 0,
                    color: rightColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: _indent, top: 2, bottom: 7),
              child: Text(
                meta,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.inkFaint,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: _indent),
              child: Finan2ProgressBar(fraction: line.fraction, color: tone.color),
            ),
          ],
        ),
      ),
    );
  }
}

/// The `.carry` label: what a rollover category brought from earlier
/// months, «+60k» - or what it owes, in red.
class _CarryBadge extends StatelessWidget {
  const _CarryBadge({required this.text, required this.tooltip, required this.negative});

  final String text;
  final String tooltip;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: negative ? colors.expenseTint : colors.brandTint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: Finan2Type.money.copyWith(
            fontSize: 10,
            letterSpacing: 0,
            color: negative ? colors.expense : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

Future<void> _editCategoryBudget(
  BuildContext context,
  WidgetRef ref,
  YearMonth month,
  Category category,
  int currentAmount,
) async {
  final currencySymbol = currencySymbolFor(ref.read(currentCurrencyProvider));
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Finan2WithTextController(
      initialText: currentAmount > 0 ? currentAmount.toString() : '',
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
              sheetContext.l10n.budgetForCategory(category.name),
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2AmountInput(
              controller: controller,
              autofocus: true,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: Finan2Space.lg),
            FilledButton(
              onPressed: () async {
                final amount = Finan2AmountInput.parse(controller.text) ?? 0;
                await ref
                    .read(budgetControllerProvider.notifier)
                    .setCategoryAmount(month, category.id, amount);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
              child: Text(sheetContext.l10n.commonSave),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pickCategoryToBudget(
  BuildContext context,
  WidgetRef ref,
  YearMonth month,
  List<Category> options,
) async {
  final selected = await showModalBottomSheet<Category>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final category in options)
              Finan2Chip(
                icon: Finan2Icons.categoria(category.iconSlug),
                label: category.name,
                selected: false,
                onTap: () => Navigator.of(sheetContext).pop(category),
              ),
          ],
        ),
      ),
    ),
  );
  if (selected != null && context.mounted) {
    await _editCategoryBudget(context, ref, month, selected, 0);
  }
}
