import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/accounts/data/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

void main() {
  test('counts every record that moves money through an account', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = AccountRepository(
      firestore: firestore,
      crypto: await testHouseholdCrypto('h1'),
    );
    Future<void> add(String collection, Map<String, dynamic> data) =>
        firestore.collection('households/h1/$collection').add(data);

    await add('transactions', {'accountId': 'nequi'});
    await add('transfers', {'fromAccountId': 'nequi', 'toAccountId': 'banco'});
    await add('transfers', {'fromAccountId': 'banco', 'toAccountId': 'nequi'});
    await add('cardPayments', {'fromAccountId': 'nequi'});
    await add('recurringBills', {'accountId': 'nequi'});
    await add('transactions', {'accountId': 'banco'});

    expect(await repository.usage('h1', 'nequi'), 5);
    expect(await repository.usage('h1', 'efectivo'), 0);
  });
}
