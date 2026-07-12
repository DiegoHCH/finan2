import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'savings_goal_model.dart';

class SavingsGoalRepository {
  SavingsGoalRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _goals(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('savingsGoals');

  Stream<List<SavingsGoal>> watchGoals(String householdId) {
    return _goals(householdId).orderBy('name').snapshots().asyncMap(
          (snap) => Future.wait(
            snap.docs.map(
              (doc) => SavingsGoal.fromFirestore(doc, _crypto, householdId),
            ),
          ),
        );
  }

  /// Returns the new goal's generated ID.
  Future<String> createGoal(String householdId, SavingsGoal goal) async {
    final doc = await _goals(householdId).add(
      await goal.toFirestore(_crypto, householdId),
    );
    return doc.id;
  }

  /// Updates the editable fields only - never touches [SavingsGoal.contributions]
  /// so it can't race with [addContribution].
  Future<void> updateGoal(String householdId, SavingsGoal goal) async {
    await _goals(householdId).doc(goal.id).update({
      'name': goal.name,
      'iconSlug': goal.iconSlug,
      'targetAmount': await _crypto.encryptAmount(householdId, goal.targetAmount),
      'targetDate': goal.targetDate == null
          ? null
          : Timestamp.fromDate(goal.targetDate!),
      'monthlyContribution':
          await _crypto.encryptAmount(householdId, goal.monthlyContribution),
      'interestRate': goal.interestRate,
    });
  }

  Future<void> addContribution(
    String householdId,
    String goalId,
    Contribution contribution,
  ) async {
    await _goals(householdId).doc(goalId).update({
      'contributions': FieldValue.arrayUnion([
        await contribution.toMap(_crypto, householdId),
      ]),
    });
  }

  Future<void> deleteGoal(String householdId, String goalId) {
    return _goals(householdId).doc(goalId).delete();
  }
}
