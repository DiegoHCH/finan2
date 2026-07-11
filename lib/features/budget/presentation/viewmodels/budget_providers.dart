import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// categoryId -> planned amount for the current month.
final currentMonthBudgetProvider = StreamProvider<Map<String, int>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const {});
  final now = DateTime.now();
  return ref.watch(budgetRepositoryProvider).watchBudget(
    householdId,
    year: now.year,
    month: now.month,
  );
});

class BudgetController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> setCategoryAmount(String categoryId, int amount) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final now = DateTime.now();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).setCategoryAmount(
        householdId,
        year: now.year,
        month: now.month,
        categoryId: categoryId,
        amount: amount,
      ),
    );
  }
}

final budgetControllerProvider = AsyncNotifierProvider<BudgetController, void>(
  BudgetController.new,
);
