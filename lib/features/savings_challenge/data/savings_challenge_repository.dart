import 'package:cloud_firestore/cloud_firestore.dart';

import 'savings_challenge_model.dart';

/// Only one challenge is ever shown per household (the mockup only designs
/// a single "Reto de ahorro" screen), but it still lives in its own
/// subcollection for consistency with the rest of the app's security rules.
class SavingsChallengeRepository {
  SavingsChallengeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _challenges(String householdId) =>
      _db.collection('households').doc(householdId).collection('savingsChallenges');

  Stream<SavingsChallenge?> watchChallenge(String householdId) {
    return _challenges(householdId).limit(1).snapshots().map(
      (snap) => snap.docs.isEmpty ? null : SavingsChallenge.fromFirestore(snap.docs.first),
    );
  }

  Future<void> createChallenge(String householdId, SavingsChallenge challenge) {
    return _challenges(householdId).add(challenge.toFirestore());
  }

  Future<void> updateDone(String householdId, String challengeId, List<bool> done) {
    return _challenges(householdId).doc(challengeId).update({'done': done});
  }

  Future<void> deleteChallenge(String householdId, String challengeId) {
    return _challenges(householdId).doc(challengeId).delete();
  }
}
