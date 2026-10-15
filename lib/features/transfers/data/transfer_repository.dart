import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'transfer_model.dart';

class TransferRepository {
  TransferRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  Stream<List<Transfer>> watchTransfers(String householdId) {
    return _household(householdId)
        .collection('transfers')
        .orderBy('date', descending: true)
        .snapshots()
        .decryptEach((doc) => Transfer.fromFirestore(doc, _crypto, householdId));
  }

  /// Decrypts an already-fetched account snapshot's `balance` field. Takes
  /// the snapshot (not a ref+get) so a transaction never reads the same
  /// document twice.
  Future<int> _decryptBalance(
    DocumentSnapshot<Map<String, dynamic>> snap,
    String householdId,
  ) async {
    final packed = snap.data()?['balance'] as String?;
    if (packed == null) return 0;
    return _crypto.decryptAmount(householdId, packed);
  }

  /// Atomically: debits [Transfer.fromAccountId], credits
  /// [Transfer.toAccountId], and logs the transfer - all 3 writes commit
  /// together or not at all.
  Future<void> createTransfer(String householdId, Transfer transfer) {
    final household = _household(householdId);
    final fromRef = household.collection('accounts').doc(transfer.fromAccountId);
    final toRef = household.collection('accounts').doc(transfer.toAccountId);
    final transferRef = household.collection('transfers').doc();

    return _db.runTransaction((tx) async {
      final fromSnap = await tx.get(fromRef);
      final toSnap = await tx.get(toRef);
      final fromBalance = await _decryptBalance(fromSnap, householdId);
      final toBalance = await _decryptBalance(toSnap, householdId);

      tx.update(fromRef, {
        'balance': await _crypto.encryptAmount(householdId, fromBalance - transfer.amount),
      });
      tx.update(toRef, {
        'balance': await _crypto.encryptAmount(householdId, toBalance + transfer.amount),
      });
      tx.set(transferRef, await transfer.toFirestore(_crypto, householdId));
    });
  }

  /// Reverses the balance change from [createTransfer] and removes the
  /// record. If either account was deleted since the transfer happened,
  /// its balance is simply left alone (nothing to reverse it on).
  Future<void> deleteTransfer(String householdId, Transfer transfer) {
    final household = _household(householdId);
    final fromRef = household.collection('accounts').doc(transfer.fromAccountId);
    final toRef = household.collection('accounts').doc(transfer.toAccountId);
    final transferRef = household.collection('transfers').doc(transfer.id);

    return _db.runTransaction((tx) async {
      final fromSnap = await tx.get(fromRef);
      final toSnap = await tx.get(toRef);

      if (fromSnap.exists) {
        final fromBalance = await _decryptBalance(fromSnap, householdId);
        tx.update(fromRef, {
          'balance': await _crypto.encryptAmount(householdId, fromBalance + transfer.amount),
        });
      }
      if (toSnap.exists) {
        final toBalance = await _decryptBalance(toSnap, householdId);
        tx.update(toRef, {
          'balance': await _crypto.encryptAmount(householdId, toBalance - transfer.amount),
        });
      }
      tx.delete(transferRef);
    });
  }
}
