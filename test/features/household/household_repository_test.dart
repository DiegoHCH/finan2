import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/household/data/household_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = HouseholdRepository(firestore: firestore);
  });

  DocumentReference<Map<String, dynamic>> householdDoc(String id) =>
      firestore.collection('households').doc(id);

  Future<String> createTwoMemberHousehold() async {
    final (household, code) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );
    await repository.joinHousehold(code: code, uid: 'u2', displayName: 'Vale');
    return household.id;
  }

  test('createHousehold uses an ID separate from a 10-character invite', () async {
    final (household, code) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );

    expect(code, hasLength(10));
    expect(household.id, isNot(code));
    final invite = await firestore.collection('invites').doc(code).get();
    expect(invite.data()!['householdId'], household.id);
    final data = (await householdDoc(household.id).get()).data()!;
    expect(data['createdBy'], 'u1');
    expect(data['activeInvite'], code);
  });

  test('a new household keeps when it was created, for dating movements', () async {
    final before = DateTime.now().subtract(const Duration(minutes: 1));
    final (household, _) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );

    final stored = await repository.watchHouseholdForUser('u1').first;
    expect(stored!.id, household.id);
    expect(stored.createdAt!.isAfter(before), isTrue);
  });

  test('joining consumes the invite and adds the member', () async {
    final (household, code) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );

    final joined = await repository.joinHousehold(
      code: code.toLowerCase(),
      uid: 'u2',
      displayName: 'Vale',
    );

    expect(joined.id, household.id);
    expect(joined.members, ['u1', 'u2']);
    expect((await firestore.collection('invites').doc(code).get()).exists, isFalse);
    expect((await householdDoc(household.id).get()).data()!['activeInvite'], isNull);
  });

  test('joining with an unknown or expired invite throws HouseholdNotFoundException', () async {
    expect(
      () => repository.joinHousehold(code: 'NOPE', uid: 'u2', displayName: 'Vale'),
      throwsA(isA<HouseholdNotFoundException>()),
    );

    final (household, code) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );
    await firestore.collection('invites').doc(code).update({
      'expiresAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 1))),
    });
    expect(
      () => repository.joinHousehold(code: code, uid: 'u2', displayName: 'Vale'),
      throwsA(isA<HouseholdNotFoundException>()),
    );
    expect((await householdDoc(household.id).get()).data()!['members'], ['u1']);
  });

  test('a new invite replaces the previous one', () async {
    final (household, first) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );

    final second = (await repository.createInvite(household.id, 'u1', inviterName: 'Diego')).code;

    expect(second, isNot(first));
    expect((await firestore.collection('invites').doc(first).get()).exists, isFalse);
    expect((await firestore.collection('invites').doc(second).get()).exists, isTrue);
    expect((await householdDoc(household.id).get()).data()!['activeInvite'], second);
  });

  test('opening the invite again shows the one already sent while it lasts', () async {
    final (household, sent) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa Hoyos',
    );

    final again = await repository.currentInvite(household.id, 'u1', inviterName: 'Diego');
    expect(again.code, sent);
    expect((await firestore.collection('invites').doc(sent).get()).exists, isTrue);

    // With under a day left it's replaced instead of sent again.
    await firestore.collection('invites').doc(sent).update({
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 5))),
    });
    final renewed = await repository.currentInvite(household.id, 'u1', inviterName: 'Diego');
    expect(renewed.code, isNot(sent));
    expect((await firestore.collection('invites').doc(sent).get()).exists, isFalse);
  });

  test('an invite says whose household it opens before joining', () async {
    final (household, code) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa Hoyos',
    );

    final preview = await repository.previewInvite(code.toLowerCase());
    expect(preview.householdName, 'Casa Hoyos');
    expect(preview.inviterName, 'Diego');
    // Looking doesn't join or use it up.
    expect((await householdDoc(household.id).get()).data()!['members'], ['u1']);
    expect((await firestore.collection('invites').doc(code).get()).exists, isTrue);

    await firestore.collection('invites').doc(code).update({
      'expiresAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 1))),
    });
    expect(() => repository.previewInvite(code), throwsA(isA<HouseholdNotFoundException>()));
    expect(() => repository.previewInvite('NOPE'), throwsA(isA<HouseholdNotFoundException>()));
  });

  test('updateMemberName only changes that member\'s name, not others', () async {
    final householdId = await createTwoMemberHousehold();

    await repository.updateMemberName(householdId, 'u1', 'Dieguito');

    final memberInfo = (await householdDoc(householdId).get()).data()!['memberInfo'] as Map;
    expect((memberInfo['u1'] as Map)['name'], 'Dieguito');
    expect((memberInfo['u2'] as Map)['name'], 'Vale');
  });

  test('leaving with a partner keeps the data but removes my tokens and prefs', () async {
    final householdId = await createTwoMemberHousehold();
    final doc = householdDoc(householdId);
    await doc.collection('fcmTokens').doc('t1').set({'token': 't1', 'uid': 'u1'});
    await doc.collection('fcmTokens').doc('t2').set({'token': 't2', 'uid': 'u2'});
    await doc.collection('memberPrefs').doc('u1').set({'dailyReminder': true});
    await doc.collection('memberPrefs').doc('u2').set({'dailyReminder': true});
    await doc.collection('transactions').doc('tx1').set({'createdBy': 'u1'});

    await repository.leaveHousehold(householdId, 'u1');

    final data = (await doc.get()).data()!;
    expect(data['members'], ['u2']);
    expect((data['memberInfo'] as Map).containsKey('u1'), isFalse);
    expect((await doc.collection('fcmTokens').get()).docs.map((d) => d.id), ['t2']);
    expect((await doc.collection('memberPrefs').get()).docs.map((d) => d.id), ['u2']);
    expect((await doc.collection('transactions').doc('tx1').get()).exists, isTrue);
  });

  test('the last member leaving deletes the household and every subcollection', () async {
    final (household, code) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );
    final doc = householdDoc(household.id);
    for (final name in householdSubcollections.where((n) => n != 'security')) {
      await doc.collection(name).doc('x').set({'createdBy': 'u1'});
    }
    await doc.collection('security').doc('recovery').set({'salt': 's'});

    await repository.leaveHousehold(household.id, 'u1');

    expect((await doc.get()).exists, isFalse);
    for (final name in householdSubcollections) {
      expect((await doc.collection(name).get()).docs, isEmpty, reason: name);
    }
    expect((await firestore.collection('invites').doc(code).get()).exists, isFalse);
  });

  test('setting a recovery wrap stores it', () async {
    final (household, _) = await repository.createHousehold(
      uid: 'u1',
      displayName: 'Diego',
      householdName: 'Casa',
    );

    await repository.setKeyRecovery(
      household.id,
      'u1',
      const WrappedKey(salt: 'salt', ciphertext: 'wrapped'),
    );

    final recovery = await repository.getKeyRecovery(household.id);
    expect(recovery?.salt, 'salt');
    expect(recovery?.wrappedKey, 'wrapped');
  });
}
