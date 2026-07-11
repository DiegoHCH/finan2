import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/recurring_bill_model.dart';
import '../viewmodels/recurring_bill_providers.dart';
import 'edit_recurring_bill_screen.dart';

class RecurringBillsScreen extends ConsumerWidget {
  const RecurringBillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final billsAsync = ref.watch(recurringBillsProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};
    final formatMoney = ref.watch(moneyFormatterProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'recurringBillsFab',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditRecurringBillScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final bills = billsAsync.value ?? const <RecurringBill>[];
                final totalFactura = bills
                    .where((b) => b.type != CategoryType.ingreso)
                    .fold(0, (sum, b) => sum + b.amount);
                return Finan2AppTop(
                  label: 'Facturas recurrentes',
                  title: '${formatMoney(totalFactura)} al mes',
                  trailing: bills.isEmpty ? null : const _AutoBadge(),
                );
              },
            ),
            Expanded(
              child: billsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (bills) {
                  if (bills.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.autorenew,
                      title: 'Aún no hay facturas recurrentes',
                      description:
                          'Programa el arriendo, servicios o el sueldo para que '
                          'se registren solos cada mes.',
                      actionLabel: '+ Nueva factura recurrente',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditRecurringBillScreen(),
                        ),
                      ),
                    );
                  }

                  return ListView(
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
                            const Text(
                              'Se registran solas cada mes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${bills.length} activa${bills.length == 1 ? '' : 's'}',
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
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: colors.line),
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < bills.length; i++) ...[
                              if (i > 0) Divider(height: 1, color: colors.line),
                              _BillRow(
                                bill: bills[i],
                                category: categoryById[bills[i].categoryId],
                                formatMoney: formatMoney,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditRecurringBillScreen(
                                      bill: bills[i],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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

class _AutoBadge extends StatelessWidget {
  const _AutoBadge();

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
        'Auto',
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

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.bill,
    required this.category,
    required this.formatMoney,
    required this.onTap,
  });

  final RecurringBill bill;
  final Category? category;
  final String Function(num) formatMoney;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isIncome = bill.type == CategoryType.ingreso;
    final day = bill.dayOfMonth.toString().padLeft(2, '0');

    return Finan2TransactionRow(
      icon: category != null ? Finan2Icons.categoria(category!.iconSlug) : Icons.autorenew,
      iconColor: category != null ? Color(category!.color) : colors.inkSoft,
      description: bill.name,
      subLabel: '${bill.type.label} · cada mes, día $day',
      amountText: isIncome ? '+${formatMoney(bill.amount)}' : '−${formatMoney(bill.amount)}',
      amountColor: isIncome ? colors.income : colors.ink,
      onTap: onTap,
    );
  }
}
