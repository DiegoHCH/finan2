import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_period_picker.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../monthly_notes/presentation/screens/monthly_notes_screen.dart';
import '../../../recurring_bills/presentation/screens/recurring_bills_screen.dart';
import '../../data/movement_filter.dart';
import '../../data/tags.dart';
import '../../data/transaction_model.dart';
import '../viewmodels/transaction_providers.dart';
import '../widgets/movement_search_bar.dart';
import 'edit_transaction_screen.dart';

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

  /// Deleted on screen but not yet in Firestore, while "Deshacer" is offered.
  final _pendingDeletion = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _filter = const MovementFilter());
  }

  Future<void> _openMovement(Movement tx) async {
    final toDelete = await Navigator.of(context).push<Movement>(
      MaterialPageRoute(builder: (_) => EditTransactionScreen(transaction: tx)),
    );
    if (toDelete != null && mounted) await _deleteWithUndo(toDelete);
  }

  /// Hides [tx] and only deletes it once the "Deshacer" snackbar closes
  /// without being tapped. Deleting later instead of recreating on undo
  /// keeps the partner's movements restorable: the rules only let a member
  /// create records attributed to themselves.
  Future<void> _deleteWithUndo(Movement tx) async {
    setState(() => _pendingDeletion.add(tx.id));
    final messenger = ScaffoldMessenger.of(context);
    // Outlives this screen, so the delete still happens after a tab switch.
    final container = ProviderScope.containerOf(context);
    messenger.hideCurrentSnackBar();
    final reason = await messenger
        .showSnackBar(
          SnackBar(
            content: const Text('Movimiento borrado'),
            action: SnackBarAction(label: 'Deshacer', onPressed: () {}),
            duration: const Duration(seconds: 5),
          ),
        )
        .closed;
    if (reason != SnackBarClosedReason.action) {
      final controller = container.read(transactionControllerProvider.notifier);
      await controller.delete(tx.id);
      final result = container.read(transactionControllerProvider);
      if (result.hasError && mounted) {
        await showFinan2ErrorSheet(
          context,
          title: 'No se pudo borrar',
          message: friendlyErrorMessage(result.error!),
        );
      }
    }
    if (mounted) setState(() => _pendingDeletion.remove(tx.id));
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
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(initialDate: _newMovementDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchingYear = _wholeYear && _filter.hasQuery;
    final transactionsAsync = searchingYear
        ? ref.watch(transactionsForYearProvider(_month.year))
        : ref.watch(transactionsOfMonthProvider(_month));
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final household = ref.watch(currentHouseholdProvider).value;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    final categoryById = {for (final c in categories) c.id: c};
    final monthLabelCap = _month.label;

    final allTransactions = (transactionsAsync.value ?? const <Movement>[])
        .where((tx) => !_pendingDeletion.contains(tx.id))
        .toList();
    final currentTransactions = _filter.apply(
      allTransactions,
      {for (final c in categories) c.id: c.name},
    );
    final filtering = !_filter.isEmpty;
    final net = currentTransactions.fold<int>(
      0,
      (sum, tx) => sum + (tx.isIncome ? tx.amount : -tx.amount),
    );

    return Scaffold(
      floatingActionButton: allTransactions.isEmpty
          ? null
          : FloatingActionButton(
              heroTag: 'transactionsFab',
              onPressed: _addMovement,
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Movimientos',
              title: currentTransactions.isEmpty
                  ? monthLabelCap
                  : '${formatMoney(net)} neto${searchingYear ? ' en ${_month.year}' : ''}${filtering ? ' · filtrado' : ''}',
              household: household,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Finan2Space.xl,
                0,
                Finan2Space.xl,
                Finan2Space.sm,
              ),
              child: Finan2PeriodPicker(
                label: monthLabelCap,
                previousTooltip: 'Mes anterior',
                nextTooltip: 'Mes siguiente',
                onPrevious: () => setState(() => _month = _month.plusMonths(-1)),
                onNext: () => setState(() => _month = _month.plusMonths(1)),
                onReset: _month.isCurrent
                    ? null
                    : () => setState(() => _month = currentYearMonth()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Finan2Space.xl,
                0,
                Finan2Space.xl,
                Finan2Space.sm,
              ),
              child: MovementSearchBar(
                controller: _searchController,
                filter: _filter,
                categories: categories,
                accounts: ref.watch(accountsProvider).value ?? const [],
                cards: [
                  for (final d in ref.watch(debtsProvider).value ?? const [])
                    if (d.type.isCard) d,
                ],
                tags: tagsByUse(allTransactions),
                household: household,
                onQueryChanged: (q) => setState(() => _filter = _filter.copyWith(query: q)),
                onFilterChanged: (f) => setState(() => _filter = f),
              ),
            ),
            if (_filter.hasQuery)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.xl,
                  0,
                  Finan2Space.xl,
                  Finan2Space.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Finan2Chip(
                    icon: Icons.calendar_month_outlined,
                    label: 'Buscar en todo ${_month.year}',
                    selected: _wholeYear,
                    onTap: () => setState(() => _wholeYear = !_wholeYear),
                  ),
                ),
              ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (_) {
                  final transactions = currentTransactions;
                  if (transactions.isEmpty && filtering) {
                    return Finan2EmptyState(
                      icon: Icons.search_off,
                      title: 'Nada coincide',
                      description: searchingYear
                          ? 'Ningún movimiento de ${_month.year} coincide con la búsqueda.'
                          : 'Ningún movimiento de $monthLabelCap coincide con la '
                              'búsqueda o los filtros.',
                      actionLabel: 'Limpiar búsqueda',
                      onAction: _clearSearch,
                    );
                  }
                  if (transactions.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: _month.isCurrent
                          ? 'Aún no hay movimientos'
                          : 'Sin movimientos en $monthLabelCap',
                      description: _month.isCurrent
                          ? 'Registra tu primer ingreso o gasto del mes y aquí '
                              'verás el resumen del hogar.'
                          : 'No se registró ningún ingreso ni gasto este mes.',
                      actionLabel: '+ Agregar el primero',
                      onAction: _addMovement,
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Finan2Space.xl,
                      0,
                      Finan2Space.xl,
                      Finan2Space.xl,
                    ),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: colors.line),
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < transactions.length; i++) ...[
                              if (i > 0) Divider(height: 1, color: colors.line),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Builder(
                                  builder: (context) {
                                    final tx = transactions[i];
                                    final category = categoryById[tx.categoryId];
                                    // Who paid, not who logged it.
                                    final memberIndex = household?.members
                                            .indexOf(tx.payer) ??
                                        0;
                                    final memberName = household
                                            ?.memberInfo[tx.payer]?.name ??
                                        '?';
                                    return Finan2TransactionRow(
                                      icon: category != null
                                          ? Finan2Icons.categoria(category.iconSlug)
                                          : Icons.label_outline,
                                      iconColor: category != null
                                          ? Color(category.color)
                                          : colors.inkSoft,
                                      description: tx.description.isEmpty
                                          ? (category?.name ?? '')
                                          : tx.description,
                                      subLabel: [
                                        category?.name ?? '',
                                        DateFormat('dd MMM', 'es').format(tx.date),
                                        ...tx.tags.map((t) => '#$t'),
                                      ].join(' · '),
                                      avatarLabel: memberName.isEmpty
                                          ? '?'
                                          : memberName.substring(0, 1).toUpperCase(),
                                      avatarIndex: memberIndex < 0 ? 0 : memberIndex,
                                      amountText: tx.isIncome
                                          ? '+${formatMoney(tx.amount)}'
                                          : '−${formatMoney(tx.amount)}',
                                      amountColor:
                                          tx.isIncome ? colors.income : colors.ink,
                                      onTap: () => _openMovement(tx),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Finan2Space.lg),
                      Finan2ListCard(
                        children: [
                          Finan2ListRow(
                            icon: Icons.autorenew,
                            label: 'Facturas recurrentes',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RecurringBillsScreen(),
                              ),
                            ),
                          ),
                          Finan2ListRow(
                            icon: Icons.sticky_note_2_outlined,
                            label: 'Notas',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MonthlyNotesScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
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
