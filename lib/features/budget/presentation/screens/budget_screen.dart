import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_with_text_controller.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_period_picker.dart';
import '../../../../l10n/l10n.dart';
import '../../../categories/data/category_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/budget_summary.dart';
import '../viewmodels/budget_providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  YearMonth _month = currentYearMonth();

  Future<void> _copyPreviousMonth() async {
    await ref.read(budgetControllerProvider.notifier).copyPreviousMonth(_month);
    final result = ref.read(budgetControllerProvider);
    if (result.hasError && mounted) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final view = ref.watch(budgetMonthViewProvider(_month));
    final formatMoney = ref.watch(moneyFormatterProvider);
    final copying = ref.watch(budgetControllerProvider).isLoading;

    final monthLabelCap = _month.monthLabel;
    final previousMonthLabel = _month.plusMonths(-1).monthLabel;
    final budget = view.budget;
    final summary = view.summary;
    final spendByCategory = summary.spendByCategory;
    final carryOver = view.carryOver;
    final rows = view.rows;
    final unbudgeted = view.unbudgeted;
    final totalPlanned = summary.totalPlanned;

    final pctAsignado = summary.pctAsignado;
    final l10n = context.l10n;

    final String bannerLabel;
    final String bannerValue;
    switch (summary.bannerKind) {
      case BudgetBannerKind.noIncome:
        bannerLabel = l10n.budgetLeftToBudget;
        bannerValue = l10n.budgetNoIncomeYet;
      case BudgetBannerKind.overBudgeted:
        bannerLabel = l10n.budgetOverBudgeted;
        bannerValue = formatMoney(summary.bannerAmount);
      case BudgetBannerKind.remaining:
        bannerLabel = l10n.budgetLeftToBudget;
        bannerValue = formatMoney(summary.bannerAmount);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: l10n.budgetTitle(monthLabelCap),
              title: l10n.budgetPlannedTotal(formatMoney(totalPlanned)),
              trailing: pctAsignado != null
                  ? _Badge(text: l10n.budgetAssignedPct(pctAsignado))
                  : null,
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Finan2PeriodPicker(
                    label: _month.label,
                    previousTooltip: l10n.budgetPreviousMonth,
                    nextTooltip: l10n.budgetNextMonth,
                    onPrevious: () => setState(() => _month = _month.plusMonths(-1)),
                    onNext: () => setState(() => _month = _month.plusMonths(1)),
                    onReset: _month.isCurrent
                        ? null
                        : () => setState(() => _month = currentYearMonth()),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  if (view.offerCopy) ...[
                    _CopyBudgetCard(
                      fromLabel: previousMonthLabel,
                      categories: view.previousMonthCategories,
                      busy: copying,
                      onCopy: _copyPreviousMonth,
                    ),
                    const SizedBox(height: Finan2Space.lg),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.heroStart, colors.heroEnd],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bannerLabel,
                          style: TextStyle(
                            color: colors.onHero,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          bannerValue,
                          style: TextStyle(
                            color: colors.onHero,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
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
                        Text(
                          l10n.budgetVsActual,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        if (rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              l10n.budgetEmpty,
                              style: TextStyle(fontSize: 12, color: colors.inkSoft),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: [
                                for (final category in rows)
                                  _BudgetRow(
                                    category: category,
                                    real: spendByCategory[category.id] ?? 0,
                                    planned: budget[category.id] ?? 0,
                                    carry: carryOver[category.id] ?? 0,
                                    formatMoney: formatMoney,
                                    onTap: () => _editCategoryBudget(
                                      context,
                                      ref,
                                      _month,
                                      category,
                                      budget[category.id] ?? 0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (unbudgeted.isNotEmpty) ...[
                    const SizedBox(height: Finan2Space.md),
                    Center(
                      child: TextButton(
                        onPressed: () => _pickCategoryToBudget(context, ref, _month, unbudgeted),
                        child: Text(l10n.budgetAddCategory),
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

/// Shown on a month with no budget yet when the one before has one.
class _CopyBudgetCard extends StatelessWidget {
  const _CopyBudgetCard({
    required this.fromLabel,
    required this.categories,
    required this.busy,
    required this.onCopy,
  });

  final String fromLabel;
  final int categories;
  final bool busy;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.all(Finan2Space.md),
      decoration: BoxDecoration(
        color: colors.brandTint,
        borderRadius: BorderRadius.circular(Finan2Radius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.budgetCopyTitle,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.budgetCopyMessage(categories, fromLabel),
                  style: TextStyle(fontSize: 12, color: colors.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: Finan2Space.md),
          FilledButton(
            onPressed: busy ? null : onCopy,
            child: Text(busy ? context.l10n.budgetCopying : context.l10n.commonCopy),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: colors.brandTint, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: colors.brandDeep,
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.category,
    required this.real,
    required this.planned,
    required this.carry,
    required this.formatMoney,
    required this.onTap,
  });

  final Category category;
  final int real;

  /// This month's own budget, before [carry].
  final int planned;

  /// Brought in from earlier months: + left over, - overspent.
  final int carry;
  final String Function(num) formatMoney;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final limit = planned + carry;
    // Spending with no budget at all isn't "over" anything, as before; a
    // limit eaten by earlier overspending is.
    final over = (planned > 0 || carry != 0) && real > limit;
    final fraction = limit > 0 ? (real / limit).clamp(0.0, 1.0) : (real > 0 ? 1.0 : 0.0);
    final barColor = over ? colors.expense : Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Finan2Icons.categoria(category.iconSlug),
                        size: 14,
                        color: colors.inkSoft,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            category.name,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatMoney(real),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: over ? colors.expense : colors.ink,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${formatMoney(limit)}',
                            style: TextStyle(fontWeight: FontWeight.w600, color: colors.inkFaint),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ),
              ],
            ),
            if (carry != 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  carry > 0
                      ? context.l10n.budgetCarryIncluded(formatMoney(carry))
                      : context.l10n.budgetCarryDeducted(formatMoney(-carry)),
                  style: TextStyle(fontSize: 11, color: carry > 0 ? colors.income : colors.expense),
                ),
              ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 9,
                backgroundColor: colors.surfaceAlt,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
