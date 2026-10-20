import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/balance/balance_ledger.dart';
import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'transfer_model.dart';

class TransferRepository {
  TransferRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto, BalanceLedger? ledger})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto(),
      _ledger = ledger ?? BalanceLedger(firestore: firestore, crypto: crypto);

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;
  final BalanceLedger _ledger;

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  Stream<List<Transfer>> watchTransfers(String householdId) {
    return _household(householdId)
        .collection('transfers')
        .orderBy('date', descending: true)
        .snapshots()
        .decryptEach((doc) => Transfer.fromFirestore(doc, _crypto, householdId));
  }

  /// In one write: debits [Transfer.fromAccountId], credits
  /// [Transfer.toAccountId] and logs the transfer. Works offline.
  Future<void> createTransfer(String householdId, Transfer transfer) async {
    final household = _household(householdId);
    final accounts = household.collection('accounts');
    final batch = _db.batch()
      ..set(
        household.collection('transfers').doc(),
        await transfer.toFirestore(_crypto, householdId),
      );
    await _ledger.commit(householdId, [
      (accounts.doc(transfer.fromAccountId), -transfer.amount),
      (accounts.doc(transfer.toAccountId), transfer.amount),
    ], batch: batch);
  }

  /// Reverses the balance change from [createTransfer] and removes the
  /// record. If either account was deleted since the transfer happened,
  /// its balance is simply left alone (nothing to reverse it on).
  Future<void> deleteTransfer(String householdId, Transfer transfer) async {
    final household = _household(householdId);
    final accounts = household.collection('accounts');
    final batch = _db.batch()..delete(household.collection('transfers').doc(transfer.id));
    await _ledger.commit(householdId, [
      (accounts.doc(transfer.fromAccountId), transfer.amount),
      (accounts.doc(transfer.toAccountId), -transfer.amount),
    ], batch: batch);
  }
}
