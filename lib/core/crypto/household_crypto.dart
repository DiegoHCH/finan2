import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../l10n/l10n.dart';
import 'recovery_phrase.dart';

/// Thrown when a household's data encryption key isn't available on this
/// device - e.g. someone joined pasting only the short invite code, without
/// the key suffix that normally rides along with it.
class Finan2CryptoException implements Exception {
  const Finan2CryptoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A household's data encryption key, wrapped under a [RecoveryPhrase] so it
/// can be stashed in Firestore as a cross-device recovery path without ever
/// exposing the raw key - [HouseholdCrypto.tryUnwrapKeyWithRecoveryPhrase] is
/// the only way back to something useful, and only with the right phrase.
/// [salt] isn't secret (it has to be readable to derive the wrapping key at
/// all); secrecy comes entirely from the phrase's 128 random bits.
class WrappedKey {
  const WrappedKey({required this.salt, required this.ciphertext});

  final String salt;
  final String ciphertext;
}

/// Where [HouseholdCrypto] persists each household's key. Kept as an
/// interface (rather than calling [FlutterSecureStorage] directly) so tests
/// can inject an in-memory fake instead of hitting platform channels.
abstract class Finan2KeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _SecureKeyStore implements Finan2KeyStore {
  const _SecureKeyStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Encrypts/decrypts a household's money fields with AES-256-GCM.
///
/// The key lives only on-device (Keychain/Keystore via
/// [FlutterSecureStorage]) and is shared between the 2 household members by
/// riding along with the invite code (see `HouseholdRepository`). The only
/// copy that ever reaches Firestore is the one wrapped under the household's
/// [RecoveryPhrase], which nobody - including an admin of the Firebase/GCP
/// project - can open without the phrase.
class HouseholdCrypto {
  HouseholdCrypto({Finan2KeyStore? keyStore}) : _keyStore = keyStore ?? const _SecureKeyStore();

  final Finan2KeyStore _keyStore;
  static final _algorithm = AesGcm.with256bits();
  // The phrase already carries 128 random bits, so a slow password KDF
  // would add nothing - HKDF just turns those bits into a wrapping key.
  static final _recoveryKdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  static final _recoveryKdfInfo = utf8.encode('finan2-recovery-v1');

  /// Length in bytes of a raw household key (AES-256).
  static const keyLength = 32;

  String _storageKey(String householdId) => 'household_dek_$householdId';

  /// Generates a fresh key for a newly-created household, persists it
  /// locally, and returns it base64url-encoded so it can be appended to the
  /// shareable invite code.
  Future<String> generateKey(String householdId) async {
    final key = await _algorithm.newSecretKey();
    final encoded = base64Url.encode(await key.extractBytes());
    await _keyStore.write(_storageKey(householdId), encoded);
    return encoded;
  }

  /// Persists a key received from a partner's invite code (the suffix after
  /// the dot in `CODE.KEY`).
  Future<void> importKey(String householdId, String encodedKey) {
    return _keyStore.write(_storageKey(householdId), encodedKey);
  }

  /// Whether [encodedKey] has the shape of a household key - catches a
  /// truncated paste before it gets stored and breaks every decryption.
  static bool isWellFormedKey(String encodedKey) {
    try {
      return base64Url.decode(encodedKey).length == keyLength;
    } on FormatException {
      return false;
    }
  }

  /// Whether [encodedKey] decrypts [packed] - checks a pasted key against
  /// the household's real data before storing it.
  static Future<bool> keyOpens(String encodedKey, String packed) async {
    try {
      final secretBox = SecretBox.fromConcatenation(
        base64Url.decode(packed),
        nonceLength: _algorithm.nonceLength,
        macLength: _algorithm.macAlgorithm.macLength,
      );
      await _algorithm.decrypt(secretBox, secretKey: SecretKey(base64Url.decode(encodedKey)));
      return true;
    } on SecretBoxAuthenticationError {
      return false;
    } on FormatException {
      return false;
    }
  }

  Future<bool> hasKey(String householdId) async {
    return await _keyStore.read(_storageKey(householdId)) != null;
  }

  /// This device's stored key for [householdId] (base64url-encoded, ready
  /// to append to a shareable invite code), or null if this device doesn't
  /// have one. Use this to re-share the existing key - never call
  /// [generateKey] again for a household that already has data encrypted
  /// under a key, or that data becomes undecryptable.
  Future<String?> exportKey(String householdId) {
    return _keyStore.read(_storageKey(householdId));
  }

