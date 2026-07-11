import 'package:cloud_firestore/cloud_firestore.dart';

import 'transfer_model.dart';

class TransferRepository {
  TransferRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  Stream<List<Transfer>> watchTransfers(String householdId) {
    return _household(householdId)
        .collection('transfers')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Transfer.fromFirestore).toList());
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
      final fromBalance = (fromSnap.data()?['balance'] as num?)?.toInt() ?? 0;
      final toBalance = (toSnap.data()?['balance'] as num?)?.toInt() ?? 0;

      tx.update(fromRef, {'balance': fromBalance - transfer.amount});
      tx.update(toRef, {'balance': toBalance + transfer.amount});
      tx.set(transferRef, transfer.toFirestore());
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
        final fromBalance = (fromSnap.data()?['balance'] as num?)?.toInt() ?? 0;
        tx.update(fromRef, {'balance': fromBalance + transfer.amount});
      }
      if (toSnap.exists) {
        final toBalance = (toSnap.data()?['balance'] as num?)?.toInt() ?? 0;
        tx.update(toRef, {'balance': toBalance - transfer.amount});
      }
      tx.delete(transferRef);
    });
  }
}
