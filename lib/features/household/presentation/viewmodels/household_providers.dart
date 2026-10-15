import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/crypto/recovery_phrase.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
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
final householdHasKeyProvider = FutureProvider.family<bool, String>((ref, householdId) {
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

  Future<void> createHousehold({required String householdName}) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    final setup = ref.read(householdSetupProvider.notifier)..expect();
    state = await AsyncValue.guard(() async {
      final (household, inviteCode) = await ref
          .read(householdRepositoryProvider)
          .createHousehold(
            uid: user.uid,
            // Never falls back to the email - a person's identity in the
            // UI should always read as a name, never an email address.
            displayName: user.displayName ?? 'Yo',
            householdName: householdName,
          );
      final key = await ref.read(householdCryptoProvider).generateKey(household.id);
      lastShareCode = '$inviteCode.$key';
      setup.ready(lastShareCode!);
      // Separate write: the category rules check membership against the
      // household as stored, so it has to exist first. Not worth failing
      // the household over - categories can always be added by hand.
      try {
        await ref.read(categoryRepositoryProvider).addDefaults(household.id, user.uid);
      } on FirebaseException {
        // Offline or denied: the household is created all the same.
      }
      return household;
    });
    if (state.hasError) setup.finish();
  }

  Future<void> joinHousehold({required String code}) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final parts = code.trim().split('.');
    final joinCode = parts.first;
    final key = parts.length > 1 ? parts[1] : null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final household = await ref
          .read(householdRepositoryProvider)
          .joinHousehold(
            code: joinCode,
            uid: user.uid,
            // Never falls back to the email - a person's identity in the
            // UI should always read as a name, never an email address.
            displayName: user.displayName ?? 'Yo',
          );
      if (key != null && HouseholdCrypto.isWellFormedKey(key)) {
        await ref.read(householdCryptoProvider).importKey(household.id, key);
        joinedWithoutKey = false;
      } else {
        joinedWithoutKey = !await ref.read(householdCryptoProvider).hasKey(household.id);
      }
      return household;
    });
  }

  /// Imports the data encryption key from a shared `<code>.<key>` string,
  /// for a device that's already a member of [householdId] but never got the
  /// key locally (reinstall, new device, or it joined pasting only the short
  /// code). Any prefix works - an invite or the household's own ID - since
  /// only the key half matters here. Returns a user-facing error message,
  /// or null on success.
  Future<String?> importMissingKey({
    required String householdId,
    required String pastedCode,
  }) async {
    final key = pastedCode.trim().split('.').last;
    if (!HouseholdCrypto.isWellFormedKey(key)) {
      return currentL10n.householdKeyIncomplete;
    }
    final sample = await ref.read(householdRepositoryProvider).sampleCiphertext(householdId);
    if (sample != null && !await HouseholdCrypto.keyOpens(key, sample)) {
      return currentL10n.householdKeyWrongHousehold;
    }
    await ref.read(householdCryptoProvider).importKey(householdId, key);
    ref.invalidate(householdHasKeyProvider(householdId));
    return null;
  }

  /// A fresh invite for [householdId] as the full `<invite>.<key>` string to
  /// share, or null if this device doesn't have the key to pass along.
  Future<String?> createInvite(String householdId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return null;
    final key = await ref.read(householdCryptoProvider).exportKey(householdId);
    if (key == null) return null;
    final code = await ref.read(householdRepositoryProvider).createInvite(householdId, user.uid);
    return '$code.$key';
  }

  /// `<householdId>.<key>`, for a partner who's already a member but lost
  /// the key on their device - it unlocks amounts but lets nobody join.
  Future<String?> keyShareCode(String householdId) async {
    final key = await ref.read(householdCryptoProvider).exportKey(householdId);
    return key == null ? null : '$householdId.$key';
  }

  /// Generates a new recovery phrase and wraps this device's key under it,
  /// without saving anything yet - the screen shows the phrase first and
  /// only calls [saveRecoveryPhrase] once the user has written it down, so
  /// the old phrase never stops working before the new one is known.
  /// Throws [Finan2CryptoException] if this device doesn't have the key.
  Future<(RecoveryPhrase, WrappedKey)> prepareRecoveryPhrase(String householdId) async {
    final phrase = await RecoveryPhrase.generate();
    final wrapped = await ref
        .read(householdCryptoProvider)
        .wrapKeyWithRecoveryPhrase(householdId, phrase);
    return (phrase, wrapped);
  }

  /// Saves [wrapped] as the household's recovery copy, replacing any
  /// previous phrase or PIN. Callers should gate the whole flow behind
  /// reauthentication (see `reauthenticate` in
  /// `core/widgets/finan2_reauth.dart`) - anyone holding the phrase can
  /// read every amount in the household.
  Future<void> saveRecoveryPhrase(String householdId, WrappedKey wrapped) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) throw StateError('Not signed in');
    await ref.read(householdRepositoryProvider).setKeyRecovery(householdId, user.uid, wrapped);
  }

  /// Tries to recover this device's missing key for [householdId] with the
  /// typed recovery [input]. Returns a user-facing message describing what
  /// went wrong, or null on success.
  Future<String?> recoverKeyWithPhrase({required String householdId, required String input}) async {
    final RecoveryPhrase phrase;
    try {
      phrase = await RecoveryPhrase.parse(input);
    } on RecoveryPhraseFormatException catch (e) {
      return e.message;
    }
    final recovery = await ref.read(householdRepositoryProvider).getKeyRecovery(householdId);
    if (recovery == null) {
      return currentL10n.householdRecoveryNotSet;
    }
    final unwrapped = await ref
        .read(householdCryptoProvider)
        .tryUnwrapKeyWithRecoveryPhrase(householdId, phrase, recovery.wrapped);
    if (!unwrapped) {
      return currentL10n.householdRecoveryPhraseMismatch;
    }
    ref.invalidate(householdHasKeyProvider(householdId));
    return null;
  }

  /// Leaves [householdId] - deleting it with all its data if this is the
  /// last member - and forgets this device's key for it.
  Future<void> leaveHousehold(String householdId) async {
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    await ref.read(householdRepositoryProvider).leaveHousehold(householdId, uid);
    await ref.read(householdCryptoProvider).deleteKey(householdId);
  }

  /// Leaves the current household (see [leaveHousehold]) and deletes the
  /// signed-in user. Must be called right after a successful
  /// reauthentication.
  Future<void> deleteAccount() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId != null) await leaveHousehold(householdId);
    await ref.read(authRepositoryProvider).deleteAccount();
  }

  /// Throws on failure - the settings screens show it in an error sheet.
  Future<void> updateSettings(
    String householdId, {
    String? currency,
    int? startYear,
    String? weekStartsOn,
  }) {
    return ref
        .read(householdRepositoryProvider)
        .updateSettings(
          householdId,
          currency: currency,
          startYear: startYear,
          weekStartsOn: weekStartsOn,
        );
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
        await ref.read(householdRepositoryProvider).updateMemberName(householdId, user.uid, name);
      }
      return ref.read(currentHouseholdProvider).value;
    });
  }
}

final householdControllerProvider = AsyncNotifierProvider<HouseholdController, Household?>(
  HouseholdController.new,
);

/// The setup after creating a household (HouseholdSetupScreen). The home
/// screen opens it - the create/join screen is gone by then, replaced as
/// soon as the household exists - and holds its own first-run sheets (the
/// notification primer) while [active].
typedef HouseholdSetupState = ({bool active, String? shareCode});

final householdSetupProvider = NotifierProvider<HouseholdSetup, HouseholdSetupState>(
  HouseholdSetup.new,
);

class HouseholdSetup extends Notifier<HouseholdSetupState> {
  @override
  HouseholdSetupState build() => (active: false, shareCode: null);

  /// Before the household exists, so the home screen knows it's coming.
  void expect() => state = (active: true, shareCode: null);

  /// [shareCode] is what the setup ends up inviting the partner with.
  void ready(String shareCode) => state = (active: true, shareCode: shareCode);

  void finish() => state = (active: false, shareCode: null);
}
