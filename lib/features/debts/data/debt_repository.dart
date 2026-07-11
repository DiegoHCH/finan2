import 'package:cloud_firestore/cloud_firestore.dart';

import 'debt_model.dart';

class DebtRepository {
  DebtRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _debts(String householdId) =>
      _db.collection('households').doc(householdId).collection('debts');

  Stream<List<Debt>> watchDebts(String householdId) {
    return _debts(householdId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Debt.fromFirestore).toList(),
        );
  }

  /// Returns the new debt's generated ID.
  Future<String> createDebt(String householdId, Debt debt) async {
    final doc = await _debts(householdId).add(debt.toFirestore());
    return doc.id;
  }

  Future<void> updateDebt(String householdId, Debt debt) {
    return _debts(householdId).doc(debt.id).update(debt.toFirestore());
  }

  Future<void> deleteDebt(String householdId, String debtId) {
    return _debts(householdId).doc(debtId).delete();
  }
}
