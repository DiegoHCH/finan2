import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/balance/balance_ledger.dart';
import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'account_model.dart';

class AccountRepository {
  AccountRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto, BalanceLedger? ledger})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto(),
      _ledger = ledger ?? BalanceLedger(firestore: firestore, crypto: crypto);

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;
  final BalanceLedger _ledger;

  CollectionReference<Map<String, dynamic>> _accounts(String householdId) =>
      _db.collection('households').doc(householdId).collection('accounts');

  Stream<List<Account>> watchAccounts(String householdId) {
    return _accounts(householdId)
        .orderBy('name')
        .snapshots()
        .decryptEach((doc) => Account.fromFirestore(doc, _crypto, householdId));
  }

  /// Returns the new account's generated ID.
  Future<String> createAccount(String householdId, Account account) async {
    final doc = await _accounts(householdId).add(await account.toFirestore(_crypto, householdId));
    return doc.id;
  }

  /// [Account.balance] is the whole balance; what each device moved stays
  /// in its share, so `balance` keeps the rest.
  Future<void> updateAccount(String householdId, Account account) async {
    final ref = _accounts(householdId).doc(account.id);
    final shares = await _ledger.sharesOf(householdId, ref);
    await ref.update({
      ...await account.toFirestore(_crypto, householdId),
      'balance': await _crypto.encryptAmount(householdId, account.balance - shares),
    });
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
