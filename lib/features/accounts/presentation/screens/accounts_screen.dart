import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_list_row.dart';
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
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditAccountScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (accounts) {
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
                      formatCop(available),
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
              if (accounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Finan2Space.xl),
                  child: Text(
                    'Aún no hay cuentas. Toca + para crear la primera.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.inkSoft),
                  ),
                )
              else
                Finan2ListCard(
                  children: [
                    for (final account in accounts)
                      Finan2ListRow(
                        icon: _accountIcons[account.type]!,
                        label: account.name,
                        value: formatCop(account.balance),
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
    );
  }
}
