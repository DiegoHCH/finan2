import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/domain/entities/debt.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../../monthly_notes/presentation/screens/monthly_notes_screen.dart';
import '../../../recurring_bills/presentation/screens/recurring_bills_screen.dart';
import '../../domain/entities/movement.dart';
import '../../domain/movement_days.dart';
import '../../domain/movement_filter.dart';
import '../../domain/tags.dart';
import '../movement_actions.dart';
import '../viewmodels/transaction_providers.dart';
import '../widgets/movement_filters.dart';
import 'edit_transaction_screen.dart';

/// «Una libreta, por días»: the month's movements grouped by day with each
/// day's net, the search always in sight and the filters as chips.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  YearMonth _month = currentYearMonth();
  final _searchController = TextEditingController();
  var _filter = const MovementFilter();

  /// A search looks through the browsed month's whole year when on.
  var _wholeYear = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _filter = const MovementFilter());
  }

  /// Today's day of month, clamped to the browsed month - so a movement
  /// added while looking at another month lands in it.
  DateTime get _newMovementDate {
    if (_month.isCurrent) return DateTime.now();
    final lastDay = DateTime(_month.year, _month.month + 1, 0).day;
    final day = DateTime.now().day.clamp(1, lastDay);
    return DateTime(_month.year, _month.month, day);
  }

  void _addMovement() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditTransactionScreen(initialDate: _newMovementDate)),
    );
  }

  Future<void> _openFilters(MovementFilterOptions options, List<Movement> movements) async {
    final picked = await showMovementFilterSheet(
      context,
      initial: _filter,
      options: options,
      movements: movements,
    );
    if (picked != null) setState(() => _filter = picked);
  }

  @override
  Widget build(BuildContext context) {
    final searchingYear = _wholeYear && _filter.hasQuery;
    final transactionsAsync = searchingYear
        ? ref.watch(transactionsForYearProvider(_month.year))
        : ref.watch(transactionsOfMonthProvider(_month));
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final household = ref.watch(currentHouseholdProvider).value;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final memberLabel = ref.watch(memberLabelProvider);
    final pending = ref.watch(pendingMovementDeletionsProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;

    final categoryById = {for (final c in categories) c.id: c};
    final monthLabelCap = _month.label;

    final allTransactions = [
      for (final tx in transactionsAsync.value ?? const <Movement>[])
        if (!pending.contains(tx.id)) tx,
    ];
    final options = MovementFilterOptions(
      categories: categories,
      accounts: ref.watch(accountsProvider).value ?? const [],
      cards: [
        for (final d in ref.watch(debtsProvider).value ?? const <Debt>[])
          if (d.type.isCard) d,
      ],
      tags: tagsByUse(allTransactions),
      members: household?.members ?? const [],
      memberLabel: memberLabel,
    );
    final transactions = _filter.apply(allTransactions, options.categoryNames)
      ..sort((a, b) => b.date.compareTo(a.date));
    final filtering = !_filter.isEmpty;

    String signed(int amount) =>
        amount < 0 ? '−${formatMoney(-amount)}' : '+${formatMoney(amount)}';

    Widget row(Movement tx, {required bool withDate}) {
      final category = categoryById[tx.categoryId];
      // Who paid, not who logged it.
      final payer = memberLabel(tx.payer);
      return Finan2TransactionRow(
        icon: category != null ? Finan2Icons.categoria(category.iconSlug) : Icons.label_outline,
        iconColor: category != null ? Color(category.color) : colors.inkSoft,
        description: tx.description.isEmpty ? (category?.name ?? '') : tx.description,
        subLabel: '· ${withDate ? DateFormat('d MMM').format(tx.date) : (category?.name ?? '')}',
        avatarLabel: payer.firstName,
        avatarIndex: payer.index,
        tags: tx.tags,
        amountText: tx.isIncome ? '+${formatMoney(tx.amount)}' : '−${formatMoney(tx.amount)}',
        amountColor: tx.isIncome ? colors.income : colors.ink,
        onTap: () => openMovement(context, tx),
      );
    }

    final hasChips = MovementFilterChips.hasChips(_filter);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              title: l10n.transactionsTitle,
              over: _MonthNav(
                label: monthLabelCap,
                onPrevious: () => setState(() => _month = _month.plusMonths(-1)),
                onNext: () => setState(() => _month = _month.plusMonths(1)),
                onReset: _month.isCurrent
                    ? null
                    : () => setState(() => _month = currentYearMonth()),
              ),
              action: Finan2HeadAction(
                icon: Icons.tune,
                tooltip: l10n.transactionsFilters,
                badge: _filter.activeFilterCount,
                highlighted: _filter.activeFilterCount > 0,
                onTap: () => _openFilters(options, allTransactions),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Finan2Space.lg, 0, Finan2Space.lg, Finan2Space.sm),
              child: MovementSearchField(
                controller: _searchController,
                onChanged: (q) => setState(() => _filter = _filter.copyWith(query: q)),
              ),
            ),
            if (hasChips)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  0,
                  Finan2Space.lg,
                  Finan2Space.sm,
                ),
                child: MovementFilterChips(
                  filter: _filter,
                  options: options,
                  onFilterChanged: (f) => setState(() => _filter = f),
                  year: _month.year,
                  wholeYear: _wholeYear,
                  onWholeYearChanged: (on) => setState(() => _wholeYear = on),
                ),
              ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (_) {
                  if (transactions.isEmpty && filtering) {
                    return Finan2EmptyState(
                      icon: Icons.search_off,
                      title: l10n.transactionsNoMatchTitle,
                      description: searchingYear
                          ? l10n.transactionsNoMatchYear(_month.year)
                          : l10n.transactionsNoMatchMonth(monthLabelCap),
                      actionLabel: l10n.transactionsClearSearch,
                      onAction: _clearSearch,
                    );
                  }
                  if (transactions.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: _month.isCurrent
                          ? l10n.transactionsEmptyTitle
                          : l10n.transactionsEmptyTitleMonth(monthLabelCap),
                      description: _month.isCurrent
                          ? l10n.transactionsEmptyDescription
                          : l10n.transactionsEmptyDescriptionMonth,
                      actionLabel: l10n.transactionsEmptyAction,
                      onAction: _addMovement,
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Finan2Space.lg,
                      Finan2Space.xxs,
                      Finan2Space.lg,
                      Finan2Space.xl,
                    ),
                    children: [
                      Finan2Sheet(
                        children: filtering
                            // Found movements read as one list, each with its date.
                            ? [for (final tx in transactions) row(tx, withDate: true)]
                            : [
                                for (final day in groupByDay(transactions)) ...[
                                  Finan2SheetHeading(
                                    label: _dayLabel(context, day.date),
                                    trailing: signed(day.net),
                                  ),
                                  for (final tx in day.movements) row(tx, withDate: false),
                                ],
                              ],
                      ),
                      if (filtering)
                        Padding(
                          padding: const EdgeInsets.only(top: Finan2Space.md),
                          child: Text(
                            l10n.transactionsResultsTotal(
                              transactions.length,
                              signed(netOf(transactions)),
                            ),
                            key: const Key('movementsResultsTotal'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.inkSoft,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        )
                      else ...[
                        const SizedBox(height: Finan2Space.lg),
                        Finan2ListCard(
                          children: [
                            Finan2ListRow(
                              icon: Icons.autorenew,
                              label: l10n.transactionsRecurringBills,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RecurringBillsScreen(),
                                ),
                              ),
                            ),
                            Finan2ListRow(
                              icon: Icons.sticky_note_2_outlined,
                              label: l10n.transactionsNotes,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => const MonthlyNotesScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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

/// «Hoy · martes 14», «Ayer · lunes 13» or «domingo 12».
String _dayLabel(BuildContext context, DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekday = DateFormat('EEEE d').format(day);
  final daysAgo = today.difference(day).inDays;
  if (daysAgo == 0) return context.l10n.transactionsDayToday(weekday);
  if (daysAgo == 1) return context.l10n.transactionsDayYesterday(weekday);
  return weekday;
}

/// «‹ Octubre 2026 ›» as the head's over-line; the month comes back to today
/// with a tap while browsing another.
class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    Widget arrow(IconData icon, String tooltip, VoidCallback onTap) => Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 16,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(icon, size: 18, color: colors.inkFaint),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(Icons.chevron_left, l10n.transactionsPreviousMonth, onPrevious),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onReset,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: label),
                if (onReset != null)
                  TextSpan(
                    text: ' · ${l10n.corePeriodBackToToday}',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
              ],
            ),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.inkFaint),
          ),
        ),
        arrow(Icons.chevron_right, l10n.transactionsNextMonth, onNext),
      ],
    );
  }
}
