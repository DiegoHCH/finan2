import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  final String id;
  final int amount;
  final CategoryType type;
  final String categoryId;
  final String accountId;
  final String description;
  final DateTime date;
  final String createdBy;

  bool get isIncome => type == CategoryType.ingreso;

  factory Movement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Movement(
      id: doc.id,
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      type: CategoryTypeLabel.fromName(data['type'] as String? ?? 'gasto'),
      categoryId: data['categoryId'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: date,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'description': description,
      'date': Timestamp.fromDate(date),
      'year': date.year,
      'month': date.month,
      'createdBy': createdBy,
    };
  }
}
