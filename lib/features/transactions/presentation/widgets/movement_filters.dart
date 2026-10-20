import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_section_label.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../categories/data/category_model.dart';
import '../../../debts/domain/entities/debt.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../domain/entities/movement.dart';
import '../../domain/movement_filter.dart';

/// What the filters can pick from: the household's categories, accounts,
/// cards, tags and members.
class MovementFilterOptions {
  const MovementFilterOptions({
    required this.categories,
    required this.accounts,
    required this.cards,
    required this.tags,
    required this.members,
    required this.memberLabel,
  });

  final List<Category> categories;
  final List<Account> accounts;
  final List<Debt> cards;

  /// Tags in the movements being browsed, most used first.
  final List<String> tags;
  final List<String> members;
  final MemberLabel Function(String uid) memberLabel;

  Map<String, String> get categoryNames => {for (final c in categories) c.id: c.name};
}

/// The search field, always in sight (`.field` with a magnifier).
class MovementSearchField extends StatelessWidget {
  const MovementSearchField({required this.controller, required this.onChanged, super.key});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Finan2Radius.field),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: colors.inkFaint),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: colors.ink),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: context.l10n.transactionsSearchHint,
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: colors.inkFaint,
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => controller.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: Icon(Icons.close, size: 18, color: colors.inkFaint),
                  ),
          ),
        ],
      ),
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

  /// Gastos covers facturas too, like Anotar's segments.
  Set<CategoryType> get types => switch (this) {
    _Kind.ingreso => {CategoryType.ingreso},
    _Kind.gasto => {CategoryType.gasto, CategoryType.factura},
    _Kind.ahorro => {CategoryType.ahorro},
  };
}

/// Every active filter as a chip in its own color - the category's, the
/// member's - that comes off with its ✕. With a search typed, «Todo 2026»
/// widens it to the year.
class MovementFilterChips extends StatelessWidget {
  const MovementFilterChips({
    required this.filter,
    required this.options,
    required this.onFilterChanged,
    required this.year,
    required this.wholeYear,
    required this.onWholeYearChanged,
    super.key,
  });

  final MovementFilter filter;
  final MovementFilterOptions options;
  final ValueChanged<MovementFilter> onFilterChanged;
  final int year;
  final bool wholeYear;
  final ValueChanged<bool> onWholeYearChanged;

  /// Whether there's anything to show at all.
  static bool hasChips(MovementFilter filter) => !filter.isEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = options.categories.where((c) => c.id == filter.categoryId).firstOrNull;
    final account = options.accounts.where((a) => a.id == filter.sourceId).firstOrNull;
    final card = options.cards.where((c) => c.id == filter.sourceId).firstOrNull;
    final payer = filter.payer == null ? null : options.memberLabel(filter.payer!);

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final kind in _Kind.values)
          if (filter.types.isNotEmpty && filter.types.containsAll(kind.types))
            Finan2Chip(
              label: kind.label(l10n),
              selected: true,
              removable: true,
              onTap: () =>
                  onFilterChanged(filter.copyWith(types: {...filter.types}..removeAll(kind.types))),
            ),
        if (filter.categoryId != null)
          Finan2Chip(
            icon: category == null ? null : Finan2Icons.categoria(category.iconSlug),
            label: category?.name ?? '?',
            tone: category == null ? null : Finan2Tone.of(context, Color(category.color)),
            selected: true,
            removable: true,
            onTap: () => onFilterChanged(filter.copyWith(categoryId: () => null)),
          ),
        if (filter.sourceId != null)
          Finan2Chip(
            icon: card != null
                ? Icons.credit_card_outlined
                : Finan2Icons.cuenta(account?.type.name ?? 'banco'),
            label: card?.name ?? account?.name ?? '?',
            selected: true,
            removable: true,
            onTap: () => onFilterChanged(filter.copyWith(sourceId: () => null)),
          ),
        if (payer != null)
          Finan2Chip(
            label: l10n.transactionsPaidByChip(payer.firstName),
            tone: Finan2Tone.member(context, payer.index),
            selected: true,
            removable: true,
            onTap: () => onFilterChanged(filter.copyWith(payer: () => null)),
          ),
        if (filter.tag != null)
          Finan2Chip(
            label: '#${filter.tag}',
            selected: true,
            removable: true,
            onTap: () => onFilterChanged(filter.copyWith(tag: () => null)),
          ),
        if (filter.hasQuery)
          Finan2Chip(
            key: const Key('movementsWholeYear'),
            icon: Icons.calendar_month_outlined,
            label: l10n.transactionsSearchWholeYear(year),
            selected: wholeYear,
            onTap: () => onWholeYearChanged(!wholeYear),
          ),
      ],
    );
  }
}

