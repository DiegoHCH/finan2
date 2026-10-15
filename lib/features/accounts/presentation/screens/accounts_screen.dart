import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../transfers/presentation/screens/transfer_history_screen.dart';
import '../../../transfers/presentation/screens/transfer_screen.dart';
import '../../data/account_model.dart';
import '../viewmodels/account_providers.dart';
import 'edit_account_screen.dart';

const _accountIcons = <AccountType, IconData>{
  AccountType.efectivo: Finan2Icons.efectivo,
  AccountType.banco: Finan2Icons.banco,
  AccountType.billetera: Finan2Icons.billeteraDigital,
  AccountType.debito: Finan2Icons.tarjetaDebito,
};

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final available = ref.watch(availableBalanceProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;

    return Scaffold(
      floatingActionButton: accountsAsync.value?.isEmpty ?? true
          ? null
          : FloatingActionButton(
              heroTag: 'accountsFab',
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const EditAccountScreen())),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: l10n.accountsTitle,
              title: l10n.accountsAvailableMoney,
              household: household,
              showBackButton: true,
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
                      onAction: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (_) => const EditAccountScreen())),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Finan2Space.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Theme.of(context).colorScheme.primary, colors.brandDeep],
                          ),
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.accountsTotalAvailable,
                              style: const TextStyle(color: Colors.white, fontSize: 11.5),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatMoney(available),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              l10n.accountsCountInHousehold(accounts.length),
                              style: const TextStyle(color: Colors.white, fontSize: 11.5),
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
                            for (var i = 0; i < accounts.length; i++) ...[
                              if (i > 0) Divider(height: 1, color: colors.line),
                              Finan2TransactionRow(
                                icon: _accountIcons[accounts[i].type]!,
                                iconColor: colors.inkSoft,
                                description: accounts[i].name,
                                subLabel: accounts[i].type.label,
                                amountText: formatMoney(accounts[i].balance),
                                amountColor: colors.ink,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => EditAccountScreen(account: accounts[i]),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Finan2Space.lg),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            if (accounts.length >= 2)
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => const TransferScreen()),
                                ),
                                icon: const Icon(Icons.swap_horiz),
                                label: Text(l10n.accountsTransferBetween),
                              ),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const TransferHistoryScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.history),
                              label: Text(l10n.accountsHistory),
                            ),
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
