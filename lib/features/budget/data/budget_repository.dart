import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetRepository {
  BudgetRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _budgets(String householdId) =>
      _db.collection('households').doc(householdId).collection('budgets');

  String _docId(int year, int month) => '${year}_$month';

  /// Maps categoryId -> planned amount for the given month. Missing/never
  /// budgeted months just stream an empty map.
  Stream<Map<String, int>> watchBudget(
    String householdId, {
    required int year,
    required int month,
  }) {
    return _budgets(householdId).doc(_docId(year, month)).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) return const {};
      return data.map((key, value) => MapEntry(key, (value as num).toInt()));
    });
  }

  Future<void> setCategoryAmount(
    String householdId, {
    required int year,
    required int month,
    required String categoryId,
    required int amount,
  }) {
    return _budgets(householdId).doc(_docId(year, month)).set({
      categoryId: amount,
    }, SetOptions(merge: true));
  }
}
