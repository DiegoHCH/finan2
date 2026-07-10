import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/household_model.dart';
import '../../data/household_repository.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository();
});

/// The signed-in user's household, or null if they haven't created/joined
/// one yet. Null (not an error) while signed out.
final currentHouseholdProvider = StreamProvider<Household?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(householdRepositoryProvider).watchHouseholdForUser(user.uid);
});

class HouseholdController extends AsyncNotifier<Household?> {
  @override
  FutureOr<Household?> build() => null;

  Future<void> createHousehold({
    required String householdName,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(householdRepositoryProvider).createHousehold(
            uid: user.uid,
            displayName: user.displayName ?? user.email ?? 'Yo',
            householdName: householdName,
          ),
    );
  }

  Future<void> joinHousehold({required String code}) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(householdRepositoryProvider).joinHousehold(
            code: code,
            uid: user.uid,
            displayName: user.displayName ?? user.email ?? 'Yo',
          ),
    );
  }
}

final householdControllerProvider =
    AsyncNotifierProvider<HouseholdController, Household?>(
  HouseholdController.new,
);
