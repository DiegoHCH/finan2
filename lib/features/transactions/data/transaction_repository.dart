import 'package:cloud_firestore/cloud_firestore.dart';

import 'transaction_model.dart';

class TransactionRepository {
  TransactionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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
        .map((snap) => snap.docs.map(Movement.fromFirestore).toList());
  }

  Future<void> createTransaction(String householdId, Movement tx) {
    return _transactions(householdId).add(tx.toFirestore());
  }

  Future<void> updateTransaction(String householdId, Movement tx) {
    return _transactions(householdId).doc(tx.id).update(tx.toFirestore());
  }

  Future<void> deleteTransaction(String householdId, String txId) {
    return _transactions(householdId).doc(txId).delete();
  }
}
