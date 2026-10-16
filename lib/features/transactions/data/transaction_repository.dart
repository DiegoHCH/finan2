import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/balance/balance_ledger.dart';
import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import '../domain/entities/movement.dart';
import '../domain/repositories/movement_writer.dart';
import 'movement_mapper.dart';
import '../../../core/observability/error_reporter.dart';

class TransactionRepository implements MovementWriter {
  TransactionRepository({
    FirebaseFirestore? firestore,
    HouseholdCrypto? crypto,
    BalanceLedger? ledger,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _crypto = crypto ?? HouseholdCrypto(),
       _ledger = ledger ?? BalanceLedger(firestore: firestore, crypto: crypto);

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;
  final BalanceLedger _ledger;

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
        final tx = await movementFromFirestore(doc, _crypto, householdId);
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
        .decryptEach((doc) => movementFromFirestore(doc, _crypto, householdId));
  }

  /// The IDs of [year]/[month]'s movements written on this device that the
  /// server hasn't confirmed yet - Firestore's `hasPendingWrites`, kept out
  /// of [Movement] so the domain never sees snapshot metadata. The same
  /// query as [watchTransactions], so Firestore serves both from one listen.
  Stream<Set<String>> watchUnsyncedIds(
    String householdId, {
    required int year,
    required int month,
  }) {
    return _transactions(householdId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .orderBy('date', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => {
            for (final doc in snap.docs)
              if (doc.metadata.hasPendingWrites) doc.id,
          },
        )
        .distinct(_sameIds);
  }

  static bool _sameIds(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

  Stream<List<Movement>> watchTransactionsForYear(String householdId, {required int year}) {
    return _transactions(householdId)
        .where('year', isEqualTo: year)
        .orderBy('date', descending: true)
        .snapshots()
        .decryptEach((doc) => movementFromFirestore(doc, _crypto, householdId));
  }

  /// [tx]'s source and the signed change it makes to its balance, if any.
  List<(DocumentReference<Map<String, dynamic>>, int)> _effect(String householdId, Movement tx) {
    final source = _sourceRef(householdId, tx);
    return source == null ? const [] : [(source, _sourceDelta(tx))];
  }

  /// The alert flag is best-effort and offline its write would wait for the
  /// server: never hold the save for it.
  Future<void> _refreshBudgetAlertLater(String householdId, Movement tx) {
    final refresh = _refreshBudgetAlert(householdId, tx.categoryId, tx.date.year, tx.date.month);
    if (_ledger.waitForServer) return refresh;
    unawaited(refresh);
    return Future.value();
  }

  /// Creates [tx] and, in the same write, applies its effect on its
  /// account's or card-debt's balance. Works offline: it's queued on this
  /// device and sent when the connection is back. If the source no longer
  /// exists, the movement is still recorded - nothing to adjust.
  Future<void> createTransaction(String householdId, Movement tx) async {
    final txRef = _transactions(householdId).doc();
    final batch = _db.batch()..set(txRef, await tx.toFirestore(_crypto, householdId));
    await _ledger.commit(householdId, _effect(householdId, tx), batch: batch);
    await _refreshBudgetAlertLater(householdId, tx);
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
  ///
  /// «Only if absent» needs the server, so unlike a movement recorded by
  /// hand this one waits for a connection; the balance follows once it's in.
  @override
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
    final data = await tx.toFirestore(_crypto, householdId);
    var wasCreated = false;

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final done = recurring && (await transaction.get(doneRef)).exists;
      if (recurring) {
        transaction.delete(pendingRef);
        if (!done) transaction.set(doneRef, {'doneAt': FieldValue.serverTimestamp()});
      }
      if (snap.exists || done) return;

      transaction.set(ref, data);
      wasCreated = true;
    });
    if (wasCreated) {
      await _ledger.commit(householdId, _effect(householdId, tx));
      await _refreshBudgetAlertLater(householdId, tx);
    }
  }

  /// Updates [tx] and, in the same write, corrects the balance(s) it
  /// affects: reverses the previous amount/type/source's effect and applies
  /// the new one - a single net adjustment when the source didn't change, or
  /// a debit+credit across both sources when it did (including switching
  /// between an account and a card, or vice versa). Works offline.
  Future<void> updateTransaction(String householdId, Movement tx) async {
    final txRef = _transactions(householdId).doc(tx.id);
    final oldSnap = await BalanceLedger.cacheFirst(txRef);
    final oldTx = oldSnap.exists
        ? await movementFromFirestore(oldSnap, _crypto, householdId)
        : null;

    final batch = _db.batch()..update(txRef, await tx.toFirestore(_crypto, householdId));
    await _ledger.commit(householdId, [
      if (oldTx != null)
        for (final (ref, delta) in _effect(householdId, oldTx)) (ref, -delta),
      ..._effect(householdId, tx),
    ], batch: batch);

    await _refreshBudgetAlertLater(householdId, tx);
    if (oldTx != null &&
        (oldTx.categoryId != tx.categoryId ||
            oldTx.date.year != tx.date.year ||
            oldTx.date.month != tx.date.month)) {
      await _refreshBudgetAlertLater(householdId, oldTx);
    }
  }

  /// Deletes the transaction with [txId] and, in the same write, reverses
  /// its effect on its source's balance. If the account/card was deleted
  /// since, the balance step is simply skipped. Works offline.
  Future<void> deleteTransaction(String householdId, String txId) async {
    final txRef = _transactions(householdId).doc(txId);
    final snap = await BalanceLedger.cacheFirst(txRef);
    final oldTx = snap.exists ? await movementFromFirestore(snap, _crypto, householdId) : null;

    final batch = _db.batch()..delete(txRef);
    await _ledger.commit(householdId, [
      if (oldTx != null)
        for (final (ref, delta) in _effect(householdId, oldTx)) (ref, -delta),
    ], batch: batch);
    if (oldTx != null) await _refreshBudgetAlertLater(householdId, oldTx);
  }
}
