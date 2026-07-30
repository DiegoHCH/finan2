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

/// Whether this device already has [householdId]'s data encryption key -
/// false right after a reinstall, or on a second device that joined pasting
/// only the short code without the key half. Drives the "pegar código para
/// desbloquear montos" prompt in Settings.
final householdHasKeyProvider =
    FutureProvider.family<bool, String>((ref, householdId) {
  return ref.watch(householdCryptoProvider).hasKey(householdId);
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
                // Never falls back to the email - a person's identity in the
                // UI should always read as a name, never an email address.
                displayName: user.displayName ?? 'Yo',
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
                // Never falls back to the email - a person's identity in the
                // UI should always read as a name, never an email address.
                displayName: user.displayName ?? 'Yo',
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

  /// Imports the data encryption key from the full `<code>.<key>` string a
  /// partner shares, for a device that's already a member of [householdId]
  /// but never got the key locally (reinstall, new device, or it joined
  /// pasting only the short code). Unlike [joinHousehold] this never touches
  /// Firestore membership - the device is already a member, only its local
  /// key is missing. Returns a Spanish error message, or null on success.
  Future<String?> importMissingKey({
    required String householdId,
    required String pastedCode,
  }) async {
    final parts = pastedCode.trim().split('.');
    if (parts.length < 2 || parts[1].isEmpty) {
      return 'Ese código no trae la llave (falta la parte después del punto).';
    }
    if (parts.first.toUpperCase() != householdId.toUpperCase()) {
      return 'Ese código no es de este hogar.';
    }
    await ref.read(householdCryptoProvider).importKey(householdId, parts[1]);
    ref.invalidate(householdHasKeyProvider(householdId));
    return null;
  }

  /// Wraps this device's key for [householdId] under a new 6-digit [pin] and
  /// saves it to Firestore as a cross-device recovery path. Returns a
  /// Spanish error message, or null on success. Callers should gate this
  /// behind reauthentication (see `reauthenticate` in
  /// `core/widgets/finan2_reauth.dart`) - anyone who can set this PIN can
  /// later use it, from any device, to read every amount in the household.
  Future<String?> setPin({
    required String householdId,
    required String pin,
  }) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'El PIN debe tener exactamente 6 dígitos.';
    }
    final PinWrappedKey wrapped;
    try {
      wrapped = await ref.read(householdCryptoProvider).wrapKeyWithPin(householdId, pin);
    } on Finan2CryptoException catch (e) {
      return e.message;
    }
    await ref.read(householdRepositoryProvider).setPinRecovery(householdId, wrapped);
    return null;
  }

  /// Tries to recover this device's missing key for [householdId] using the
  /// household's backup PIN. Returns a Spanish message describing what
  /// happened (wrong PIN, locked out, no PIN configured), or null on
  /// success.
  Future<String?> recoverKeyWithPin({
    required String householdId,
    required String pin,
  }) async {
    final repo = ref.read(householdRepositoryProvider);
    var recovery = await repo.getPinRecovery(householdId);
    if (recovery == null) {
      return 'Tu pareja no ha configurado un PIN de respaldo para este '
          'hogar todavía.';
    }
    if (recovery.isLocked) {
      final minutes = recovery.lockedUntil!.difference(DateTime.now()).inMinutes + 1;
      return 'Demasiados intentos fallidos. Intenta de nuevo en $minutes '
          'minuto${minutes == 1 ? '' : 's'}.';
    }
    if (recovery.lockedUntil != null) {
      // A previous lockout already expired - clear it before this attempt.
      await repo.resetPinAttemptsIfLockExpired(householdId, recovery);
      recovery = await repo.getPinRecovery(householdId);
    }

    final wrapped = PinWrappedKey(
      salt: recovery!.salt,
      ciphertext: recovery.wrappedKey,
    );
    final unwrapped = await ref
        .read(householdCryptoProvider)
        .tryUnwrapKeyWithPin(householdId, pin, wrapped);
    if (unwrapped) {
      ref.invalidate(householdHasKeyProvider(householdId));
      return null;
    }

    await repo.recordFailedPinAttempt(householdId, recovery);
    final attemptsLeft = 3 - (recovery.attempts + 1);
    return attemptsLeft > 0
        ? 'PIN incorrecto. Te queda${attemptsLeft == 1 ? '' : 'n'} '
            '$attemptsLeft intento${attemptsLeft == 1 ? '' : 's'} antes de '
            'bloquear por 1 hora.'
        : 'PIN incorrecto. Se bloqueó por 1 hora tras demasiados intentos '
            'fallidos.';
  }

  /// Updates the signed-in member's own display name, both in Firebase Auth
  /// (so it's correct the next time they create/join a household) and on
  /// the current household's memberInfo (so "Registrado por" etc. update
  /// immediately without needing to leave/rejoin).
  Future<void> updateMyName(String name) async {
    final user = ref.read(authStateChangesProvider).value;
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateDisplayName(name);
      if (householdId != null) {
        await ref
            .read(householdRepositoryProvider)
            .updateMemberName(householdId, user.uid, name);
      }
      return ref.read(currentHouseholdProvider).value;
    });
  }
}

final householdControllerProvider =
    AsyncNotifierProvider<HouseholdController, Household?>(
  HouseholdController.new,
);
