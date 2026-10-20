import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../data/category_model.dart';
import '../../domain/category_use.dart';
import '../viewmodels/category_providers.dart';
import 'edit_category_screen.dart';

/// The kinds as the segmented control offers them: spending first, income
/// last.
const _typeOrder = [
  CategoryType.gasto,
  CategoryType.factura,
  CategoryType.ahorro,
  CategoryType.ingreso,
];

/// Categorías: each in the color it carries everywhere - the list, the
/// budget, the bar at Inicio - with how much it's used under it.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  var _type = CategoryType.gasto;

  void _open([Category? category]) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EditCategoryScreen(category: category, initialType: _type),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.categoriesTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
              action: Finan2HeadAction(
                icon: Finan2Icons.agregar,
                tooltip: l10n.categoriesNewTitle,
                filled: true,
                onTap: _open,
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (categories) {
                  if (categories.isEmpty) {
                    return Finan2EmptyState(
                      icon: Finan2Icons.categorias,
                      tone: Finan2Tone.of(context, Finan2Palette.mercado),
                      title: l10n.categoriesEmptyTitle,
                      description: l10n.categoriesEmptyDescription,
                      actionLabel: l10n.categoriesEmptyAction,
                      onAction: _open,
                    );
                  }
                  return _CategoriesList(
                    categories: categories.where((c) => c.type == _type).toList(),
                    type: _type,
                    onType: (type) => setState(() => _type = type),
                    open: _open,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesList extends ConsumerWidget {
  const _CategoriesList({
    required this.categories,
    required this.type,
    required this.onType,
    required this.open,
  });

  final List<Category> categories;
  final CategoryType type;
  final ValueChanged<CategoryType> onType;
  final ValueChanged<Category> open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uses = ref.watch(categoryUsesProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;

    String usage(Category category) {
      final use = uses[category.id] ?? CategoryUse.none;
      return [
        if (category.rollover && category.type != CategoryType.ingreso) l10n.categoriesRowRollover,
        l10n.categoriesRowUsage(use.movements),
        if (use.recurringBills > 0) l10n.categoriesUsageRecurringBills(use.recurringBills),
      ].join(' · ');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xxl,
      ),
      children: [
        Finan2SegmentedControl<CategoryType>(
          options: {for (final t in _typeOrder) t: t.plural},
          selected: type,
          onChanged: onType,
        ),
        const SizedBox(height: Finan2Space.md),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Finan2Space.xl),
            child: Text(
              l10n.categoriesNoneOfType,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.inkSoft),
            ),
          )
        else
          Finan2Sheet(
            children: [
              for (final category in categories)
                Finan2TransactionRow(
                  key: ValueKey(category.id),
                  icon: Finan2Icons.categoria(category.iconSlug),
                  iconColor: Color(category.color),
                  description: category.name,
                  subLabel: usage(category),
                  amountText: '',
                  amountColor: colors.ink,
                  onTap: () => open(category),
                ),
            ],
          ),
      ],
    );
  }
}
