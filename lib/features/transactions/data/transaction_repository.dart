import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'transaction_model.dart';
import '../../../core/observability/error_reporter.dart';

class TransactionRepository {
  TransactionRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _transactions(String householdId) =>
      _db.collection('households').doc(householdId).collection('transactions');

  CollectionReference<Map<String, dynamic>> _accounts(String householdId) =>
      _db.collection('households').doc(householdId).collection('accounts');

  CollectionReference<Map<String, dynamic>> _debts(String householdId) =>
      _db.collection('households').doc(householdId).collection('debts');

  CollectionReference<Map<String, dynamic>> _budgets(String householdId) =>
      _db.collection('households').doc(householdId).collection('budgets');

  CollectionReference<Map<String, dynamic>> _budgetAlerts(String householdId) =>
      _db.collection('households').doc(householdId).collection('budgetAlerts');

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
  DocumentReference<Map<String, dynamic>>? _sourceRef(String householdId, Movement tx) {
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

  /// Recomputes real spend vs. planned for [categoryId]/[year]/[month] and
  /// persists a plaintext `overCategoryIds` flag on `budgetAlerts/{year}_
  /// {month}` - amounts stay encrypted, but "is this category over budget"
  /// is readable without the household's key. This is what lets the
  /// Cloudflare Worker's cron (cloudflare/finan2-notifications/worker.js)
  /// send the "te pasaste del presupuesto" push even with every device
  /// closed - the flag is already fresh as of whoever last wrote a
  /// transaction, since only a client (with the key) can compute it.
  /// Best-effort: a failure here must never block the transaction write.
  Future<void> _refreshBudgetAlert(
    String householdId,
    String categoryId,
    int year,
    int month,
  ) async {
    if (categoryId.isEmpty) return;
    try {
      final budgetDoc = await _budgets(householdId).doc('${year}_$month').get();
      final plannedPacked = budgetDoc.data()?[categoryId] as String?;
      if (plannedPacked == null) return;
      final planned = await _crypto.decryptAmount(householdId, plannedPacked);
      if (planned <= 0) return;

      final txSnap = await _transactions(householdId)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .where('categoryId', isEqualTo: categoryId)
          .get();
      var real = 0;
      for (final doc in txSnap.docs) {
        final tx = await Movement.fromFirestore(doc, _crypto, householdId);
        if (tx.isIncome) continue;
        real += tx.amount;
      }

      final alertRef = _budgetAlerts(householdId).doc('${year}_$month');
      await alertRef.set({
        'overCategoryIds': real > planned
            ? FieldValue.arrayUnion([categoryId])
            : FieldValue.arrayRemove([categoryId]),
      }, SetOptions(merge: true));
    } catch (e, st) {
      // Best-effort - the transaction itself already succeeded.
      ErrorReporter.recoverable(e, st, reason: 'budget alert flag not refreshed');
    }
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
        .decryptEach((doc) => Movement.fromFirestore(doc, _crypto, householdId));
  }

  Stream<List<Movement>> watchTransactionsForYear(String householdId, {required int year}) {
    return _transactions(householdId)
        .where('year', isEqualTo: year)
        .orderBy('date', descending: true)
        .snapshots()
        .decryptEach((doc) => Movement.fromFirestore(doc, _crypto, householdId));
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
          'balance': await _crypto.encryptAmount(householdId, balance + _sourceDelta(tx)),
        });
      }
    });
    await _refreshBudgetAlert(householdId, tx.categoryId, tx.date.year, tx.date.month);
  }

  /// Writes [tx] under the deterministic [id] only if no document with that
  /// ID already exists - used by recurring_bill_scanner.dart so re-scanning
  /// never creates a duplicate Movement for the same bill/month. Adjusts the
  /// balance the same way [createTransaction] does, only when the document
  /// is actually created.
  ///
  /// [recurring]: [id] is a recurring bill's occurrence. It's only generated
  /// once ever - a `recurringDone` marker outlives the movement, so deleting
  /// it doesn't bring it back - and the Worker's `pendingBills` marker for
  /// it, if any, is cleared.
  Future<void> createIfAbsent(
    String householdId,
    String id,
    Movement tx, {
    bool recurring = false,
  }) async {
    final ref = _transactions(householdId).doc(id);
    final household = _db.collection('households').doc(householdId);
    final doneRef = household.collection('recurringDone').doc(id);
    final pendingRef = household.collection('pendingBills').doc(id);
    final sourceRef = _sourceRef(householdId, tx);
    final data = await tx.toFirestore(_crypto, householdId);
    var wasCreated = false;

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final done = recurring && (await transaction.get(doneRef)).exists;
      final sourceSnap = snap.exists || done || sourceRef == null
          ? null
          : await transaction.get(sourceRef);
      if (recurring) {
        transaction.delete(pendingRef);
        if (!done) transaction.set(doneRef, {'doneAt': FieldValue.serverTimestamp()});
      }
      if (snap.exists || done) return;

      transaction.set(ref, data);
      wasCreated = true;
      if (sourceSnap != null && sourceSnap.exists) {
        final balance = await _decryptBalance(sourceSnap, householdId);
        transaction.update(sourceRef!, {
          'balance': await _crypto.encryptAmount(householdId, balance + _sourceDelta(tx)),
        });
      }
    });
    if (wasCreated) {
      await _refreshBudgetAlert(householdId, tx.categoryId, tx.date.year, tx.date.month);
    }
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
    Movement? capturedOldTx;

    await _db.runTransaction((transaction) async {
      final oldSnap = await transaction.get(txRef);
      final oldTx = oldSnap.exists
          ? await Movement.fromFirestore(oldSnap, _crypto, householdId)
          : null;
      capturedOldTx = oldTx;
      final oldRef = oldTx == null ? null : _sourceRef(householdId, oldTx);
      final oldDelta = oldTx == null ? 0 : _sourceDelta(oldTx);
      final samePath = oldRef?.path == newRef?.path;

      // All reads must happen before any writes in a Firestore transaction.
      final newSnap = newRef == null ? null : await transaction.get(newRef);
      final oldSourceSnap = (samePath || oldRef == null) ? null : await transaction.get(oldRef);

      transaction.update(txRef, data);

      if (samePath) {
        if (newRef != null && newSnap != null && newSnap.exists) {
          final balance = await _decryptBalance(newSnap, householdId);
          transaction.update(newRef, {
            'balance': await _crypto.encryptAmount(householdId, balance - oldDelta + newDelta),
          });
        }
      } else {
        if (oldRef != null && oldSourceSnap != null && oldSourceSnap.exists) {
          final oldBalance = await _decryptBalance(oldSourceSnap, householdId);
          transaction.update(oldRef, {
            'balance': await _crypto.encryptAmount(householdId, oldBalance - oldDelta),
          });
        }
        if (newRef != null && newSnap != null && newSnap.exists) {
          final newBalance = await _decryptBalance(newSnap, householdId);
          transaction.update(newRef, {
            'balance': await _crypto.encryptAmount(householdId, newBalance + newDelta),
          });
        }
      }
    });

    await _refreshBudgetAlert(householdId, tx.categoryId, tx.date.year, tx.date.month);
    final oldTx = capturedOldTx;
    if (oldTx != null &&
        (oldTx.categoryId != tx.categoryId ||
            oldTx.date.year != tx.date.year ||
            oldTx.date.month != tx.date.month)) {
      await _refreshBudgetAlert(householdId, oldTx.categoryId, oldTx.date.year, oldTx.date.month);
    }
  }

  /// Deletes the transaction with [txId] and, atomically, reverses its
  /// effect on its source's balance. If the account/card was deleted since,
  /// the balance step is simply skipped - nothing to reverse it on.
  Future<void> deleteTransaction(String householdId, String txId) async {
    final txRef = _transactions(householdId).doc(txId);
    Movement? deletedTx;

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(txRef);
      if (!snap.exists) {
        transaction.delete(txRef);
        return;
      }
      final oldTx = await Movement.fromFirestore(snap, _crypto, householdId);
      deletedTx = oldTx;
      final sourceRef = _sourceRef(householdId, oldTx);
      final sourceSnap = sourceRef == null ? null : await transaction.get(sourceRef);

      transaction.delete(txRef);

      if (sourceSnap != null && sourceSnap.exists) {
        final balance = await _decryptBalance(sourceSnap, householdId);
        transaction.update(sourceRef!, {
          'balance': await _crypto.encryptAmount(householdId, balance - _sourceDelta(oldTx)),
        });
      }
    });

    final oldTx = deletedTx;
    if (oldTx != null) {
      await _refreshBudgetAlert(householdId, oldTx.categoryId, oldTx.date.year, oldTx.date.month);
    }
  }
}
