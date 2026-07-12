import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thrown when a household's data encryption key isn't available on this
/// device - e.g. someone joined pasting only the short invite code, without
/// the key suffix that normally rides along with it.
class Finan2CryptoException implements Exception {
  const Finan2CryptoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Where [HouseholdCrypto] persists each household's key. Kept as an
/// interface (rather than calling [FlutterSecureStorage] directly) so tests
/// can inject an in-memory fake instead of hitting platform channels.
abstract class Finan2KeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class _SecureKeyStore implements Finan2KeyStore {
  const _SecureKeyStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// Encrypts/decrypts a household's money fields with AES-256-GCM.
///
/// The key lives only on-device (Keychain/Keystore via
/// [FlutterSecureStorage]) and is shared between the 2 household members by
/// riding along with the invite code (see `HouseholdRepository`) - it is
/// never written to Firestore, so nobody with admin access to the
/// Firebase/GCP console can read raw amounts.
class HouseholdCrypto {
  HouseholdCrypto({Finan2KeyStore? keyStore})
      : _keyStore = keyStore ?? const _SecureKeyStore();

  final Finan2KeyStore _keyStore;
  static final _algorithm = AesGcm.with256bits();

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

  Future<SecretKey> _keyFor(String householdId) async {
    final encoded = await _keyStore.read(_storageKey(householdId));
    if (encoded == null) {
      throw const Finan2CryptoException(
        'Este dispositivo no tiene la llave para ver los montos de este '
        'hogar. Pide a tu pareja el código de invitación completo.',
      );
    }
    return SecretKey(base64Url.decode(encoded));
  }

  Future<String> encryptAmount(String householdId, int amount) async {
    final key = await _keyFor(householdId);
    final secretBox = await _algorithm.encrypt(
      utf8.encode(amount.toString()),
      secretKey: key,
    );
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
}
