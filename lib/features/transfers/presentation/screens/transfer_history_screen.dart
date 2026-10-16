import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../transactions/presentation/screens/edit_transaction_screen.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transfer_model.dart';
import '../viewmodels/transfer_providers.dart';

/// Read-only log of past transfers, reachable from Cuentas. Transfers have
/// no edit screen - tapping one only offers to delete it, which reverses
/// the balance adjustment it made.
class TransferHistoryScreen extends ConsumerWidget {
  const TransferHistoryScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Transfer transfer) async {
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: context.l10n.transfersDeleteTitle,
      message: context.l10n.transfersDeleteMessage,
      confirmLabel: context.l10n.commonDelete,
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
    final l10n = context.l10n;

    String accountName(String id) {
      for (final account in accounts) {
        if (account.id == id) return account.name;
      }
      return l10n.transfersDeletedAccount;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2BackHead(title: l10n.transfersHistoryTitle),
            Expanded(
              child: transfersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (transfers) {
                  if (transfers.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.swap_horiz,
                      title: l10n.transfersEmptyTitle,
                      description: l10n.transfersEmptyDescription,
                      actionLabel: l10n.transfersEmptyAction,
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditTransactionScreen(startWithTransfer: true),
                        ),
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
                          subLabel: DateFormat('dd MMM yyyy').format(transfer.date),
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
