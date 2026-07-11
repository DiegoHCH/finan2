import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../viewmodels/transaction_providers.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactionsAsync = ref.watch(transactionsForMonthProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final household = ref.watch(currentHouseholdProvider).value;
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    final categoryById = {for (final c in categories) c.id: c};
    final monthLabel = DateFormat.yMMMM(
      'es',
    ).format(DateTime(selectedMonth.year, selectedMonth.month));

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Finan2Space.xl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(color: colors.line),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () =>
                        ref.read(selectedMonthProvider.notifier).previous(),
                  ),
                  Text(
                    '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        ref.read(selectedMonthProvider.notifier).next(),
                  ),
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
                  return Center(
                    child: Text(
                      'Sin movimientos este mes. Toca + para agregar el primero.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.inkSoft),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Finan2Space.xl,
                  ),
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: colors.line),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final category = categoryById[tx.categoryId];
                    final memberIndex =
                        household?.members.indexOf(tx.createdBy) ?? 0;
                    final memberName =
                        household?.memberInfo[tx.createdBy]?.name ?? '?';
                    return Finan2TransactionRow(
                      icon: category != null
                          ? Finan2Icons.categoria(category.iconSlug)
                          : Icons.label_outline,
                      iconColor:
                          category != null ? Color(category.color) : colors.inkSoft,
                      description: tx.description.isEmpty
                          ? (category?.name ?? '')
                          : tx.description,
                      subLabel:
                          '${category?.type.plural ?? ''} · ${DateFormat('dd MMM', 'es').format(tx.date)}',
                      avatarLabel: memberName.isEmpty
                          ? '?'
                          : memberName.substring(0, 1).toUpperCase(),
                      avatarIndex: memberIndex < 0 ? 0 : memberIndex,
                      amountText: tx.isIncome
                          ? '+${formatCop(tx.amount)}'
                          : '−${formatCop(tx.amount)}',
                      amountColor: tx.isIncome ? colors.income : colors.ink,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditTransactionScreen(
                            transaction: tx,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
