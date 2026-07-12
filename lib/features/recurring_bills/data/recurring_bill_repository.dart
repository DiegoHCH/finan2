import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'recurring_bill_model.dart';

class RecurringBillRepository {
  RecurringBillRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _bills(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('recurringBills');

  Stream<List<RecurringBill>> watchBills(String householdId) {
    return _bills(householdId).orderBy('dayOfMonth').snapshots().asyncMap(
          (snap) => Future.wait(
            snap.docs.map(
              (doc) => RecurringBill.fromFirestore(doc, _crypto, householdId),
            ),
          ),
        );
  }

  Future<String> createBill(String householdId, RecurringBill bill) async {
    final doc = await _bills(householdId).add(
      await bill.toFirestore(_crypto, householdId),
    );
    return doc.id;
  }

  Future<void> updateBill(String householdId, RecurringBill bill) async {
    await _bills(householdId).doc(bill.id).update(
          await bill.toFirestore(_crypto, householdId),
        );
  }

  Future<void> deleteBill(String householdId, String billId) {
    return _bills(householdId).doc(billId).delete();
  }
}
