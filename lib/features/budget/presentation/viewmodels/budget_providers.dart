import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/year_month.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// categoryId -> planned amount for the current month - what the
/// notification scanner and Ajustes work from.
final currentMonthBudgetProvider = StreamProvider<Map<String, int>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const {});
  final now = currentYearMonth();
  return ref.watch(budgetRepositoryProvider).watchBudget(
    householdId,
    year: now.year,
    month: now.month,
  );
});

/// categoryId -> planned amount for any month, for Presupuesto while
/// browsing.
final budgetOfMonthProvider =
    StreamProvider.autoDispose.family<Map<String, int>, YearMonth>((ref, month) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const {});
  return ref.watch(budgetRepositoryProvider).watchBudget(
    householdId,
    year: month.year,
    month: month.month,
  );
});

class BudgetController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> setCategoryAmount(YearMonth month, String categoryId, int amount) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).setCategoryAmount(
        householdId,
        year: month.year,
        month: month.month,
        categoryId: categoryId,
        amount: amount,
      ),
    );
  }

  /// Fills [month]'s empty budget with the previous month's.
  Future<void> copyPreviousMonth(YearMonth month) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).copyBudget(
        householdId,
        from: month.plusMonths(-1),
        to: month,
      ),
    );
  }
}

final budgetControllerProvider = AsyncNotifierProvider<BudgetController, void>(
  BudgetController.new,
);
