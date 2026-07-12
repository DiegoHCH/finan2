import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryKeyStore implements Finan2KeyStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

void main() {
  late _InMemoryKeyStore store;
  late HouseholdCrypto crypto;

  setUp(() {
    store = _InMemoryKeyStore();
    crypto = HouseholdCrypto(keyStore: store);
  });

  test('generateKey then encrypt/decrypt round-trips the amount', () async {
    await crypto.generateKey('h1');

    final packed = await crypto.encryptAmount('h1', 1250000);
    expect(packed, isNot(contains('1250000')));

    final decrypted = await crypto.decryptAmount('h1', packed);
    expect(decrypted, 1250000);
  });

  test('a key imported from a partner decrypts what the creator encrypted', () async {
    final exported = await crypto.generateKey('h1');

    final partnerCrypto = HouseholdCrypto(keyStore: _InMemoryKeyStore());
    await partnerCrypto.importKey('h1', exported);

    final packed = await crypto.encryptAmount('h1', 42000);
    final decrypted = await partnerCrypto.decryptAmount('h1', packed);
    expect(decrypted, 42000);
  });

  test('hasKey reflects whether a key was generated or imported', () async {
    expect(await crypto.hasKey('h1'), isFalse);
    await crypto.generateKey('h1');
    expect(await crypto.hasKey('h1'), isTrue);
  });

  test('decrypting without a key throws Finan2CryptoException', () async {
    expect(
      () => crypto.decryptAmount('unknown-household', 'anything'),
      throwsA(isA<Finan2CryptoException>()),
    );
  });

  test('two different households never share a key', () async {
    await crypto.generateKey('h1');
    await crypto.generateKey('h2');

    final packed = await crypto.encryptAmount('h1', 99);
    expect(
      () => crypto.decryptAmount('h2', packed),
      throwsA(anything),
    );
  });
}
