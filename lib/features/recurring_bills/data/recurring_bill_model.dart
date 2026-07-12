import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import '../../categories/data/category_model.dart';

/// A fixed monthly income or bill (salary, rent, utilities...) that
/// generates its own Movement each month once its day arrives - see
/// recurring_bill_scanner.dart. Only ingreso/factura make sense here (the
/// mockup only ever shows those 2), unlike ad-hoc gasto/ahorro spending.
class RecurringBill {
  const RecurringBill({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.amount,
    required this.dayOfMonth,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final CategoryType type;
  final String categoryId;
  final String accountId;
  final int amount;
  final int dayOfMonth;
  final String createdBy;

  static Future<RecurringBill> fromFirestore(
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
      amount: await crypto.decryptAmount(
        householdId,
        data['amount'] as String,
      ),
      dayOfMonth: (data['dayOfMonth'] as num?)?.toInt() ?? 1,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    return {
      'name': name,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'amount': await crypto.encryptAmount(householdId, amount),
      'dayOfMonth': dayOfMonth,
      'createdBy': createdBy,
    };
  }
}
