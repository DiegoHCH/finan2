import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/avalanche_calculator.dart';
import '../../domain/entities/debt.dart';
import '../../data/debt_repository.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository();
});

final debtsProvider = StreamProvider<List<Debt>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(debtRepositoryProvider).watchDebts(householdId);
});

final totalDebtProvider = Provider<int>((ref) {
  final debts = ref.watch(debtsProvider).value ?? const [];
  return debts.fold(0, (sum, d) => sum + d.balance);
});

/// The Avalancha projection (payoff date + per-debt schedule) recomputed
/// whenever the debt list changes.
final avalancheResultProvider = Provider<AvalancheResult>((ref) {
  final debts = ref.watch(debtsProvider).value ?? const [];
  return computeAvalanche(debts);
});

class DebtController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Debt debt) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          debt.id.isEmpty ? repo.createDebt(householdId, debt) : repo.updateDebt(householdId, debt),
    );
  }

  Future<void> delete(String debtId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(debtRepositoryProvider).deleteDebt(householdId, debtId),
    );
  }
}

final debtControllerProvider = AsyncNotifierProvider<DebtController, void>(DebtController.new);
