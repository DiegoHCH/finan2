import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/utils/currency.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/household_model.dart';
import '../../data/household_repository.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository();
});

/// One [HouseholdCrypto] instance for the whole app - it's stateless besides
/// the secure-storage handle it wraps.
final householdCryptoProvider = Provider<HouseholdCrypto>((ref) {
  return HouseholdCrypto();
});

/// The signed-in user's household, or null if they haven't created/joined
/// one yet. Null (not an error) while signed out.
final currentHouseholdProvider = StreamProvider<Household?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(householdRepositoryProvider).watchHouseholdForUser(user.uid);
});

/// The household's currency code (e.g. "COP", "USD"), defaulting to
/// [defaultCurrency] until the household loads.
final currentCurrencyProvider = Provider<String>((ref) {
  return ref.watch(currentHouseholdProvider).value?.currency ?? defaultCurrency;
});

/// A ready-to-use formatter for the household's current currency - screens
/// call `ref.watch(moneyFormatterProvider)(amount)` instead of hardcoding COP.
final moneyFormatterProvider = Provider<String Function(num)>((ref) {
  final currency = ref.watch(currentCurrencyProvider);
  return (amount) => formatMoney(amount, currency);
});

class HouseholdController extends AsyncNotifier<Household?> {
  @override
  FutureOr<Household?> build() => null;

  /// Set right after [createHousehold] succeeds: `<code>.<key>`, the full
  /// string to share with a partner so their device also gets the data
  /// encryption key (never stored in Firestore). Screens read this once,
  /// immediately after creating.
  String? lastShareCode;

  /// Set right after [joinHousehold] succeeds, if the pasted code didn't
  /// include the trailing key - the partner joined the household but this
  /// device can't decrypt amounts yet.
  bool joinedWithoutKey = false;

  Future<void> createHousehold({
    required String householdName,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final household =
          await ref.read(householdRepositoryProvider).createHousehold(
                uid: user.uid,
                displayName: user.displayName ?? user.email ?? 'Yo',
                householdName: householdName,
              );
      final key =
          await ref.read(householdCryptoProvider).generateKey(household.id);
      lastShareCode = '${household.id}.$key';
      return household;
    });
  }

  Future<void> joinHousehold({required String code}) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final parts = code.trim().split('.');
    final joinCode = parts.first;
    final key = parts.length > 1 ? parts[1] : null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final household =
          await ref.read(householdRepositoryProvider).joinHousehold(
                code: joinCode,
                uid: user.uid,
                displayName: user.displayName ?? user.email ?? 'Yo',
              );
      if (key != null) {
        await ref
            .read(householdCryptoProvider)
            .importKey(household.id, key);
        joinedWithoutKey = false;
      } else {
        joinedWithoutKey =
            !await ref.read(householdCryptoProvider).hasKey(household.id);
      }
      return household;
    });
  }
}

final householdControllerProvider =
    AsyncNotifierProvider<HouseholdController, Household?>(
  HouseholdController.new,
);
