import 'package:cloud_firestore/cloud_firestore.dart';

import 'savings_goal_model.dart';

class SavingsGoalRepository {
  SavingsGoalRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _goals(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('savingsGoals');

  Stream<List<SavingsGoal>> watchGoals(String householdId) {
    return _goals(householdId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map(SavingsGoal.fromFirestore).toList(),
        );
  }

  /// Returns the new goal's generated ID.
  Future<String> createGoal(String householdId, SavingsGoal goal) async {
    final doc = await _goals(householdId).add(goal.toFirestore());
    return doc.id;
  }

  /// Updates the editable fields only - never touches [SavingsGoal.contributions]
  /// so it can't race with [addContribution].
  Future<void> updateGoal(String householdId, SavingsGoal goal) {
    return _goals(householdId).doc(goal.id).update({
      'name': goal.name,
      'iconSlug': goal.iconSlug,
      'targetAmount': goal.targetAmount,
      'targetDate': goal.targetDate == null
          ? null
          : Timestamp.fromDate(goal.targetDate!),
      'monthlyContribution': goal.monthlyContribution,
      'interestRate': goal.interestRate,
    });
  }

  Future<void> addContribution(
    String householdId,
    String goalId,
    Contribution contribution,
  ) {
    return _goals(householdId).doc(goalId).update({
      'contributions': FieldValue.arrayUnion([contribution.toMap()]),
    });
  }

  Future<void> deleteGoal(String householdId, String goalId) {
    return _goals(householdId).doc(goalId).delete();
  }
}
