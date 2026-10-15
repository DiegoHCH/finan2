import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/account_model.dart';
import '../../data/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

final accountsProvider = StreamProvider<List<Account>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(accountRepositoryProvider).watchAccounts(householdId);
});

/// Sum of balances for accounts flagged as "incluir en disponible".
final availableBalanceProvider = Provider<int>((ref) {
  final accounts = ref.watch(accountsProvider).value ?? const [];
  return accounts
      .where((a) => a.includeInAvailable)
      .fold(0, (sum, a) => sum + a.balance);
});

class AccountController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Account account) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(accountRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => account.id.isEmpty
          ? repo.createAccount(householdId, account)
          : repo.updateAccount(householdId, account),
    );
  }

  Future<int> usage(String accountId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return 0;
    return ref.read(accountRepositoryProvider).usage(householdId, accountId);
  }

  Future<void> delete(String accountId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider).deleteAccount(
            householdId,
            accountId,
          ),
    );
  }
}

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, void>(AccountController.new);
