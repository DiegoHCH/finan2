import 'package:cloud_firestore/cloud_firestore.dart';

/// Moving money between two of the household's own accounts. Deliberately
/// NOT a Movement - it never counts as income/expense, so it lives in its
/// own collection instead of touching every place that reads `transactions`.
class Transfer {
  const Transfer({
    required this.id,
    required this.amount,
    required this.fromAccountId,
    required this.toAccountId,
    required this.date,
    required this.createdBy,
  });

  final String id;
  final int amount;
  final String fromAccountId;
  final String toAccountId;
  final DateTime date;
  final String createdBy;

  factory Transfer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Transfer(
      id: doc.id,
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      fromAccountId: data['fromAccountId'] as String? ?? '',
      toAccountId: data['toAccountId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
    };
  }
}
