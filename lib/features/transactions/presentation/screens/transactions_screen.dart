import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_period_picker.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../monthly_notes/presentation/screens/monthly_notes_screen.dart';
import '../../../recurring_bills/presentation/screens/recurring_bills_screen.dart';
import '../viewmodels/transaction_providers.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  YearMonth _month = currentYearMonth();

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
    final transactionsAsync = ref.watch(transactionsOfMonthProvider(_month));
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final household = ref.watch(currentHouseholdProvider).value;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    final categoryById = {for (final c in categories) c.id: c};
    final monthLabelCap = _month.label;

    final currentTransactions = transactionsAsync.value ?? const [];
    final net = currentTransactions.fold<int>(
      0,
      (sum, tx) => sum + (tx.isIncome ? tx.amount : -tx.amount),
    );

    return Scaffold(
      floatingActionButton: currentTransactions.isEmpty
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
                  : '${formatMoney(net)} neto',
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
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (transactions) {
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
                                    final memberIndex = household?.members
                                            .indexOf(tx.createdBy) ??
                                        0;
                                    final memberName = household
                                            ?.memberInfo[tx.createdBy]?.name ??
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
                                      subLabel:
                                          '${category?.name ?? ''} · ${DateFormat('dd MMM', 'es').format(tx.date)}',
                                      avatarLabel: memberName.isEmpty
                                          ? '?'
                                          : memberName.substring(0, 1).toUpperCase(),
                                      avatarIndex: memberIndex < 0 ? 0 : memberIndex,
                                      amountText: tx.isIncome
                                          ? '+${formatMoney(tx.amount)}'
                                          : '−${formatMoney(tx.amount)}',
                                      amountColor:
                                          tx.isIncome ? colors.income : colors.ink,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditTransactionScreen(
                                            transaction: tx,
                                          ),
                                        ),
                                      ),
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
