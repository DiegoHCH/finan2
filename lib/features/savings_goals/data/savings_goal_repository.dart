import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/decrypted_snapshots.dart';
import '../../../core/crypto/household_crypto.dart';
import 'savings_goal_model.dart';
import '../../../core/observability/error_reporter.dart';

class SavingsGoalRepository {
  SavingsGoalRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _goals(String householdId) =>
      _db.collection('households').doc(householdId).collection('savingsGoals');

  CollectionReference<Map<String, dynamic>> _goalAlerts(String householdId) =>
      _db.collection('households').doc(householdId).collection('goalAlerts');

  Stream<List<SavingsGoal>> watchGoals(String householdId) {
    return _goals(householdId)
        .orderBy('name')
        .snapshots()
        .decryptEach((doc) => SavingsGoal.fromFirestore(doc, _crypto, householdId));
  }

  /// Returns the new goal's generated ID.
  Future<String> createGoal(String householdId, SavingsGoal goal) async {
    final doc = await _goals(householdId).add(await goal.toFirestore(_crypto, householdId));
    return doc.id;
  }

  /// Updates the editable fields only - never touches [SavingsGoal.contributions]
  /// so it can't race with [addContribution].
  Future<void> updateGoal(String householdId, SavingsGoal goal) async {
    await _goals(householdId).doc(goal.id).update({
      'name': goal.name,
      'iconSlug': goal.iconSlug,
      'targetAmount': await _crypto.encryptAmount(householdId, goal.targetAmount),
      'targetDate': goal.targetDate == null ? null : Timestamp.fromDate(goal.targetDate!),
      'monthlyContribution': await _crypto.encryptAmount(householdId, goal.monthlyContribution),
      'interestRate': goal.interestRate,
    });
  }

  Future<void> addContribution(String householdId, String goalId, Contribution contribution) async {
    await _goals(householdId).doc(goalId).update({
      'contributions': FieldValue.arrayUnion([await contribution.toMap(_crypto, householdId)]),
    });
    await _refreshGoalNearAlert(householdId, goalId);
  }

  /// Recomputes [SavingsGoal.progressFractionAsOf] and persists a plaintext
  /// `near` flag on `goalAlerts/{goalId}` - the amounts stay encrypted, but
  /// "is this goal between 90% and 100%" is readable without the household's
  /// key. This is what lets the Cloudflare Worker's cron
  /// (cloudflare/finan2-notifications/worker.js) send the "¡casi logras tu
  /// meta!" push even with every device closed - the flag is already fresh
  /// as of whoever last added a contribution, since only a client (with the
  /// key) can compute it. Best-effort: a failure here must never block the
  /// contribution write.
  Future<void> _refreshGoalNearAlert(String householdId, String goalId) async {
    try {
      final doc = await _goals(householdId).doc(goalId).get();
      if (!doc.exists) return;
      final goal = await SavingsGoal.fromFirestore(doc, _crypto, householdId);
      final fraction = goal.progressFractionAsOf(DateTime.now());
      await _goalAlerts(householdId).doc(goalId).set({'near': fraction >= 0.9 && fraction < 1.0});
    } catch (e, st) {
      // Best-effort - the contribution itself already succeeded.
      ErrorReporter.recoverable(e, st, reason: 'goal near-alert flag not refreshed');
    }
  }

  Future<void> deleteGoal(String householdId, String goalId) {
    return _goals(householdId).doc(goalId).delete();
  }
}
