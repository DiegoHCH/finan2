import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'household_model.dart';

class HouseholdNotFoundException implements Exception {
  const HouseholdNotFoundException();
}

class HouseholdFullException implements Exception {
  const HouseholdFullException();
}

/// Invite codes avoid visually ambiguous characters (0/O, 1/I).
const _inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const _inviteCodeLength = 6;

class HouseholdRepository {
  HouseholdRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _households =>
      _db.collection('households');

  /// Watches the (at most one) household the given user belongs to.
  Stream<Household?> watchHouseholdForUser(String uid) {
    return _households
        .where('members', arrayContains: uid)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return Household.fromFirestore(snap.docs.first);
    });
  }

  Future<Household> createHousehold({
    required String uid,
    required String displayName,
    required String householdName,
  }) async {
    // Extremely unlikely to collide (32^6 codes), but guard against
    // overwriting an existing household anyway.
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateInviteCode();
      final docRef = _households.doc(code);
      final created = await _db.runTransaction((tx) async {
        final existing = await tx.get(docRef);
        if (existing.exists) return null;
        final household = Household(
          id: code,
          name: householdName,
          members: [uid],
          memberInfo: {uid: HouseholdMemberInfo(name: displayName)},
          currency: 'COP',
          startYear: DateTime.now().year,
          weekStartsOn: 'monday',
        );
        tx.set(docRef, household.toFirestore());
        return household;
      });
      if (created != null) return created;
    }
    throw StateError('Could not generate a unique invite code, try again.');
  }

  Future<Household> joinHousehold({
    required String code,
    required String uid,
    required String displayName,
  }) async {
    final docRef = _households.doc(code.trim().toUpperCase());
    return _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw const HouseholdNotFoundException();
      }
      var household = Household.fromFirestore(snap);
      if (household.members.contains(uid)) {
        return household;
      }
      if (household.members.length >= 2) {
        throw const HouseholdFullException();
      }
      final updatedMembers = [...household.members, uid];
      final updatedMemberInfo = {
        ...household.memberInfo,
        uid: HouseholdMemberInfo(name: displayName),
      };
      tx.update(docRef, {
        'members': updatedMembers,
        'memberInfo':
            updatedMemberInfo.map((uid, info) => MapEntry(uid, info.toMap())),
      });
      return Household(
        id: household.id,
        name: household.name,
        members: updatedMembers,
        memberInfo: updatedMemberInfo,
        currency: household.currency,
        startYear: household.startYear,
        weekStartsOn: household.weekStartsOn,
      );
    });
  }

  Future<void> updateSettings(
    String householdId, {
    String? currency,
    int? startYear,
    String? weekStartsOn,
  }) {
    final update = <String, dynamic>{
      'settings.currency': ?currency,
      'settings.startYear': ?startYear,
      'settings.weekStartsOn': ?weekStartsOn,
    };
    if (update.isEmpty) return Future.value();
    return _households.doc(householdId).update(update);
  }

  String _generateInviteCode() {
    final rand = Random.secure();
    return List.generate(
      _inviteCodeLength,
      (_) => _inviteCodeAlphabet[rand.nextInt(_inviteCodeAlphabet.length)],
    ).join();
  }
}
