import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../transactions/presentation/viewmodels/transaction_providers.dart';
import '../../data/recurring_bill_model.dart';
import '../../data/recurring_bill_repository.dart';
import '../../data/recurring_bill_scanner.dart';

final recurringBillRepositoryProvider = Provider<RecurringBillRepository>((
  ref,
) {
  return RecurringBillRepository();
});

final recurringBillsProvider = StreamProvider<List<RecurringBill>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(recurringBillRepositoryProvider).watchBills(householdId);
});

final recurringBillScannerProvider = Provider<RecurringBillScanner>((ref) {
  return RecurringBillScanner(ref.watch(transactionRepositoryProvider));
});

class RecurringBillController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(RecurringBill bill) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(recurringBillRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => bill.id.isEmpty
          ? repo.createBill(householdId, bill)
          : repo.updateBill(householdId, bill),
    );
  }

  Future<void> delete(String billId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(recurringBillRepositoryProvider)
          .deleteBill(householdId, billId),
    );
  }
}

final recurringBillControllerProvider =
    AsyncNotifierProvider<RecurringBillController, void>(
      RecurringBillController.new,
    );
