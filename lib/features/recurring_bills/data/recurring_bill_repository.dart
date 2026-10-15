import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'recurring_bill_model.dart';

class RecurringBillRepository {
  RecurringBillRepository({
    FirebaseFirestore? firestore,
    HouseholdCrypto? crypto,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _bills(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('recurringBills');

  Stream<List<RecurringBill>> watchBills(String householdId) {
    return _bills(householdId)
        .orderBy('dayOfMonth')
        .snapshots()
        .asyncMap(
          (snap) => Future.wait(
            snap.docs.map(
              (doc) => RecurringBill.fromFirestore(doc, _crypto, householdId),
            ),
          ),
        );
  }

  Future<String> createBill(String householdId, RecurringBill bill) async {
    final doc = await _bills(
      householdId,
    ).add(await bill.toFirestore(_crypto, householdId));
    return doc.id;
  }

  Future<void> updateBill(String householdId, RecurringBill bill) async {
    await _bills(
      householdId,
    ).doc(bill.id).update(await bill.toFirestore(_crypto, householdId));
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
        .map((snap) => [for (final doc in snap.docs) PendingBill.fromFirestore(doc)]);
  }

  Future<void> deletePending(String householdId, String id) {
    return _db
        .collection('households')
        .doc(householdId)
        .collection('pendingBills')
        .doc(id)
        .delete();
  }
}

/// A recurring bill's occurrence the Worker left for a phone to register.
/// Its ID is the movement's - see RecurringBillScanner.movementIdFor.
class PendingBill {
  const PendingBill({required this.id, required this.billId, required this.date});

  final String id;
  final String billId;

  /// Local calendar day, no time.
  final DateTime date;

  /// The Worker writes the date as `YYYY-MM-DD` so no time zone gets in
  /// the way.
  factory PendingBill.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final parsed = DateTime.tryParse(data['date'] as String? ?? '');
    return PendingBill(
      id: doc.id,
      billId: data['billId'] as String? ?? '',
      date: parsed == null ? DateTime(1970) : DateTime(parsed.year, parsed.month, parsed.day),
    );
  }
}
