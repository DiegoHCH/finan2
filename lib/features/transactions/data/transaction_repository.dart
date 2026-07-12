import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'transaction_model.dart';

class TransactionRepository {
  TransactionRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _transactions(
    String householdId,
  ) =>
      _db.collection('households').doc(householdId).collection(
            'transactions',
          );

  Stream<List<Movement>> watchTransactions(
    String householdId, {
    required int year,
    required int month,
  }) {
    return _transactions(householdId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snap) => Future.wait(
              snap.docs.map(
                (doc) => Movement.fromFirestore(doc, _crypto, householdId),
              ),
            ));
  }

  Stream<List<Movement>> watchTransactionsForYear(
    String householdId, {
    required int year,
  }) {
    return _transactions(householdId)
        .where('year', isEqualTo: year)
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snap) => Future.wait(
              snap.docs.map(
                (doc) => Movement.fromFirestore(doc, _crypto, householdId),
              ),
            ));
  }

  Future<void> createTransaction(String householdId, Movement tx) async {
    await _transactions(householdId).add(
      await tx.toFirestore(_crypto, householdId),
    );
  }

  /// Writes [tx] under the deterministic [id] only if no document with that
  /// ID already exists - used by recurring_bill_scanner.dart so re-scanning
  /// never creates a duplicate Movement for the same bill/month.
  Future<void> createIfAbsent(String householdId, String id, Movement tx) async {
    final ref = _transactions(householdId).doc(id);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set(await tx.toFirestore(_crypto, householdId));
  }

  Future<void> updateTransaction(String householdId, Movement tx) async {
    await _transactions(householdId).doc(tx.id).update(
          await tx.toFirestore(_crypto, householdId),
        );
  }

  Future<void> deleteTransaction(String householdId, String txId) {
    return _transactions(householdId).doc(txId).delete();
  }
}
