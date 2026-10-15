import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../categories/data/category_model.dart';
import '../../../debts/data/debt_model.dart';
import '../../../household/data/household_model.dart';
import '../../data/movement_filter.dart';

/// Search field plus the filter button that opens [_FilterSheet].
class MovementSearchBar extends StatelessWidget {
  const MovementSearchBar({
    required this.controller,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.categories,
    required this.accounts,
    required this.cards,
    required this.tags,
    required this.household,
    super.key,
  });

  final TextEditingController controller;
  final MovementFilter filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MovementFilter> onFilterChanged;
  final List<Category> categories;
  final List<Account> accounts;
  final List<Debt> cards;

  /// Tags in the movements being browsed, most used first.
  final List<String> tags;
  final Household? household;

  Future<void> _openFilters(BuildContext context) async {
    final picked = await showModalBottomSheet<MovementFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        initial: filter,
        categories: categories,
        accounts: accounts,
        cards: cards,
        tags: [...tags, if (filter.tag != null && !tags.contains(filter.tag)) filter.tag!],
        household: household,
      ),
    );
    if (picked != null) onFilterChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final count = filter.activeFilterCount;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Finan2Radius.field),
              border: Border.all(color: colors.line),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: colors.inkFaint),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onQueryChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: context.l10n.transactionsSearchHint,
                      hintStyle: TextStyle(fontSize: 13, color: colors.inkFaint),
                    ),
                  ),
                ),
                if (filter.hasQuery)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onQueryChanged('');
                    },
                    child: Icon(Icons.close, size: 18, color: colors.inkFaint),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Finan2Space.sm),
        IconButton(
          tooltip: context.l10n.transactionsFilters,
          onPressed: () => _openFilters(context),
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: Icon(
              Icons.tune,
              color: count > 0 ? Theme.of(context).colorScheme.primary : colors.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}

enum _Kind { ingreso, gasto, ahorro }

extension on _Kind {
  String label(AppLocalizations l10n) => switch (this) {
    _Kind.ingreso => l10n.categoriesTypeIncomePlural,
    _Kind.gasto => l10n.categoriesTypeExpensePlural,
    _Kind.ahorro => l10n.categoriesTypeSavingsPlural,
  };

  /// Gastos covers facturas too, like the movement form's segments.
  Set<CategoryType> get types => switch (this) {
    _Kind.ingreso => {CategoryType.ingreso},
    _Kind.gasto => {CategoryType.gasto, CategoryType.factura},
    _Kind.ahorro => {CategoryType.ahorro},
  };
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initial,
    required this.categories,
    required this.accounts,
    required this.cards,
    required this.tags,
    required this.household,
  });

  final MovementFilter initial;
  final List<Category> categories;
  final List<Account> accounts;
  final List<Debt> cards;
  final List<String> tags;
  final Household? household;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late var _filter = widget.initial;

  void _toggleKind(_Kind kind) {
    final types = {..._filter.types};
    if (types.containsAll(kind.types)) {
      types.removeAll(kind.types);
    } else {
      types.addAll(kind.types);
    }
    // A category of a type no longer shown would hide everything.
    final category = widget.categories.where((c) => c.id == _filter.categoryId).firstOrNull;
    final keepCategory = category == null || types.isEmpty || types.contains(category.type);
    setState(() {
      _filter = _filter.copyWith(types: types, categoryId: keepCategory ? null : () => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final l10n = context.l10n;
    final members = widget.household?.members ?? const <String>[];
    final visibleCategories = widget.categories
        .where((c) => _filter.types.isEmpty || _filter.types.contains(c.type))
        .toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.transactionsFilterTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Finan2Space.lg),
              Text(l10n.transactionsFilterType, style: labelStyle),
              const SizedBox(height: Finan2Space.sm),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final kind in _Kind.values)
                    Finan2Chip(
                      label: kind.label(l10n),
                      selected: _filter.types.containsAll(kind.types),
                      onTap: () => _toggleKind(kind),
                    ),
                ],
              ),
              const SizedBox(height: Finan2Space.lg),
              Text(l10n.commonCategory, style: labelStyle),
              const SizedBox(height: Finan2Space.sm),
              if (visibleCategories.isEmpty)
                Text(
                  l10n.transactionsFilterNoCategories,
                  style: TextStyle(fontSize: 12, color: colors.inkSoft),
                )
              else
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final category in visibleCategories)
                      Finan2Chip(
                        icon: Finan2Icons.categoria(category.iconSlug),
                        label: category.name,
                        selected: _filter.categoryId == category.id,
                        onTap: () => setState(() {
                          _filter = _filter.copyWith(
                            categoryId: () =>
                                _filter.categoryId == category.id ? null : category.id,
                          );
                        }),
                      ),
                  ],
                ),
              if (widget.accounts.length + widget.cards.length > 1) ...[
                const SizedBox(height: Finan2Space.lg),
                Text(l10n.commonAccount, style: labelStyle),
                const SizedBox(height: Finan2Space.sm),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final (id, name, icon) in [
                      for (final a in widget.accounts)
                        (a.id, a.name, Finan2Icons.cuenta(a.type.name)),
                      for (final c in widget.cards) (c.id, c.name, Icons.credit_card_outlined),
                    ])
                      Finan2Chip(
                        icon: icon,
                        label: name,
                        selected: _filter.sourceId == id,
                        onTap: () => setState(() {
                          _filter = _filter.copyWith(
                            sourceId: () => _filter.sourceId == id ? null : id,
                          );
                        }),
                      ),
                  ],
                ),
              ],
              if (widget.tags.isNotEmpty) ...[
                const SizedBox(height: Finan2Space.lg),
                Text(l10n.transactionsFilterTag, style: labelStyle),
                const SizedBox(height: Finan2Space.sm),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final tag in widget.tags)
                      Finan2Chip(
                        label: '#$tag',
                        selected: _filter.tag == tag,
                        onTap: () => setState(() {
                          _filter = _filter.copyWith(tag: () => _filter.tag == tag ? null : tag);
                        }),
                      ),
                  ],
                ),
              ],
              // Only worth asking once there's a partner to tell apart.
              if (members.length > 1) ...[
                const SizedBox(height: Finan2Space.lg),
                Text(l10n.transactionsPaidBy, style: labelStyle),
                const SizedBox(height: Finan2Space.sm),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final uid in members)
                      Finan2Chip(
                        label: widget.household?.memberInfo[uid]?.name ?? '?',
                        selected: _filter.payer == uid,
                        onTap: () => setState(() {
                          _filter = _filter.copyWith(
                            payer: () => _filter.payer == uid ? null : uid,
                          );
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: Finan2Space.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(_filter.withoutFilters()),
                      child: Text(l10n.transactionsFilterClear),
                    ),
                  ),
                  const SizedBox(width: Finan2Space.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_filter),
                      child: Text(l10n.transactionsFilterApply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
