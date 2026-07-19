import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

/// A payment made toward a credit-card Debt from one of the household's own
/// accounts. Deliberately NOT a Movement (like Transfer) - it never counts
/// as income/expense, it just moves money from an account into paying down
/// what's owed on the card.
class CardPayment {
  const CardPayment({
    required this.id,
    required this.amount,
    required this.fromAccountId,
    required this.cardDebtId,
    required this.date,
    required this.createdBy,
  });

  final String id;
  final int amount;
  final String fromAccountId;
  final String cardDebtId;
  final DateTime date;
  final String createdBy;

  static Future<CardPayment> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    final amount = await crypto.decryptAmount(
      householdId,
      data['amount'] as String,
    );
    return CardPayment(
      id: doc.id,
      amount: amount,
      fromAccountId: data['fromAccountId'] as String? ?? '',
      cardDebtId: data['cardDebtId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    return {
      'amount': await crypto.encryptAmount(householdId, amount),
      'fromAccountId': fromAccountId,
      'cardDebtId': cardDebtId,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
    };
  }
}
