import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transfer_model.dart';
import '../viewmodels/transfer_providers.dart';
import 'transfer_screen.dart';

/// Read-only log of past transfers, reachable from Cuentas. Transfers have
/// no edit screen - tapping one only offers to delete it, which reverses
/// the balance adjustment it made.
class TransferHistoryScreen extends ConsumerWidget {
  const TransferHistoryScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Transfer transfer) async {
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: 'Eliminar transferencia',
      message: 'Se revertirá el ajuste de saldo en ambas cuentas. Esta acción no '
          'se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(transferControllerProvider.notifier).deleteTransfer(transfer);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final transfersAsync = ref.watch(transfersProvider);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final formatMoney = ref.watch(moneyFormatterProvider);

    String accountName(String id) {
      for (final account in accounts) {
        if (account.id == id) return account.name;
      }
      return 'Cuenta eliminada';
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Finan2BackHead(title: 'Transferencias'),
            Expanded(
              child: transfersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (transfers) {
                  if (transfers.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.swap_horiz,
                      title: 'Aún no hay transferencias',
                      description:
                          'Los movimientos de dinero entre tus propias '
                          'cuentas aparecerán aquí.',
                      actionLabel: '+ Transferir',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransferScreen()),
                      ),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.all(Finan2Space.xl),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      itemCount: transfers.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: colors.line),
                      itemBuilder: (context, index) {
                        final transfer = transfers[index];
                        return Finan2TransactionRow(
                          icon: Icons.swap_horiz,
                          iconColor: colors.inkSoft,
                          description:
                              '${accountName(transfer.fromAccountId)} → '
                              '${accountName(transfer.toAccountId)}',
                          subLabel: DateFormat('dd MMM yyyy', 'es').format(transfer.date),
                          amountText: formatMoney(transfer.amount),
                          amountColor: colors.ink,
                          onTap: () => _delete(context, ref, transfer),
                        );
                      },
                    ),
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
