import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import '../../categories/data/category_model.dart';
import '../domain/entities/pending_bill.dart';
import '../domain/entities/recurring_bill.dart';

Future<RecurringBill> recurringBillFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
  HouseholdCrypto crypto,
  String householdId,
) async {
  final data = doc.data()!;
  return RecurringBill(
    id: doc.id,
    name: data['name'] as String? ?? '',
    type: CategoryTypeLabel.fromName(data['type'] as String? ?? 'factura'),
    categoryId: data['categoryId'] as String? ?? '',
    accountId: data['accountId'] as String? ?? '',
    amount: await crypto.decryptAmount(householdId, data['amount'] as String),
    dayOfMonth: (data['dayOfMonth'] as num?)?.toInt() ?? 1,
    frequency: RecurringFrequencyLabel.fromName(data['frequency'] as String?),
    startDate: (data['startDate'] as Timestamp?)?.toDate(),
    endDate: (data['endDate'] as Timestamp?)?.toDate(),
    paused: data['paused'] as bool? ?? false,
    resumedOn: (data['resumedOn'] as Timestamp?)?.toDate(),
    createdBy: data['createdBy'] as String? ?? '',
  );
}

extension RecurringBillFirestore on RecurringBill {
  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'name': name,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'amount': await crypto.encryptAmount(householdId, amount),
      'dayOfMonth': dayOfMonth,
      'frequency': frequency.name,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'paused': paused,
      'resumedOn': resumedOn == null ? null : Timestamp.fromDate(resumedOn!),
      'createdBy': createdBy,
    };
  }
}

/// The Worker writes the date as `YYYY-MM-DD` so no time zone gets in
/// the way.
PendingBill pendingBillFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? const {};
  final parsed = DateTime.tryParse(data['date'] as String? ?? '');
  return PendingBill(
    id: doc.id,
    billId: data['billId'] as String? ?? '',
    date: parsed == null ? DateTime(1970) : DateTime(parsed.year, parsed.month, parsed.day),
  );
}
