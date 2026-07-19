import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/household/data/household_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = HouseholdRepository(firestore: firestore);
  });

  test('updateMemberName only changes that member\'s name, not others', () async {
    final household = await repository.createHousehold(
      uid: 'u1',
      displayName: 'diego@example.com',
      householdName: 'Casa',
    );
    await repository.joinHousehold(code: household.id, uid: 'u2', displayName: 'Vale');

    await repository.updateMemberName(household.id, 'u1', 'Diego');

    final doc = await firestore.collection('households').doc(household.id).get();
    final memberInfo = doc.data()!['memberInfo'] as Map;
    expect((memberInfo['u1'] as Map)['name'], 'Diego');
    expect((memberInfo['u2'] as Map)['name'], 'Vale');
  });
}
