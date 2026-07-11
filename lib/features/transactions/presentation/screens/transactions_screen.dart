import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../monthly_notes/presentation/screens/monthly_notes_screen.dart';
import '../../../recurring_bills/presentation/screens/recurring_bills_screen.dart';
import '../viewmodels/transaction_providers.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsForMonthProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final household = ref.watch(currentHouseholdProvider).value;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    final categoryById = {for (final c in categories) c.id: c};
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM('es').format(now);
    final monthLabelCap = '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}';

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
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditTransactionScreen()),
              ),
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
            if (currentTransactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.xl,
                  0,
                  Finan2Space.xl,
                  Finan2Space.sm,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: colors.line),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.chevron_left, color: colors.inkFaint),
                      Text(
                        monthLabelCap,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Icon(Icons.chevron_right, color: colors.inkFaint),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Aún no hay movimientos',
                      description:
                          'Registra tu primer ingreso o gasto del mes y aquí '
                          'verás el resumen del hogar.',
                      actionLabel: '+ Agregar el primero',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditTransactionScreen(),
                        ),
                      ),
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
