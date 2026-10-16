import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/balance/balance_ledger.dart';
import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import '../domain/entities/card_payment.dart';
import 'card_payment_mapper.dart';

class CardPaymentRepository {
  CardPaymentRepository({
    FirebaseFirestore? firestore,
    HouseholdCrypto? crypto,
    BalanceLedger? ledger,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _crypto = crypto ?? HouseholdCrypto(),
       _ledger = ledger ?? BalanceLedger(firestore: firestore, crypto: crypto);

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;
  final BalanceLedger _ledger;

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  Stream<List<CardPayment>> watchPayments(String householdId, String cardDebtId) {
    return _household(householdId)
        .collection('cardPayments')
        .where('cardDebtId', isEqualTo: cardDebtId)
        .orderBy('date', descending: true)
        .snapshots()
        .decryptEach((doc) => cardPaymentFromFirestore(doc, _crypto, householdId));
  }

  /// In one write: debits [CardPayment.fromAccountId], reduces
  /// [CardPayment.cardDebtId]'s balance and logs the payment. Works offline.
  Future<void> createPayment(String householdId, CardPayment payment) async {
    final household = _household(householdId);
    final batch = _db.batch()
      ..set(household.collection('cardPayments').doc(), await payment.toFirestore(_crypto, householdId));
    await _ledger.commit(householdId, [
      (household.collection('accounts').doc(payment.fromAccountId), -payment.amount),
      (household.collection('debts').doc(payment.cardDebtId), -payment.amount),
    ], batch: batch);
  }

  /// Reverses the balance change from [createPayment] and removes the
  /// record. If either the account or the card was deleted since, its
  /// balance is simply left alone (nothing to reverse it on).
  Future<void> deletePayment(String householdId, CardPayment payment) async {
    final household = _household(householdId);
    final batch = _db.batch()..delete(household.collection('cardPayments').doc(payment.id));
    await _ledger.commit(householdId, [
      (household.collection('accounts').doc(payment.fromAccountId), payment.amount),
      (household.collection('debts').doc(payment.cardDebtId), payment.amount),
    ], batch: batch);
  }
}