/// «Una hoja, cinco preguntas»: tipo, categoría, cuenta, etiqueta y quién
/// pagó. Returns the filter to apply, or null if dismissed. [movements] are
/// the ones being browsed, to say how many «Ver N» would show.
Future<MovementFilter?> showMovementFilterSheet(
  BuildContext context, {
  required MovementFilter initial,
  required MovementFilterOptions options,
  required List<Movement> movements,
}) {
  return showModalBottomSheet<MovementFilter>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FilterSheet(initial: initial, options: options, movements: movements),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.options, required this.movements});

  final MovementFilter initial;
  final MovementFilterOptions options;
  final List<Movement> movements;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late var _filter = widget.initial;

  /// The «Los dos» option of the payer control.
  static const _both = '';

  void _toggleKind(_Kind kind) {
    final types = {..._filter.types};
    if (types.containsAll(kind.types)) {
      types.removeAll(kind.types);
    } else {
      types.addAll(kind.types);
    }
    // A category of a type no longer shown would hide everything.
    final category = widget.options.categories.where((c) => c.id == _filter.categoryId).firstOrNull;
    final keepCategory = category == null || types.isEmpty || types.contains(category.type);
    setState(() {
      _filter = _filter.copyWith(types: types, categoryId: keepCategory ? null : () => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final options = widget.options;
    final members = options.members;
    final tags = [
      ...options.tags,
      if (_filter.tag != null && !options.tags.contains(_filter.tag)) _filter.tag!,
    ];
    final visibleCategories = options.categories
        .where((c) => _filter.types.isEmpty || _filter.types.contains(c.type))
        .toList();
    final matches = _filter.apply(widget.movements, options.categoryNames).length;
    const gap = SizedBox(height: Finan2Space.md);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Finan2Space.lg, 0, Finan2Space.lg, Finan2Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.transactionsFilterTitle, style: Theme.of(context).textTheme.titleLarge),
              gap,
              Finan2SectionLabel(l10n.transactionsFilterType),
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
              gap,
              Finan2SectionLabel(l10n.commonCategory),
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
                        tone: Finan2Tone.of(context, Color(category.color)),
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
              if (options.accounts.length + options.cards.length > 1) ...[
                gap,
                Finan2SectionLabel(l10n.commonAccount),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final (id, name, icon) in [
                      for (final a in options.accounts)
                        (a.id, a.name, Finan2Icons.cuenta(a.type.name)),
                      for (final c in options.cards) (c.id, c.name, Icons.credit_card_outlined),
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
              if (tags.isNotEmpty) ...[
                gap,
                Finan2SectionLabel(l10n.transactionsFilterTag),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final tag in tags)
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
                gap,
                Finan2SectionLabel(l10n.transactionsPaidBy),
                Finan2SegmentedControl<String>(
                  options: {
                    _both: l10n.transactionsFilterBoth,
                    for (final uid in members) uid: options.memberLabel(uid).firstName,
                  },
                  dots: {
                    for (final uid in members)
                      uid: Finan2Tone.member(context, options.memberLabel(uid).index).color,
                  },
                  tones: {
                    for (final uid in members)
                      uid: Finan2Tone.member(context, options.memberLabel(uid).index),
                  },
                  selected: _filter.payer ?? _both,
                  onChanged: (uid) => setState(() {
                    _filter = _filter.copyWith(payer: () => uid == _both ? null : uid);
                  }),
                ),
              ],
              const SizedBox(height: Finan2Space.lg),
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
                      child: Text(l10n.transactionsFilterSee(matches)),
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
