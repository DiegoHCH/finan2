import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transaction_model.dart';
import '../../data/transaction_repository.dart';

class SelectedMonth {
  const SelectedMonth(this.year, this.month);

  final int year;
  final int month;

  SelectedMonth previous() =>
      month == 1 ? SelectedMonth(year - 1, 12) : SelectedMonth(year, month - 1);

  SelectedMonth next() =>
      month == 12 ? SelectedMonth(year + 1, 1) : SelectedMonth(year, month + 1);
}

class SelectedMonthNotifier extends Notifier<SelectedMonth> {
  @override
  SelectedMonth build() {
    final now = DateTime.now();
    return SelectedMonth(now.year, now.month);
  }

  void previous() => state = state.previous();

  void next() => state = state.next();
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, SelectedMonth>(
  SelectedMonthNotifier.new,
);

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsForMonthProvider = StreamProvider<List<Movement>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  final selected = ref.watch(selectedMonthProvider);
  if (householdId == null) return Stream.value(const []);
  return ref.watch(transactionRepositoryProvider).watchTransactions(
        householdId,
        year: selected.year,
        month: selected.month,
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
