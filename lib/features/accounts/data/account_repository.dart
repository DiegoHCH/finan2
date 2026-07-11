import 'package:cloud_firestore/cloud_firestore.dart';

import 'account_model.dart';

class AccountRepository {
  AccountRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _accounts(String householdId) =>
      _db.collection('households').doc(householdId).collection('accounts');

  Stream<List<Account>> watchAccounts(String householdId) {
    return _accounts(householdId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Account.fromFirestore).toList(),
        );
  }

  Future<void> createAccount(String householdId, Account account) {
    return _accounts(householdId).add(account.toFirestore());
  }

  Future<void> updateAccount(String householdId, Account account) {
    return _accounts(householdId).doc(account.id).update(account.toFirestore());
  }

  Future<void> deleteAccount(String householdId, String accountId) {
    return _accounts(householdId).doc(accountId).delete();
  }
}
