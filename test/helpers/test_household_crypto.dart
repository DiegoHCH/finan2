import 'package:finan2/core/crypto/household_crypto.dart';

/// In-memory [Finan2KeyStore] so tests never touch platform-channel secure
/// storage (which isn't mocked in plain `flutter_test` unit tests).
class InMemoryKeyStore implements Finan2KeyStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

/// A [HouseholdCrypto] backed by [InMemoryKeyStore], with a key already
/// generated for [householdId] - the one-liner every Firestore-backed repo
/// test needs to encrypt/decrypt amounts without touching real storage.
Future<HouseholdCrypto> testHouseholdCrypto(String householdId) async {
  final crypto = HouseholdCrypto(keyStore: InMemoryKeyStore());
  await crypto.generateKey(householdId);
  return crypto;
}
