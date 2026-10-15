import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import '../domain/entities/pending_bill.dart';
import '../domain/entities/recurring_bill.dart';
import '../domain/repositories/pending_bill_store.dart';
import 'recurring_bill_mapper.dart';

class RecurringBillRepository implements PendingBillStore {
  RecurringBillRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _bills(String householdId) =>
      _db.collection('households').doc(householdId).collection('recurringBills');

  Stream<List<RecurringBill>> watchBills(String householdId) {
    return _bills(householdId)
        .orderBy('dayOfMonth')
        .snapshots()
        .decryptEach((doc) => recurringBillFromFirestore(doc, _crypto, householdId));
  }

  Future<String> createBill(String householdId, RecurringBill bill) async {
    final doc = await _bills(householdId).add(await bill.toFirestore(_crypto, householdId));
    return doc.id;
  }

  Future<void> updateBill(String householdId, RecurringBill bill) async {
    await _bills(householdId).doc(bill.id).update(await bill.toFirestore(_crypto, householdId));
  }

  Future<void> deleteBill(String householdId, String billId) {
    return _bills(householdId).doc(billId).delete();
  }

  /// Dates the Worker found due while no one had the app open.
  Stream<List<PendingBill>> watchPending(String householdId) {
    return _db
        .collection('households')
        .doc(householdId)
        .collection('pendingBills')
        .snapshots()
        .map((snap) => [for (final doc in snap.docs) pendingBillFromFirestore(doc)]);
  }

  @override
  Future<void> deletePending(String householdId, String id) {
    return _db
        .collection('households')
        .doc(householdId)
        .collection('pendingBills')
        .doc(id)
        .delete();
  }
}
