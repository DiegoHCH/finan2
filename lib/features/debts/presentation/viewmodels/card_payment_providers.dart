import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/card_payment_model.dart';
import '../../data/card_payment_repository.dart';

final cardPaymentRepositoryProvider = Provider<CardPaymentRepository>((ref) {
  return CardPaymentRepository();
});

final cardPaymentsProvider =
    StreamProvider.family<List<CardPayment>, String>((ref, cardDebtId) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(cardPaymentRepositoryProvider).watchPayments(householdId, cardDebtId);
});

class CardPaymentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createPayment(CardPayment payment) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cardPaymentRepositoryProvider).createPayment(householdId, payment),
    );
  }

  Future<void> deletePayment(CardPayment payment) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cardPaymentRepositoryProvider).deletePayment(householdId, payment),
    );
  }
}

final cardPaymentControllerProvider =
    AsyncNotifierProvider<CardPaymentController, void>(CardPaymentController.new);
