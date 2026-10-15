import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'account_model.dart';

class AccountRepository {
  AccountRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _accounts(String householdId) =>
      _db.collection('households').doc(householdId).collection('accounts');

  Stream<List<Account>> watchAccounts(String householdId) {
    return _accounts(householdId).orderBy('name').snapshots().asyncMap(
          (snap) => Future.wait(
            snap.docs.map(
              (doc) => Account.fromFirestore(doc, _crypto, householdId),
            ),
          ),
        );
  }

  /// Returns the new account's generated ID.
  Future<String> createAccount(String householdId, Account account) async {
    final doc = await _accounts(householdId).add(
      await account.toFirestore(_crypto, householdId),
    );
    return doc.id;
  }

  Future<void> updateAccount(String householdId, Account account) async {
    await _accounts(householdId).doc(account.id).update(
          await account.toFirestore(_crypto, householdId),
        );
  }

  /// How many records still move money through [accountId]: movements,
  /// transfers in either direction, card payments and recurring bills.
  Future<int> usage(String householdId, String accountId) async {
    final household = _db.collection('households').doc(householdId);
    final queries = [
      household.collection('transactions').where('accountId', isEqualTo: accountId),
      household.collection('transfers').where('fromAccountId', isEqualTo: accountId),
      household.collection('transfers').where('toAccountId', isEqualTo: accountId),
      household.collection('cardPayments').where('fromAccountId', isEqualTo: accountId),
      household.collection('recurringBills').where('accountId', isEqualTo: accountId),
    ];
    var total = 0;
    for (final query in queries) {
      total += (await query.count().get()).count ?? 0;
    }
    return total;
  }

  Future<void> deleteAccount(String householdId, String accountId) {
    return _accounts(householdId).doc(accountId).delete();
  }
}
