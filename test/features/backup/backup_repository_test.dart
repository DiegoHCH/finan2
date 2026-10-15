import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/backup/data/backup_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

const _hid = 'h1';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late BackupRepository repo;

  CollectionReference<Map<String, dynamic>> col(String name, [String hid = _hid]) =>
      firestore.collection('households').doc(hid).collection(name);

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_hid);
    repo = BackupRepository(firestore: firestore, crypto: crypto);
    await col('transactions').doc('mine').set({
      'amount': 'x' * 40,
      'description': 'Mercado',
      'date': Timestamp.fromDate(DateTime(2026, 10, 5)),
      'createdBy': 'u1',
      'paidBy': 'u1',
      'tags': ['casa'],
    });
    await col('transactions').doc('partner').set({
      'amount': 'y' * 40,
      'description': 'Arriendo',
      'date': Timestamp.fromDate(DateTime(2026, 10, 1)),
      'createdBy': 'u2',
    });
    await col('savingsGoals').doc('g').set({
      'name': 'Viaje',
      'contributions': [
        {'date': Timestamp.fromDate(DateTime(2026, 9, 1)), 'amount': 'z' * 40, 'createdBy': 'u2'},
      ],
      'createdBy': 'u1',
    });
    await col('recurringDone').doc('recurring_b_2026_10').set({
      'doneAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
    });
    await col('fcmTokens').doc('tok').set({'uid': 'u1'});
  });

  test('the file names its household but hides the data', () async {
    final file = await repo.create(_hid, now: DateTime.utc(2026, 10, 15, 12));
    final info = repo.inspect(file);
    expect(info.householdId, _hid);
    expect(info.createdAt.toUtc(), DateTime.utc(2026, 10, 15, 12));
    final text = utf8.decode(file);
    expect(text, isNot(contains('Mercado')));
    expect(text, isNot(contains('tok')));
  });

  test('restoring puts back changed and deleted documents and drops new ones', () async {
    final file = await repo.create(_hid);
    await col('transactions').doc('mine').update({'description': 'Cambiado'});
    await col('transactions').doc('partner').delete();
    await col('transactions').doc('new').set({'description': 'Después', 'createdBy': 'u1'});
    await col('recurringDone').doc('recurring_b_2026_10').delete();

    final result = await repo.restore(_hid, file, currentUid: 'u1');

    final txs = {for (final d in (await col('transactions').get()).docs) d.id: d.data()};
    expect(txs.keys.toSet(), {'mine', 'partner'});
    expect(txs['mine']!['description'], 'Mercado');
    expect(txs['mine']!['tags'], ['casa']);
    expect(txs['mine']!['date'], Timestamp.fromDate(DateTime(2026, 10, 5)));
    // Recreated by u1: the rules wouldn't let u1 create it as u2's.
    expect(txs['partner']!['createdBy'], 'u1');
    expect(txs['partner']!['paidBy'], 'u2');
    expect((await col('recurringDone').doc('recurring_b_2026_10').get()).exists, isTrue);
    final goal = (await col('savingsGoals').doc('g').get()).data()!;
    expect((goal['contributions'] as List).single['date'], Timestamp.fromDate(DateTime(2026, 9, 1)));
    expect(result.removed, 1);
    expect(result.reattributed, 1);
  });

  test('records still there keep their author', () async {
    final file = await repo.create(_hid);
    await repo.restore(_hid, file, currentUid: 'u1');
    expect((await col('transactions').doc('partner').get()).data()!['createdBy'], 'u2');
  });

  test("another household's backup is refused before decrypting", () async {
    final file = await repo.create(_hid);
    await crypto.generateKey('h2');
    expect(
      () => repo.restore('h2', file, currentUid: 'u1'),
      throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('otro hogar'))),
    );
  });

  test('a tampered file is refused and nothing is written', () async {
    final outer = jsonDecode(utf8.decode(await repo.create(_hid))) as Map<String, dynamic>;
    final sealed = base64Url.decode(outer['data'] as String);
    sealed[20] ^= 1;
    outer['data'] = base64Url.encode(sealed);
    await col('transactions').doc('new').set({'createdBy': 'u1'});

    await expectLater(
      repo.restore(_hid, utf8.encode(jsonEncode(outer)), currentUid: 'u1'),
      throwsA(isA<BackupException>()),
    );
    expect((await col('transactions').doc('new').get()).exists, isTrue);
  });

  test('a file that is not a backup says so', () {
    expect(
      () => repo.inspect(utf8.encode('Fecha,Monto\n')),
      throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('no es una copia'))),
    );
  });
}
