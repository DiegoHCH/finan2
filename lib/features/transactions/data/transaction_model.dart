import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import '../../categories/data/category_model.dart';

class Movement {
  const Movement({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.description,
    required this.date,
    required this.createdBy,
    this.cardDebtId = '',
  });

  final String id;
  final int amount;
  final CategoryType type;
  final String categoryId;

  /// The Account this movement is paid from/into. Empty when [cardDebtId] is
  /// set instead - a movement targets exactly one of the two.
  final String accountId;

  /// A credit-card Debt this movement was charged to, instead of an Account.
  /// A gasto/factura/ahorro here increases what's owed on the card rather
  /// than debiting cash on hand; see TransactionRepository's signed delta.
  final String cardDebtId;
  final String description;
  final DateTime date;
  final String createdBy;

  bool get isIncome => type == CategoryType.ingreso;

  bool get isCardPurchase => cardDebtId.isNotEmpty;

  /// A plain factory can't be async, so this is a static method - callers
  /// use it identically (`Movement.fromFirestore(doc, crypto, householdId)`).
  /// [amount] is stored encrypted (see [HouseholdCrypto]), so decrypting it
  /// requires the household's on-device key.
  static Future<Movement> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final amount = await crypto.decryptAmount(
      householdId,
      data['amount'] as String,
    );
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
    );
  }

  Future<Map<String, dynamic>> toFirestore(
    HouseholdCrypto crypto,
    String householdId,
  ) async {
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
    };
  }
}
