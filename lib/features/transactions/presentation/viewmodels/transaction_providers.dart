import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transaction_model.dart';
import '../../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// Movimientos always shows the current month - browsing past months is a
/// separate "historial" feature, not this screen.
final transactionsForMonthProvider = StreamProvider<List<Movement>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  final now = DateTime.now();
  return ref.watch(transactionRepositoryProvider).watchTransactions(
        householdId,
        year: now.year,
        month: now.month,
      );
});

class TransactionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Movement tx) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(transactionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => tx.id.isEmpty
          ? repo.createTransaction(householdId, tx)
          : repo.updateTransaction(householdId, tx),
    );
  }

  Future<void> delete(String txId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionRepositoryProvider).deleteTransaction(
            householdId,
            txId,
          ),
    );
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, void>(
  TransactionController.new,
);
