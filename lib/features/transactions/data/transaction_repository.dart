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

  CollectionReference<Map<String, dynamic>> _accounts(String householdId) =>
      _db.collection('households').doc(householdId).collection('accounts');

  /// Decrypts an already-fetched account snapshot's `balance` field. Takes
  /// the snapshot (not a ref+get) so a Firestore transaction never reads the
  /// same document twice.
  Future<int> _decryptBalance(
    DocumentSnapshot<Map<String, dynamic>> snap,
    String householdId,
  ) async {
    final packed = snap.data()?['balance'] as String?;
    if (packed == null) return 0;
    return _crypto.decryptAmount(householdId, packed);
  }

  int _signedDelta(Movement tx) => tx.isIncome ? tx.amount : -tx.amount;

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

  /// Creates [tx] and, atomically, applies its effect on
  /// [Movement.accountId]'s balance (credit if income, debit otherwise). If
  /// the account no longer exists, the transaction is still recorded but the
  /// balance step is skipped - nothing to adjust.
  Future<void> createTransaction(String householdId, Movement tx) async {
    final txRef = _transactions(householdId).doc();
    final accountRef = _accounts(householdId).doc(tx.accountId);
    final data = await tx.toFirestore(_crypto, householdId);

    await _db.runTransaction((transaction) async {
      final accountSnap = await transaction.get(accountRef);

      transaction.set(txRef, data);
      if (accountSnap.exists) {
        final balance = await _decryptBalance(accountSnap, householdId);
        transaction.update(accountRef, {
          'balance': await _crypto.encryptAmount(
            householdId,
            balance + _signedDelta(tx),
          ),
        });
      }
    });
  }

  /// Writes [tx] under the deterministic [id] only if no document with that
  /// ID already exists - used by recurring_bill_scanner.dart so re-scanning
  /// never creates a duplicate Movement for the same bill/month. Adjusts the
  /// account balance the same way [createTransaction] does, only when the
  /// document is actually created.
  Future<void> createIfAbsent(String householdId, String id, Movement tx) async {
    final ref = _transactions(householdId).doc(id);
    final accountRef = _accounts(householdId).doc(tx.accountId);
    final data = await tx.toFirestore(_crypto, householdId);

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (snap.exists) return;
      final accountSnap = await transaction.get(accountRef);

      transaction.set(ref, data);
      if (accountSnap.exists) {
        final balance = await _decryptBalance(accountSnap, householdId);
        transaction.update(accountRef, {
          'balance': await _crypto.encryptAmount(
            householdId,
            balance + _signedDelta(tx),
          ),
        });
      }
    });
  }

  /// Updates [tx] and, atomically, corrects the balance(s) it affects:
  /// reverses the previous amount/type/account's effect and applies the new
  /// one - a single net adjustment when the account didn't change, or a
  /// debit+credit across both accounts when it did.
  Future<void> updateTransaction(String householdId, Movement tx) async {
    final txRef = _transactions(householdId).doc(tx.id);
    final newAccountRef = _accounts(householdId).doc(tx.accountId);
    final data = await tx.toFirestore(_crypto, householdId);
    final newDelta = _signedDelta(tx);

    await _db.runTransaction((transaction) async {
      final oldSnap = await transaction.get(txRef);
      final oldTx = oldSnap.exists
          ? await Movement.fromFirestore(oldSnap, _crypto, householdId)
          : null;
      final oldDelta = oldTx == null ? 0 : _signedDelta(oldTx);
      final sameAccount = oldTx?.accountId == tx.accountId;
      final oldAccountRef = (!sameAccount && oldTx != null && oldTx.accountId.isNotEmpty)
          ? _accounts(householdId).doc(oldTx.accountId)
          : null;

      // All reads must happen before any writes in a Firestore transaction.
      final newAccountSnap = await transaction.get(newAccountRef);
      final oldAccountSnap =
          oldAccountRef == null ? null : await transaction.get(oldAccountRef);

      transaction.update(txRef, data);

      if (sameAccount) {
        if (newAccountSnap.exists) {
          final balance = await _decryptBalance(newAccountSnap, householdId);
          transaction.update(newAccountRef, {
            'balance': await _crypto.encryptAmount(
              householdId,
              balance - oldDelta + newDelta,
            ),
          });
        }
      } else {
        if (oldAccountSnap != null && oldAccountSnap.exists) {
          final oldBalance = await _decryptBalance(oldAccountSnap, householdId);
          transaction.update(oldAccountRef!, {
            'balance': await _crypto.encryptAmount(
              householdId,
              oldBalance - oldDelta,
            ),
          });
        }
        if (newAccountSnap.exists) {
          final newBalance = await _decryptBalance(newAccountSnap, householdId);
          transaction.update(newAccountRef, {
            'balance': await _crypto.encryptAmount(
              householdId,
              newBalance + newDelta,
            ),
          });
        }
      }
    });
  }

  /// Deletes the transaction with [txId] and, atomically, reverses its
  /// effect on its account's balance. If the account was deleted since, the
  /// balance step is simply skipped - nothing to reverse it on.
  Future<void> deleteTransaction(String householdId, String txId) {
    final txRef = _transactions(householdId).doc(txId);
    return _db.runTransaction((transaction) async {
      final snap = await transaction.get(txRef);
      if (!snap.exists) {
        transaction.delete(txRef);
        return;
      }
      final oldTx = await Movement.fromFirestore(snap, _crypto, householdId);
      final accountRef =
          oldTx.accountId.isEmpty ? null : _accounts(householdId).doc(oldTx.accountId);
      final accountSnap = accountRef == null ? null : await transaction.get(accountRef);

      transaction.delete(txRef);

      if (accountSnap != null && accountSnap.exists) {
        final balance = await _decryptBalance(accountSnap, householdId);
        transaction.update(accountRef!, {
          'balance': await _crypto.encryptAmount(
            householdId,
            balance - _signedDelta(oldTx),
          ),
        });
      }
    });
  }
}
