import 'package:finan2/features/app_lock/data/app_lock_cloud.dart';
import 'package:finan2/features/app_lock/data/app_lock_repository.dart';
import 'package:finan2/features/app_lock/domain/app_lock_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

void main() {
  group('AppLockPolicy', () {
    test('a PIN is exactly 4 digits', () {
      expect(AppLockPolicy.isValidPin('0420'), isTrue);
      expect(AppLockPolicy.isValidPin('042'), isFalse);
      expect(AppLockPolicy.isValidPin('04201'), isFalse);
      expect(AppLockPolicy.isValidPin('04a0'), isFalse);
    });

    test('5 free tries, then 30 s doubling up to 5 minutes', () {
      expect(AppLockPolicy.lockoutAfter(4), Duration.zero);
      expect(AppLockPolicy.lockoutAfter(5), const Duration(seconds: 30));
      expect(AppLockPolicy.lockoutAfter(6), const Duration(seconds: 60));
      expect(AppLockPolicy.lockoutAfter(8), const Duration(seconds: 240));
      expect(AppLockPolicy.lockoutAfter(9), const Duration(minutes: 5));
      expect(AppLockPolicy.lockoutAfter(40), const Duration(minutes: 5));
      expect(AppLockPolicy.attemptsLeft(3), 2);
      expect(AppLockPolicy.attemptsLeft(7), 0);
    });
  });

  group('AppLockRepository', () {
    late InMemoryKeyStore store;
    late DateTime now;
    late AppLockRepository repository;

    setUp(() {
      store = InMemoryKeyStore();
      now = DateTime(2026, 10, 21, 9);
      repository = AppLockRepository(store: store, now: () => now);
    });

    test('off until a PIN is set; the PIN itself is never stored', () async {
      expect((await repository.load()).enabled, isFalse);
      await repository.setPin('2580');
      final settings = await repository.load();
      expect(settings.enabled, isTrue);
      expect(settings.biometrics, isFalse);
      expect(await store.read('app_lock_pin'), isNot(contains('2580')));
    });

    test('the right PIN opens, a wrong one counts', () async {
      await repository.setPin('2580');
      final wrong = await repository.verify('1111');
      expect(wrong.ok, isFalse);
      expect(wrong.failures, 1);
      expect(wrong.lockedUntil, isNull);

      final right = await repository.verify('2580');
      expect(right.ok, isTrue);
      expect(await repository.failures(), 0);
    });

    test('the 5th wrong PIN makes it wait, even for the right one', () async {
      await repository.setPin('2580');
      for (var i = 0; i < 4; i++) {
        expect((await repository.verify('0000')).lockedUntil, isNull);
      }
      final fifth = await repository.verify('0000');
      expect(fifth.lockedUntil, now.add(const Duration(seconds: 30)));

      final meanwhile = await repository.verify('2580');
      expect(meanwhile.ok, isFalse, reason: 'not even checked while waiting');

      // A new repository (the app closed and opened) still waits.
      final reopened = AppLockRepository(store: store, now: () => now);
      expect(await reopened.lockedUntil(), isNotNull);

      now = now.add(const Duration(seconds: 31));
      expect((await repository.verify('2580')).ok, isTrue);
      expect(await repository.lockedUntil(), isNull);
    });

    test('each account on the phone has its own PIN', () async {
      final mine = AppLockRepository(account: 'ana', store: store, now: () => now);
      final theirs = AppLockRepository(account: 'luis', store: store, now: () => now);
      await mine.setPin('2580');
      expect((await mine.load()).enabled, isTrue);
      expect((await theirs.load()).enabled, isFalse);
      await theirs.setPin('1397');
      expect((await mine.verify('1397')).ok, isFalse);
      expect((await mine.verify('2580')).ok, isTrue);
    });

    test('changing the PIN keeps biometrics; clearing forgets everything', () async {
      await repository.setPin('2580');
      await repository.setBiometrics(true);
      await repository.setPin('1397');
      expect((await repository.load()).biometrics, isTrue);
      expect((await repository.verify('2580')).ok, isFalse);
      expect((await repository.verify('1397')).ok, isTrue);

      await repository.verify('0000');
      await repository.clear();
      expect((await repository.load()).enabled, isFalse);
      expect(await repository.failures(), 0);
      expect(await store.read('app_lock_biometrics'), isNull);
    });
  });

  group('the PIN follows the account to other phones', () {
    late _FakeCloud cloud;
    AppLockRepository phone() =>
        AppLockRepository(account: 'ana', cloud: cloud, store: InMemoryKeyStore());

    setUp(() => cloud = _FakeCloud());

    test('a PIN set on one phone opens the app on another', () async {
      final first = phone();
      await first.setPin('2580');
      await pumpEventQueue();

      final second = phone();
      final settings = await second.load();
      expect(settings.enabled, isTrue);
      expect(settings.onboarded, isFalse, reason: 'its own notifications and fingerprint still');
      expect((await second.verify('2580')).ok, isTrue);
    });

    test('a PIN changed on one phone is the PIN on the other next time', () async {
      final first = phone();
      final second = phone();
      await first.setPin('2580');
      await pumpEventQueue();
      await second.load();

      await first.setPin('1397');
      await pumpEventQueue();
      await second.load();
      expect((await second.verify('2580')).ok, isFalse);
      expect((await second.verify('1397')).ok, isTrue);
    });

    test('offline, the copy on the phone works', () async {
      final first = phone();
      await first.setPin('2580');
      await first.markOnboarded();
      cloud.offline = true;
      final settings = await first.load();
      expect(settings.enabled, isTrue);
      expect(settings.onboarded, isTrue);
      expect((await first.verify('2580')).ok, isTrue);
    });

    test('a PIN that never reached the cloud goes up, and then works elsewhere', () async {
      final store = InMemoryKeyStore();
      // Made before the PIN synced: the phone has it, the cloud doesn't.
      await AppLockRepository(account: 'ana', store: store).setPin('2580');
      expect(cloud.records, isEmpty);

      await AppLockRepository(account: 'ana', cloud: cloud, store: store).load();
      await pumpEventQueue();
      expect(cloud.records, contains('ana'));

      final other = phone();
      expect((await other.load()).enabled, isTrue);
      expect((await other.verify('2580')).ok, isTrue);
    });

    test('a PIN another phone forgot is not put back from this one', () async {
      final first = phone();
      final second = phone();
      await first.setPin('2580');
      await pumpEventQueue();
      await second.load();

      await first.clear();
      await pumpEventQueue();
      await second.load();
      await pumpEventQueue();
      expect(cloud.records, isEmpty);
    });

    test('«forgot your PIN?» clears it in the cloud too', () async {
      final first = phone();
      await first.setPin('2580');
      await pumpEventQueue();
      await first.clear();
      await pumpEventQueue();
      expect(cloud.records, isEmpty);
      expect((await phone().load()).enabled, isFalse);
    });
  });
}

class _FakeCloud implements AppLockCloud {
  final records = <String, String>{};
  var offline = false;

  @override
  Future<String?> fetch(String account) async {
    if (offline) throw StateError('offline');
    return records[account];
  }

  @override
  Future<void> save(String account, String record) async => records[account] = record;

  @override
  Future<void> delete(String account) async => records.remove(account);
}
