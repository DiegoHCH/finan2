import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/core/crypto/recovery_phrase.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryKeyStore implements Finan2KeyStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
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

  test('deleteKey forgets the household key on this device', () async {
    await crypto.generateKey('h1');
    await crypto.deleteKey('h1');
    expect(await crypto.hasKey('h1'), isFalse);
  });

  test('isWellFormedKey accepts a real key and rejects a truncated one', () async {
    final key = await crypto.generateKey('h1');
    expect(HouseholdCrypto.isWellFormedKey(key), isTrue);
    expect(HouseholdCrypto.isWellFormedKey(key.substring(0, 20)), isFalse);
    expect(HouseholdCrypto.isWellFormedKey('not base64!'), isFalse);
  });

  test('keyOpens tells this household\'s key from another one', () async {
    final key = await crypto.generateKey('h1');
    final otherKey = await HouseholdCrypto(keyStore: _InMemoryKeyStore()).generateKey('h2');
    final packed = await crypto.encryptAmount('h1', 42);

    expect(await HouseholdCrypto.keyOpens(key, packed), isTrue);
    expect(await HouseholdCrypto.keyOpens(otherKey, packed), isFalse);
  });

  group('Recovery phrase:', () {
    test('the right phrase recovers a key onto a device that lost it', () async {
      await crypto.generateKey('h1');
      final packed = await crypto.encryptAmount('h1', 5000);
      final phrase = await RecoveryPhrase.generate();
      final wrapped = await crypto.wrapKeyWithRecoveryPhrase('h1', phrase);

      final recovered = HouseholdCrypto(keyStore: _InMemoryKeyStore());
      final typed = await RecoveryPhrase.parse(phrase.words.join(' '));
      final ok = await recovered.tryUnwrapKeyWithRecoveryPhrase('h1', typed, wrapped);

      expect(ok, isTrue);
      expect(await recovered.decryptAmount('h1', packed), 5000);
    });

    test('a different phrase fails without recovering anything', () async {
      await crypto.generateKey('h1');
      final wrapped = await crypto.wrapKeyWithRecoveryPhrase('h1', await RecoveryPhrase.generate());

      final recovered = HouseholdCrypto(keyStore: _InMemoryKeyStore());
      final ok = await recovered.tryUnwrapKeyWithRecoveryPhrase(
        'h1',
        await RecoveryPhrase.generate(),
        wrapped,
      );

      expect(ok, isFalse);
      expect(await recovered.hasKey('h1'), isFalse);
    });

    test('wrapping without a local key throws Finan2CryptoException', () async {
      expect(
        () async => crypto.wrapKeyWithRecoveryPhrase(
          'unknown-household',
          await RecoveryPhrase.generate(),
        ),
        throwsA(isA<Finan2CryptoException>()),
      );
    });
  });
}
