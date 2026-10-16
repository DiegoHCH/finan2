import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../debts/domain/entities/debt.dart';
import '../../../debts/presentation/debt_style.dart';
import '../../../debts/presentation/screens/debt_detail_screen.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../transactions/presentation/screens/edit_transaction_screen.dart';
import '../../../transfers/presentation/screens/transfer_history_screen.dart';
import '../../data/account_model.dart';
import '../account_style.dart';
import '../viewmodels/account_providers.dart';
import 'edit_account_screen.dart';

/// Cuentas: what's available apart from what's owed. The accounts add up
/// into the figure, each in its own color - the one it has in Anotar; the
/// credit cards go in their own block and subtract apart.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.accountsTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
              action: Finan2HeadAction(
                icon: Finan2Icons.agregar,
                tooltip: l10n.accountsAdd,
                filled: true,
                onTap: () => _open(context, const EditAccountScreen()),
              ),
            ),
            Expanded(
              child: accountsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return Finan2EmptyState(
                      icon: Finan2Icons.cuentas,
                      title: l10n.accountsEmptyTitle,
                      description: l10n.accountsEmptyDescription,
                      actionLabel: l10n.accountsEmptyAction,
                      onAction: () => _open(context, const EditAccountScreen()),
                    );
                  }
                  return _AccountsList(accounts: accounts, open: (s) => _open(context, s));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountsList extends ConsumerWidget {
  const _AccountsList({required this.accounts, required this.open});

  final List<Account> accounts;
  final ValueChanged<Widget> open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(availableBalanceProvider);
    final cards = (ref.watch(debtsProvider).value ?? const <Debt>[])
        .where((d) => d.type.isCard)
        .toList();
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xxl,
      ),
      children: [
        Finan2Figure(
          label: l10n.accountsAvailableLabel,
          amountText: formatMoney(available),
          fontSize: 38,
          subtitle: Text(l10n.accountsAvailableNote),
        ),
        const SizedBox(height: Finan2Space.lg),
        Finan2Sheet(
          children: [
            for (final account in accounts)
              Finan2TransactionRow(
                icon: accountIcon(account.type),
                iconColor: accountColor(ref, account.id),
                description: account.name,
                subLabel: account.includeInAvailable
                    ? account.type.label
                    : l10n.accountsRowExcluded(account.type.label),
                amountText: formatMoney(account.balance),
                amountColor: colors.ink,
                onTap: () => open(EditAccountScreen(account: account)),
              ),
          ],
        ),
        if (cards.isNotEmpty) ...[
          const SizedBox(height: Finan2Space.lg),
          Text(l10n.accountsCards, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: Finan2Space.sm),
          Finan2Sheet(
            children: [
              for (final card in cards)
                Finan2TransactionRow(
                  icon: Finan2Icons.tarjetaDebito,
                  iconColor: debtColor(card.id),
                  description: card.name,
                  subLabel: card.cutoffDay > 0
                      ? l10n.debtsCardDays(card.cutoffDay, card.paymentDay)
                      : l10n.debtsCardPayDay(card.paymentDay),
                  amountText: card.balance > 0 ? '−${formatMoney(card.balance)}' : formatMoney(0),
                  amountColor: colors.ink,
                  onTap: () => open(DebtDetailScreen(debt: card)),
                ),
            ],
          ),
        ],
        const SizedBox(height: Finan2Space.lg),
        Finan2Sheet(
          children: [
            if (accounts.length >= 2)
              _LinkRow(
                icon: Icons.swap_vert,
                label: l10n.accountsTransferBetween,
                onTap: () => open(const EditTransactionScreen(startWithTransfer: true)),
              ),
            _LinkRow(
              icon: Icons.history,
              label: l10n.transfersHistoryTitle,
              onTap: () => open(const TransferHistoryScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

/// The `.set` line of a sheet that leads somewhere: icon, label, chevron.
class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.inkSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.inkFaint),
          ],
        ),
      ),
    );
  }
}
