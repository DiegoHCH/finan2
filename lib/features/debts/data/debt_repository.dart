import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'debt_model.dart';

class DebtRepository {
  DebtRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _debts(String householdId) =>
      _db.collection('households').doc(householdId).collection('debts');

  Stream<List<Debt>> watchDebts(String householdId) {
    return _debts(householdId)
        .orderBy('name')
        .snapshots()
        .decryptEach((doc) => Debt.fromFirestore(doc, _crypto, householdId));
  }

  /// Returns the new debt's generated ID.
  Future<String> createDebt(String householdId, Debt debt) async {
    final doc = await _debts(householdId).add(await debt.toFirestore(_crypto, householdId));
    return doc.id;
  }

  Future<void> updateDebt(String householdId, Debt debt) async {
    await _debts(householdId).doc(debt.id).update(await debt.toFirestore(_crypto, householdId));
  }

  Future<void> deleteDebt(String householdId, String debtId) {
    return _debts(householdId).doc(debtId).delete();
  }
}
