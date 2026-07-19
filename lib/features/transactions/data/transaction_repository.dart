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

  CollectionReference<Map<String, dynamic>> _debts(String householdId) =>
      _db.collection('households').doc(householdId).collection('debts');

  /// Decrypts an already-fetched account/debt snapshot's `balance` field.
  /// Takes the snapshot (not a ref+get) so a Firestore transaction never
  /// reads the same document twice.
  Future<int> _decryptBalance(
    DocumentSnapshot<Map<String, dynamic>> snap,
    String householdId,
  ) async {
    final packed = snap.data()?['balance'] as String?;
    if (packed == null) return 0;
    return _crypto.decryptAmount(householdId, packed);
  }

  /// The account or card-debt [tx] pays from/into, or null if neither is set
  /// (e.g. the account it pointed to was deleted and the movement was left
  /// as-is).
  DocumentReference<Map<String, dynamic>>? _sourceRef(
    String householdId,
    Movement tx,
  ) {
    if (tx.isCardPurchase) return _debts(householdId).doc(tx.cardDebtId);
    if (tx.accountId.isNotEmpty) return _accounts(householdId).doc(tx.accountId);
    return null;
  }

  /// The signed change [tx] applies to its source's `balance`. For an
  /// account this is the familiar "income credits, expense debits". For a
  /// credit card it's inverted: a gasto doesn't touch cash on hand, it
  /// increases what's owed (and an ingreso - e.g. a refund - reduces it).
  int _sourceDelta(Movement tx) {
    final accountStyle = tx.isIncome ? tx.amount : -tx.amount;
    return tx.isCardPurchase ? -accountStyle : accountStyle;
  }

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

  /// Creates [tx] and, atomically, applies its effect on its account's or
  /// card-debt's balance. If the source no longer exists, the transaction is
  /// still recorded but the balance step is skipped - nothing to adjust.
  Future<void> createTransaction(String householdId, Movement tx) async {
    final txRef = _transactions(householdId).doc();
    final sourceRef = _sourceRef(householdId, tx);
    final data = await tx.toFirestore(_crypto, householdId);

    await _db.runTransaction((transaction) async {
      final sourceSnap = sourceRef == null ? null : await transaction.get(sourceRef);

      transaction.set(txRef, data);
      if (sourceSnap != null && sourceSnap.exists) {
        final balance = await _decryptBalance(sourceSnap, householdId);
        transaction.update(sourceRef!, {
          'balance': await _crypto.encryptAmount(
            householdId,
            balance + _sourceDelta(tx),
          ),
        });
      }
    });
  }

  /// Writes [tx] under the deterministic [id] only if no document with that
  /// ID already exists - used by recurring_bill_scanner.dart so re-scanning
  /// never creates a duplicate Movement for the same bill/month. Adjusts the
  /// balance the same way [createTransaction] does, only when the document
  /// is actually created.
  Future<void> createIfAbsent(String householdId, String id, Movement tx) async {
    final ref = _transactions(householdId).doc(id);
    final sourceRef = _sourceRef(householdId, tx);
    final data = await tx.toFirestore(_crypto, householdId);

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (snap.exists) return;
      final sourceSnap = sourceRef == null ? null : await transaction.get(sourceRef);

      transaction.set(ref, data);
      if (sourceSnap != null && sourceSnap.exists) {
        final balance = await _decryptBalance(sourceSnap, householdId);
        transaction.update(sourceRef!, {
          'balance': await _crypto.encryptAmount(
            householdId,
            balance + _sourceDelta(tx),
          ),
        });
      }
    });
  }

  /// Updates [tx] and, atomically, corrects the balance(s) it affects:
  /// reverses the previous amount/type/source's effect and applies the new
  /// one - a single net adjustment when the source didn't change, or a
  /// debit+credit across both sources when it did (including switching
  /// between an account and a card, or vice versa).
  Future<void> updateTransaction(String householdId, Movement tx) async {
    final txRef = _transactions(householdId).doc(tx.id);
    final newRef = _sourceRef(householdId, tx);
    final data = await tx.toFirestore(_crypto, householdId);
    final newDelta = _sourceDelta(tx);

    await _db.runTransaction((transaction) async {
      final oldSnap = await transaction.get(txRef);
      final oldTx = oldSnap.exists
          ? await Movement.fromFirestore(oldSnap, _crypto, householdId)
          : null;
      final oldRef = oldTx == null ? null : _sourceRef(householdId, oldTx);
      final oldDelta = oldTx == null ? 0 : _sourceDelta(oldTx);
      final samePath = oldRef?.path == newRef?.path;

      // All reads must happen before any writes in a Firestore transaction.
      final newSnap = newRef == null ? null : await transaction.get(newRef);
      final oldSourceSnap = (samePath || oldRef == null)
          ? null
          : await transaction.get(oldRef);

      transaction.update(txRef, data);

      if (samePath) {
        if (newRef != null && newSnap != null && newSnap.exists) {
          final balance = await _decryptBalance(newSnap, householdId);
          transaction.update(newRef, {
            'balance': await _crypto.encryptAmount(
              householdId,
              balance - oldDelta + newDelta,
            ),
          });
        }
      } else {
        if (oldRef != null && oldSourceSnap != null && oldSourceSnap.exists) {
          final oldBalance = await _decryptBalance(oldSourceSnap, householdId);
          transaction.update(oldRef, {
            'balance': await _crypto.encryptAmount(
              householdId,
              oldBalance - oldDelta,
            ),
          });
        }
        if (newRef != null && newSnap != null && newSnap.exists) {
          final newBalance = await _decryptBalance(newSnap, householdId);
          transaction.update(newRef, {
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
  /// effect on its source's balance. If the account/card was deleted since,
  /// the balance step is simply skipped - nothing to reverse it on.
  Future<void> deleteTransaction(String householdId, String txId) {
    final txRef = _transactions(householdId).doc(txId);
    return _db.runTransaction((transaction) async {
      final snap = await transaction.get(txRef);
      if (!snap.exists) {
        transaction.delete(txRef);
        return;
      }
      final oldTx = await Movement.fromFirestore(snap, _crypto, householdId);
      final sourceRef = _sourceRef(householdId, oldTx);
      final sourceSnap = sourceRef == null ? null : await transaction.get(sourceRef);

      transaction.delete(txRef);

      if (sourceSnap != null && sourceSnap.exists) {
        final balance = await _decryptBalance(sourceSnap, householdId);
        transaction.update(sourceRef!, {
          'balance': await _crypto.encryptAmount(
            householdId,
            balance - _sourceDelta(oldTx),
          ),
        });
      }
    });
  }
}