  /// Forgets this device's key for [householdId] - after leaving the
  /// household, so nothing that could read its amounts stays behind.
  Future<void> deleteKey(String householdId) {
    return _keyStore.delete(_storageKey(householdId));
  }

  Future<SecretKey> _keyFor(String householdId) async {
    final encoded = await _keyStore.read(_storageKey(householdId));
    if (encoded == null) {
      throw Finan2CryptoException(currentL10n.errorMissingKey);
    }
    return SecretKey(base64Url.decode(encoded));
  }

  /// Seals [clear] under the household key, bound to [context] (and the
  /// household) so a sealed blob can't be passed off as a different kind of
  /// data or as another household's. Nonce, ciphertext and MAC together.
  Future<List<int>> seal(String householdId, String context, List<int> clear) async {
    final key = await _keyFor(householdId);
    final secretBox = await _algorithm.encrypt(
      clear,
      secretKey: key,
      aad: utf8.encode('$context:$householdId'),
    );
    return secretBox.concatenation();
  }

  /// Opens what [seal] produced. Throws [SecretBoxAuthenticationError] when
  /// the key, context or household don't match, or the bytes were altered.
  Future<List<int>> open(String householdId, String context, List<int> sealed) async {
    final key = await _keyFor(householdId);
    final secretBox = SecretBox.fromConcatenation(
      sealed,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    return _algorithm.decrypt(secretBox, secretKey: key, aad: utf8.encode('$context:$householdId'));
  }

  Future<String> encryptAmount(String householdId, int amount) async {
    final key = await _keyFor(householdId);
    final secretBox = await _algorithm.encrypt(utf8.encode(amount.toString()), secretKey: key);
    return base64Url.encode(secretBox.concatenation());
  }

  Future<int> decryptAmount(String householdId, String packed) async {
    final key = await _keyFor(householdId);
    final secretBox = SecretBox.fromConcatenation(
      base64Url.decode(packed),
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final clear = await _algorithm.decrypt(secretBox, secretKey: key);
    return int.parse(utf8.decode(clear));
  }

  /// Wraps this device's already-stored key for [householdId] under
  /// [phrase] so it can be saved to Firestore as a cross-device recovery
  /// path. Throws [Finan2CryptoException] if this device doesn't have the
  /// key either - there's nothing to wrap.
  Future<WrappedKey> wrapKeyWithRecoveryPhrase(String householdId, RecoveryPhrase phrase) async {
    final key = await _keyFor(householdId);
    final salt = _randomBytes(16);
    final kek = await _deriveRecoveryKek(phrase, salt);
    final secretBox = await _algorithm.encrypt(await key.extractBytes(), secretKey: kek);
    return WrappedKey(
      salt: base64Url.encode(salt),
      ciphertext: base64Url.encode(secretBox.concatenation()),
    );
  }

  /// Tries [phrase] against [wrapped]; if it's correct, persists the
  /// recovered key locally for [householdId] and returns true. Returns false
  /// (leaving local storage untouched) if the phrase doesn't open it.
  Future<bool> tryUnwrapKeyWithRecoveryPhrase(
    String householdId,
    RecoveryPhrase phrase,
    WrappedKey wrapped,
  ) async {
    final kek = await _deriveRecoveryKek(phrase, base64Url.decode(wrapped.salt));
    final secretBox = SecretBox.fromConcatenation(
      base64Url.decode(wrapped.ciphertext),
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final List<int> rawKey;
    try {
      rawKey = await _algorithm.decrypt(secretBox, secretKey: kek);
    } on SecretBoxAuthenticationError {
      return false;
    }
    await _keyStore.write(_storageKey(householdId), base64Url.encode(rawKey));
    return true;
  }

  Future<SecretKey> _deriveRecoveryKek(RecoveryPhrase phrase, List<int> salt) {
    return _recoveryKdf.deriveKey(
      secretKey: SecretKey(phrase.entropy),
      nonce: salt,
      info: _recoveryKdfInfo,
    );
  }

  List<int> _randomBytes(int length) {
    final rand = Random.secure();
    return List<int>.generate(length, (_) => rand.nextInt(256));
  }
}
