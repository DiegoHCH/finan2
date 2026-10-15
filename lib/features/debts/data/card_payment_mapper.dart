import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import '../domain/entities/card_payment.dart';

Future<CardPayment> cardPaymentFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
  HouseholdCrypto crypto,
  String householdId,
) async {
  final data = doc.data()!;
  final amount = await crypto.decryptAmount(householdId, data['amount'] as String);
  return CardPayment(
    id: doc.id,
    amount: amount,
    fromAccountId: data['fromAccountId'] as String? ?? '',
    cardDebtId: data['cardDebtId'] as String? ?? '',
    date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    createdBy: data['createdBy'] as String? ?? '',
  );
}

extension CardPaymentFirestore on CardPayment {
  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'amount': await crypto.encryptAmount(householdId, amount),
      'fromAccountId': fromAccountId,
      'cardDebtId': cardDebtId,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
    };
  }
}
