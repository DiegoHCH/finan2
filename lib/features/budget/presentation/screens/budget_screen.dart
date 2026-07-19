import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../transactions/presentation/viewmodels/transaction_providers.dart';
import '../../data/budget_summary.dart';
import '../viewmodels/budget_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final budget = ref.watch(currentMonthBudgetProvider).value ?? const {};
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final transactions = ref.watch(transactionsForMonthProvider).value ?? const [];
    final formatMoney = ref.watch(moneyFormatterProvider);

    final monthLabel = DateFormat.MMMM('es').format(DateTime.now());
    final monthLabelCap = '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}';

    final summary = computeBudgetSummary(budget: budget, transactions: transactions);
    final spendByCategory = summary.spendByCategory;

    final budgetable = categories.where((c) => c.type != CategoryType.ingreso).toList();
    final totalPlanned = summary.totalPlanned;

    final rows = budgetable
        .where((c) => summary.visibleCategoryIds.contains(c.id))
        .toList()
      ..sort(
        (a, b) => (spendByCategory[b.id] ?? 0).compareTo(spendByCategory[a.id] ?? 0),
      );
    final unbudgeted =
        budgetable.where((c) => !summary.visibleCategoryIds.contains(c.id)).toList();

    final pctAsignado = summary.pctAsignado;

    final String bannerLabel;
    final String bannerValue;
    switch (summary.bannerKind) {
      case BudgetBannerKind.noIncome:
        bannerLabel = 'Falta por presupuestar';
        bannerValue = 'Registra ingresos este mes';
      case BudgetBannerKind.overBudgeted:
        bannerLabel = 'Presupuestado de más';
        bannerValue = formatMoney(summary.bannerAmount);
      case BudgetBannerKind.remaining:
        bannerLabel = 'Falta por presupuestar';
        bannerValue = formatMoney(summary.bannerAmount);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Presupuesto · $monthLabelCap',
              title: '${formatMoney(totalPlanned)} planeado',
              trailing: pctAsignado != null
                  ? _Badge(text: '$pctAsignado% asignado')
                  : null,
              showBackButton: true,
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
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          colors.brandDeep,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bannerLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          bannerValue,
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
                          'Presupuesto vs. real',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        if (rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Aún no has presupuestado ninguna categoría.',
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
                                    formatMoney: formatMoney,
                                    onTap: () => _editCategoryBudget(
                                      context,
                                      ref,
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
                        onPressed: () => _pickCategoryToBudget(context, ref, unbudgeted),
                        child: const Text('+ Presupuestar otra categoría'),
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
  Category category,
  int currentAmount,
) async {
  final controller = TextEditingController(
    text: currentAmount > 0 ? currentAmount.toString() : '',
  );
  final currencySymbol = currencySymbolFor(ref.read(currentCurrencyProvider));
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
          Text(
            'Presupuesto para ${category.name}',
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
              final amount = int.tryParse(controller.text) ?? 0;
              await ref
                  .read(budgetControllerProvider.notifier)
                  .setCategoryAmount(category.id, amount);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
}

Future<void> _pickCategoryToBudget(
  BuildContext context,
  WidgetRef ref,
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
    await _editCategoryBudget(context, ref, selected, 0);
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
      decoration: BoxDecoration(
        color: colors.brandTint,
        borderRadius: BorderRadius.circular(999),
      ),
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
    required this.formatMoney,
    required this.onTap,
  });

  final Category category;
  final int real;
  final int planned;
  final String Function(num) formatMoney;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final over = planned > 0 && real > planned;
    final fraction = planned > 0 ? (real / planned).clamp(0.0, 1.0) : (real > 0 ? 1.0 : 0.0);
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
                            text: ' / ${formatMoney(planned)}',
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
