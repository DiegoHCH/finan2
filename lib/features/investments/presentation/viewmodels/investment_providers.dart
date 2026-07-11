import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/investment_model.dart';
import '../../data/investment_repository.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository();
});

final investmentsProvider = StreamProvider<List<Investment>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(investmentRepositoryProvider).watchInvestments(householdId);
});

final totalInvestmentValueProvider = Provider<int>((ref) {
  final investments = ref.watch(investmentsProvider).value ?? const [];
  return investments.fold(0, (sum, i) => sum + i.currentValue);
});

class InvestmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Investment investment) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(investmentRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => investment.id.isEmpty
          ? repo.createInvestment(householdId, investment)
          : repo.updateInvestment(householdId, investment),
    );
  }

  Future<void> delete(String investmentId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(investmentRepositoryProvider).deleteInvestment(householdId, investmentId),
    );
  }
}

final investmentControllerProvider =
    AsyncNotifierProvider<InvestmentController, void>(
  InvestmentController.new,
);
