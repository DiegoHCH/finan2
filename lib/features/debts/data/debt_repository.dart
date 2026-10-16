import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/balance/balance_ledger.dart';
import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import '../domain/entities/debt.dart';
import 'debt_mapper.dart';

class DebtRepository {
  DebtRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto, BalanceLedger? ledger})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto(),
      _ledger = ledger ?? BalanceLedger(firestore: firestore, crypto: crypto);

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;
  final BalanceLedger _ledger;

  CollectionReference<Map<String, dynamic>> _debts(String householdId) =>
      _db.collection('households').doc(householdId).collection('debts');

  Stream<List<Debt>> watchDebts(String householdId) {
    return _debts(householdId)
        .orderBy('name')
        .snapshots()
        .decryptEach((doc) => debtFromFirestore(doc, _crypto, householdId));
  }

  /// Returns the new debt's generated ID.
  Future<String> createDebt(String householdId, Debt debt) async {
    final doc = await _debts(householdId).add(await debt.toFirestore(_crypto, householdId));
    return doc.id;
  }

  /// [Debt.balance] is the whole balance; what each device moved stays in
  /// its share, so `balance` keeps the rest.
  Future<void> updateDebt(String householdId, Debt debt) async {
    final ref = _debts(householdId).doc(debt.id);
    final shares = await _ledger.sharesOf(householdId, ref);
    await ref.update({
      ...await debt.toFirestore(_crypto, householdId),
      'balance': await _crypto.encryptAmount(householdId, debt.balance - shares),
    });
  }

  Future<void> deleteDebt(String householdId, String debtId) {
    return _debts(householdId).doc(debtId).delete();
  }
}
