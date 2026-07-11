import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_challenge_model.dart';
import '../../data/savings_challenge_repository.dart';

final savingsChallengeRepositoryProvider = Provider<SavingsChallengeRepository>((ref) {
  return SavingsChallengeRepository();
});

final savingsChallengeProvider = StreamProvider<SavingsChallenge?>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(null);
  return ref.watch(savingsChallengeRepositoryProvider).watchChallenge(householdId);
});

class SavingsChallengeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> create(String name, List<int> cellAmounts) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsChallengeRepositoryProvider).createChallenge(
            householdId,
            SavingsChallenge(
              id: '',
              name: name,
              cellAmounts: cellAmounts,
              done: List.filled(cellAmounts.length, false),
            ),
          ),
    );
  }

  Future<void> toggleCell(String challengeId, List<bool> newDone) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(savingsChallengeRepositoryProvider)
          .updateDone(householdId, challengeId, newDone),
    );
  }

  Future<void> delete(String challengeId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(savingsChallengeRepositoryProvider)
          .deleteChallenge(householdId, challengeId),
    );
  }
}

final savingsChallengeControllerProvider =
    AsyncNotifierProvider<SavingsChallengeController, void>(
  SavingsChallengeController.new,
);
