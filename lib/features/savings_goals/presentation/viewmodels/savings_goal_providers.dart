import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_goal_model.dart';
import '../../data/savings_goal_repository.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return SavingsGoalRepository();
});

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(savingsGoalRepositoryProvider).watchGoals(householdId);
});

/// Sum of every goal's current amount (contributions + accrued interest).
final totalSavedProvider = Provider<int>((ref) {
  final goals = ref.watch(savingsGoalsProvider).value ?? const [];
  final now = DateTime.now();
  return goals.fold(0, (sum, g) => sum + g.currentAmountAsOf(now));
});

class SavingsGoalController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(SavingsGoal goal) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(savingsGoalRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          goal.id.isEmpty ? repo.createGoal(householdId, goal) : repo.updateGoal(householdId, goal),
    );
  }

  Future<void> delete(String goalId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsGoalRepositoryProvider).deleteGoal(householdId, goalId),
    );
  }

  Future<void> addContribution(String goalId, int amount) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final user = ref.read(authStateChangesProvider).value;
    if (householdId == null || user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(savingsGoalRepositoryProvider)
          .addContribution(
            householdId,
            goalId,
            Contribution(date: DateTime.now(), amount: amount, createdBy: user.uid),
          ),
    );
  }
}

final savingsGoalControllerProvider = AsyncNotifierProvider<SavingsGoalController, void>(
  SavingsGoalController.new,
);
