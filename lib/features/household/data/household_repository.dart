import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'household_model.dart';

class HouseholdNotFoundException implements Exception {
  const HouseholdNotFoundException();
}

/// A household's data encryption key, wrapped under a 6-digit PIN and
/// stashed in `households/{id}/security/pinRecovery` for cross-device
/// recovery. [attempts]/[lockedUntil] enforce the 3-tries/1h lockout -
/// firestore.rules constrains how these two can actually change so a
/// compromised client can't just reset them to keep guessing.
class PinRecovery {
  const PinRecovery({
    required this.salt,
    required this.wrappedKey,
    required this.attempts,
    required this.lockedUntil,
  });

  final String salt;
  final String wrappedKey;
  final int attempts;
  final DateTime? lockedUntil;

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  factory PinRecovery.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PinRecovery(
      salt: data['salt'] as String,
      wrappedKey: data['wrappedKey'] as String,
      attempts: data['attempts'] as int? ?? 0,
      lockedUntil: (data['lockedUntil'] as Timestamp?)?.toDate(),
    );
  }
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

  /// Removes [uid] from the household's membership. The household and its
  /// data are left untouched for any remaining member - there is no way to
  /// delete a household outright (`allow delete: if false` in the rules).
  Future<void> leaveHousehold(String householdId, String uid) {
    return _households.doc(householdId).update({
      'members': FieldValue.arrayRemove([uid]),
      'memberInfo.$uid': FieldValue.delete(),
    });
  }

  Future<void> updateMemberName(String householdId, String uid, String name) {
    return _households.doc(householdId).update({'memberInfo.$uid.name': name});
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

  DocumentReference<Map<String, dynamic>> _pinRecoveryDoc(String householdId) =>
      _households.doc(householdId).collection('security').doc('pinRecovery');

  Future<PinRecovery?> getPinRecovery(String householdId) async {
    final snap = await _pinRecoveryDoc(householdId).get();
    return snap.exists ? PinRecovery.fromFirestore(snap) : null;
  }

  /// Sets a brand-new PIN (fresh salt + wrapped key). Always allowed and
  /// always resets attempts/lockout to zero - see firestore.rules for why
  /// this can't be used to brute-force whatever wrap it replaces (only a
  /// device that already holds the plaintext key can produce a wrap worth
  /// anything; this overwrites the old one rather than revealing it).
  Future<void> setPinRecovery(String householdId, PinWrappedKey wrapped) {
    return _pinRecoveryDoc(householdId).set({
      'salt': wrapped.salt,
      'wrappedKey': wrapped.ciphertext,
      'attempts': 0,
      'lockedUntil': null,
    });
  }

  /// Clears attempts/lockout back to zero - only meaningful (and only
  /// allowed by firestore.rules) once [current]'s lockout has actually
  /// passed. Call only when [current.isLocked] is already false but
  /// [PinRecovery.lockedUntil] is non-null (i.e. a past lock that expired).
  Future<void> resetPinAttemptsIfLockExpired(
    String householdId,
    PinRecovery current,
  ) {
    if (current.lockedUntil == null || current.isLocked) {
      throw StateError('Cannot reset PIN attempts before the lockout expires.');
    }
    return _pinRecoveryDoc(householdId).update({
      'attempts': 0,
      'lockedUntil': null,
    });
  }

  /// Records one more failed guess against the PIN currently on file,
  /// locking for 1 hour once this is the 3rd failure since the last reset.
  /// Call only when [current] isn't already locked (check
  /// [PinRecovery.isLocked] first) - firestore.rules rejects this write
  /// otherwise.
  Future<void> recordFailedPinAttempt(String householdId, PinRecovery current) {
    final attempts = current.attempts + 1;
    return _pinRecoveryDoc(householdId).update({
      'attempts': attempts,
      'lockedUntil': attempts >= 3
          ? Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1)))
          : null,
    });
  }
}
