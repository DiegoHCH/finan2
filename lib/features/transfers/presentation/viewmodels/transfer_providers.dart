import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transfer_model.dart';
import '../../data/transfer_repository.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository();
});

class TransferController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createTransfer(Transfer transfer) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transferRepositoryProvider).createTransfer(householdId, transfer),
    );
  }
}

final transferControllerProvider = AsyncNotifierProvider<TransferController, void>(
  TransferController.new,
);
