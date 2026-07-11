import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditAccountScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Cuentas',
              title: 'Dinero disponible',
              household: household,
            ),
            Expanded(
              child: accountsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return Finan2EmptyState(
                      icon: Finan2Icons.cuentas,
                      title: 'Aún no hay cuentas',
                      description:
                          'Agrega tu primera cuenta (efectivo, banco, '
                          'billetera) para empezar a registrar movimientos.',
                      actionLabel: '+ Nueva cuenta',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditAccountScreen(),
                        ),
                      ),
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
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              colors.brandDeep,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total disponible',
                              style: TextStyle(color: Colors.white, fontSize: 11.5),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: Finan2Space.lg),
                      Finan2ListCard(
                        children: [
                          for (final account in accounts)
                            Finan2ListRow(
                              icon: _accountIcons[account.type]!,
                              label: account.name,
                              value: formatMoney(account.balance),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditAccountScreen(account: account),
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
