import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

Movement _movement({String paidBy = ''}) => Movement(
      id: '',
      amount: 1000,
      type: CategoryType.gasto,
      categoryId: 'c',
      accountId: 'a',
      description: '',
      date: DateTime(2026, 10, 15),
      createdBy: 'u1',
      paidBy: paidBy,
    );

void main() {
  test('the payer defaults to whoever logged the movement', () {
    expect(_movement().payer, 'u1');
    expect(_movement(paidBy: 'u2').payer, 'u2');
  });

  test('the payer survives a round trip, and old docs without it read as the creator', () async {
    final crypto = await testHouseholdCrypto('h1');
    final firestore = FakeFirebaseFirestore();
    final ref = firestore.doc('households/h1/transactions/t1');

    await ref.set(await _movement(paidBy: 'u2').toFirestore(crypto, 'h1'));
    expect((await Movement.fromFirestore(await ref.get(), crypto, 'h1')).payer, 'u2');

    await ref.update({'paidBy': FieldValue.delete()});
    expect((await Movement.fromFirestore(await ref.get(), crypto, 'h1')).payer, 'u1');
  });
}
