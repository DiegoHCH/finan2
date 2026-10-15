import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/year_month.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transaction_model.dart';
import '../../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// The current month's transactions - what Inicio, Presupuesto's alerts and
/// the notification scanner work from. Screens that browse other months use
/// [transactionsOfMonthProvider].
final transactionsForMonthProvider = StreamProvider<List<Movement>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  final now = currentYearMonth();
  return ref.watch(transactionRepositoryProvider).watchTransactions(
        householdId,
        year: now.year,
        month: now.month,
      );
});

/// Any month's transactions, for Movimientos and Presupuesto while browsing.
final transactionsOfMonthProvider =
    StreamProvider.autoDispose.family<List<Movement>, YearMonth>((ref, month) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(transactionRepositoryProvider).watchTransactions(
        householdId,
        year: month.year,
        month: month.month,
      );
});

/// All of a year's transactions - used by Resumen anual to compute yearly
/// totals and the month-by-month spend chart.
final transactionsForYearProvider =
    StreamProvider.autoDispose.family<List<Movement>, int>((ref, year) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref
      .watch(transactionRepositoryProvider)
      .watchTransactionsForYear(householdId, year: year);
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
