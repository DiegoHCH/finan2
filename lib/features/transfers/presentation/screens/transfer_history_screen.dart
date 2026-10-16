import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/account_style.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../../transactions/presentation/screens/edit_transaction_screen.dart';
import '../../data/transfer_model.dart';
import '../../domain/transfer_plan.dart';
import '../viewmodels/transfer_providers.dart';

/// Pasar · historial: the money moved between accounts, by month. Each icon
/// takes the color of the account the money went to, so it shows at a
/// glance how much goes to savings. Transfers have no edit screen - tapping
/// one only offers to delete it, which reverses both balances.
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
    final result = ref.read(transferControllerProvider);
    if (result.hasError && context.mounted) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final transfersAsync = ref.watch(transfersProvider);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final members = ref.watch(currentHouseholdProvider).value?.members ?? const <String>[];
    final memberLabel = ref.watch(memberLabelProvider);
    final formatMoney = ref.watch(moneyFormatterProvider);
    final l10n = context.l10n;

    String accountName(String id) =>
        accounts.where((a) => a.id == id).firstOrNull?.name ?? l10n.transfersDeletedAccount;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.accountsTitle,
              title: l10n.transfersHistoryTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
            ),
            Expanded(
              child: transfersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (transfers) {
                  if (transfers.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.swap_vert,
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
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Finan2Space.lg,
                      Finan2Space.xs,
                      Finan2Space.lg,
                      Finan2Space.xxl,
                    ),
                    children: [
                      Finan2Sheet(
                        children: [
                          for (final group in groupByMonth(transfers, (t) => t.date)) ...[
                            Finan2SheetHeading(label: _monthLabel(group.month)),
                            for (final transfer in group.items)
                              _row(
                                ref: ref,
                                transfer: transfer,
                                to: accountName(transfer.toAccountId),
                                from: accountName(transfer.fromAccountId),
                                payer: members.length > 1 ? memberLabel(transfer.createdBy) : null,
                                amount: formatMoney(transfer.amount),
                                ink: colors.ink,
                                l10n: l10n,
                                onTap: () => _delete(context, ref, transfer),
                              ),
                          ],
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

  /// «Octubre» this year, «Octubre 2025» before it.
  static String _monthLabel(DateTime month) {
    final now = DateTime.now();
    final label = month.year == now.year
        ? DateFormat.MMMM().format(month)
        : DateFormat('MMMM y').format(month);
    return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
  }

  Widget _row({
    required WidgetRef ref,
    required Transfer transfer,
    required String to,
    required String from,
    required MemberLabel? payer,
    required String amount,
    required Color ink,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    final date = DateFormat('d MMM').format(transfer.date).replaceAll('.', '');
    return Finan2TransactionRow(
      icon: Icons.swap_vert,
      iconColor: accountColor(ref, transfer.toAccountId),
      description: l10n.transfersRowTo(to),
      subLabel: '${payer == null ? '' : '· '}${l10n.transfersRowFrom(from, date)}',
      avatarLabel: payer?.firstName,
      avatarIndex: payer?.index,
      amountText: amount,
      amountColor: ink,
      onTap: onTap,
    );
  }
}
