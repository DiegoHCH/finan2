import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'card_payment_model.dart';

class CardPaymentRepository {
  CardPaymentRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  Stream<List<CardPayment>> watchPayments(String householdId, String cardDebtId) {
    return _household(householdId)
        .collection('cardPayments')
        .where('cardDebtId', isEqualTo: cardDebtId)
        .orderBy('date', descending: true)
        .snapshots()
        .decryptEach((doc) => CardPayment.fromFirestore(doc, _crypto, householdId));
  }

  /// Decrypts an already-fetched account/debt snapshot's `balance` field.
  Future<int> _decryptBalance(
    DocumentSnapshot<Map<String, dynamic>> snap,
    String householdId,
  ) async {
    final packed = snap.data()?['balance'] as String?;
    if (packed == null) return 0;
    return _crypto.decryptAmount(householdId, packed);
  }

  /// Atomically: debits [CardPayment.fromAccountId], credits down (reduces)
  /// [CardPayment.cardDebtId]'s balance, and logs the payment - all 3 writes
  /// commit together or not at all.
  Future<void> createPayment(String householdId, CardPayment payment) {
    final household = _household(householdId);
    final accountRef = household.collection('accounts').doc(payment.fromAccountId);
    final debtRef = household.collection('debts').doc(payment.cardDebtId);
    final paymentRef = household.collection('cardPayments').doc();

    return _db.runTransaction((tx) async {
      final accountSnap = await tx.get(accountRef);
      final debtSnap = await tx.get(debtRef);

      if (accountSnap.exists) {
        final accountBalance = await _decryptBalance(accountSnap, householdId);
        tx.update(accountRef, {
          'balance': await _crypto.encryptAmount(householdId, accountBalance - payment.amount),
        });
      }
      if (debtSnap.exists) {
        final debtBalance = await _decryptBalance(debtSnap, householdId);
        tx.update(debtRef, {
          'balance': await _crypto.encryptAmount(householdId, debtBalance - payment.amount),
        });
      }
      tx.set(paymentRef, await payment.toFirestore(_crypto, householdId));
    });
  }

  /// Reverses the balance change from [createPayment] and removes the
  /// record. If either the account or the card was deleted since, its
  /// balance is simply left alone (nothing to reverse it on).
  Future<void> deletePayment(String householdId, CardPayment payment) {
    final household = _household(householdId);
    final accountRef = household.collection('accounts').doc(payment.fromAccountId);
    final debtRef = household.collection('debts').doc(payment.cardDebtId);
    final paymentRef = household.collection('cardPayments').doc(payment.id);

    return _db.runTransaction((tx) async {
      final accountSnap = await tx.get(accountRef);
      final debtSnap = await tx.get(debtRef);

      if (accountSnap.exists) {
        final accountBalance = await _decryptBalance(accountSnap, householdId);
        tx.update(accountRef, {
          'balance': await _crypto.encryptAmount(householdId, accountBalance + payment.amount),
        });
      }
      if (debtSnap.exists) {
        final debtBalance = await _decryptBalance(debtSnap, householdId);
        tx.update(debtRef, {
          'balance': await _crypto.encryptAmount(householdId, debtBalance + payment.amount),
        });
      }
      tx.delete(paymentRef);
    });
  }
}
