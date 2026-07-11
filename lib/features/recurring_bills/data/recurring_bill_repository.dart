import 'package:cloud_firestore/cloud_firestore.dart';

import 'recurring_bill_model.dart';

class RecurringBillRepository {
  RecurringBillRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _bills(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('recurringBills');

  Stream<List<RecurringBill>> watchBills(String householdId) {
    return _bills(householdId).orderBy('dayOfMonth').snapshots().map(
          (snap) => snap.docs.map(RecurringBill.fromFirestore).toList(),
        );
  }

  Future<String> createBill(String householdId, RecurringBill bill) async {
    final doc = await _bills(householdId).add(bill.toFirestore());
    return doc.id;
  }

  Future<void> updateBill(String householdId, RecurringBill bill) {
    return _bills(householdId).doc(bill.id).update(bill.toFirestore());
  }

  Future<void> deleteBill(String householdId, String billId) {
    return _bills(householdId).doc(billId).delete();
  }
}
