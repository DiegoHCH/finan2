import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import '../../categories/data/category_model.dart';
import '../domain/entities/movement.dart';

/// [amount] is stored encrypted (see [HouseholdCrypto]), so decrypting it
/// requires the household's on-device key.
Future<Movement> movementFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
  HouseholdCrypto crypto,
  String householdId,
) async {
  final data = doc.data()!;
  final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
  final amount = await crypto.decryptAmount(householdId, data['amount'] as String);
  return Movement(
    id: doc.id,
    amount: amount,
    type: CategoryTypeLabel.fromName(data['type'] as String? ?? 'gasto'),
    categoryId: data['categoryId'] as String? ?? '',
    accountId: data['accountId'] as String? ?? '',
    cardDebtId: data['cardDebtId'] as String? ?? '',
    description: data['description'] as String? ?? '',
    date: date,
    createdBy: data['createdBy'] as String? ?? '',
    paidBy: data['paidBy'] as String? ?? '',
    tags: [for (final t in data['tags'] as List? ?? const []) t as String],
  );
}

extension MovementFirestore on Movement {
  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'amount': await crypto.encryptAmount(householdId, amount),
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'cardDebtId': cardDebtId,
      'description': description,
      'date': Timestamp.fromDate(date),
      'year': date.year,
      'month': date.month,
      'createdBy': createdBy,
      'paidBy': payer,
      'tags': tags,
    };
  }
}
