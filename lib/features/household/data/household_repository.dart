import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'household_model.dart';

/// The invite code doesn't exist, or it expired.
class HouseholdNotFoundException implements Exception {
  const HouseholdNotFoundException();
}

/// Firestore refused the join - the household is already full, or the invite
/// stopped being valid between reading it and joining.
class HouseholdFullException implements Exception {
  const HouseholdFullException();
}

/// What an invite says before using it: whose household it opens. The
/// names are null for invites made before they were stored.
class InvitePreview {
  const InvitePreview({
    required this.code,
    required this.expiresAt,
    this.householdName,
    this.inviterName,
  });

  final String code;
  final DateTime expiresAt;
  final String? householdName;
  final String? inviterName;
}

/// A household's data encryption key, wrapped under its recovery phrase and
/// stashed in `households/{id}/security/recovery` for cross-device recovery.
class KeyRecovery {
  const KeyRecovery({required this.salt, required this.wrappedKey});

  final String salt;
  final String wrappedKey;

  WrappedKey get wrapped => WrappedKey(salt: salt, ciphertext: wrappedKey);

  factory KeyRecovery.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return KeyRecovery(salt: data['salt'] as String, wrappedKey: data['wrappedKey'] as String);
  }
}

/// Invite codes avoid visually ambiguous characters (0/O, 1/I). 10 of them
/// are 50 bits - with a 7-day expiry, far out of reach of anyone guessing.
const _inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const _inviteCodeLength = 10;
const _inviteLifetime = Duration(days: 7);

/// An invite with less than this left is replaced rather than shown again,
/// so the partner isn't sent a code about to expire.
const _inviteReuseMargin = Duration(days: 1);

/// Every subcollection under `households/{id}` - what [HouseholdRepository]
/// wipes when the last member leaves. A new subcollection must be added here
/// or it outlives its household.
const householdSubcollections = [
  'accounts',
  'budgetAlerts',
  'budgets',
  'cardPayments',
  'categories',
  'debts',
  'fcmTokens',
  'goalAlerts',
  'investments',
  'memberPrefs',
  'monthlyNotes',
  'notifications',
  'pendingBills',
  'recurringBills',
  'recurringDone',
  'savingsChallenges',
  'savingsGoals',
  'security',
  'sentReminders',
  'transactions',
  'transfers',
];

class HouseholdRepository {
  HouseholdRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _households => _db.collection('households');

  CollectionReference<Map<String, dynamic>> get _invites => _db.collection('invites');

  /// Watches the (at most one) household the given user belongs to.
  Stream<Household?> watchHouseholdForUser(String uid) {
    return _households.where('members', arrayContains: uid).limit(1).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      return Household.fromFirestore(snap.docs.first);
    });
  }

  /// Creates the household plus its first invite. Returns the household and
  /// the invite code to share.
  Future<(Household, String)> createHousehold({
    required String uid,
    required String displayName,
    required String householdName,
  }) async {
    final docRef = _households.doc();
    final code = _generateInviteCode();
    final household = Household(
      id: docRef.id,
      name: householdName,
      members: [uid],
      memberInfo: {uid: HouseholdMemberInfo(name: displayName)},
      currency: 'COP',
      startYear: DateTime.now().year,
      weekStartsOn: 'monday',
    );
    final batch = _db.batch()
      ..set(docRef, {
        ...household.toFirestore(),
        'createdBy': uid,
        'activeInvite': code,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(
        _invites.doc(code),
        _inviteData(docRef.id, uid, householdName: householdName, inviterName: displayName),
      );
    await batch.commit();
    return (household, code);
  }

  /// The household's current invite if it still has at least
  /// [_inviteReuseMargin] left, so opening the invite again doesn't break
  /// the code already sent; otherwise a fresh one ([createInvite]).
  Future<InvitePreview> currentInvite(
    String householdId,
    String uid, {
    required String inviterName,
  }) async {
    final household = (await _households.doc(householdId).get()).data() ?? const {};
    final active = household['activeInvite'] as String?;
    if (active != null) {
      final invite = await _invites.doc(active).get();
      final preview = invite.exists ? _preview(invite) : null;
      if (preview != null && preview.expiresAt.isAfter(DateTime.now().add(_inviteReuseMargin))) {
        return preview;
      }
    }
    return createInvite(householdId, uid, inviterName: inviterName);
  }

  /// Replaces the household's current invite (if any) with a fresh one: the
  /// old code stops working.
  Future<InvitePreview> createInvite(
    String householdId,
    String uid, {
    required String inviterName,
  }) async {
    final docRef = _households.doc(householdId);
    final household = (await docRef.get()).data() ?? const {};
    final previous = household['activeInvite'] as String?;
    final code = _generateInviteCode();
    final data = _inviteData(
      householdId,
      uid,
      householdName: household['name'] as String? ?? '',
      inviterName: inviterName,
    );
    final batch = _db.batch()
      ..update(docRef, {'activeInvite': code})
      ..set(_invites.doc(code), data);
    if (previous != null) batch.delete(_invites.doc(previous));
    await batch.commit();
    return InvitePreview(
      code: code,
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      householdName: data['householdName'] as String?,
      inviterName: data['inviterName'] as String?,
    );
  }

  /// Whose household [code] opens, without joining - so the partner can
  /// check it's the right one first. Throws [HouseholdNotFoundException] if
  /// it doesn't exist or expired.
  Future<InvitePreview> previewInvite(String code) async {
    final invite = await _invites.doc(code.trim().toUpperCase()).get();
    final preview = invite.exists ? _preview(invite) : null;
    if (preview == null || preview.expiresAt.isBefore(DateTime.now())) {
      throw const HouseholdNotFoundException();
    }
    return preview;
  }

  InvitePreview? _preview(DocumentSnapshot<Map<String, dynamic>> invite) {
    final data = invite.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    if (expiresAt == null) return null;
    String? text(String field) {
      final value = (data[field] as String?)?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    return InvitePreview(
      code: invite.id,
      expiresAt: expiresAt,
      householdName: text('householdName'),
      inviterName: text('inviterName'),
    );
  }

  /// The household's and the inviter's names ride on the invite in the
  /// clear: whoever has the code is about to join, and a non-member can't
  /// read the household itself to check it's the right one.
  Map<String, dynamic> _inviteData(
    String householdId,
    String uid, {
    required String householdName,
    required String inviterName,
  }) => {
    'householdId': householdId,
    'createdBy': uid,
    'expiresAt': Timestamp.fromDate(DateTime.now().add(_inviteLifetime)),
    'householdName': householdName,
    'inviterName': inviterName,
  };

  /// Joins the household behind invite [code], consuming the invite.
  Future<Household> joinHousehold({
    required String code,
    required String uid,
    required String displayName,
  }) async {
    final inviteRef = _invites.doc(code.trim().toUpperCase());
    final String householdId;
    try {
      householdId = await _db.runTransaction((tx) async {
        final invite = await tx.get(inviteRef);
        final data = invite.data();
        final expiresAt = (data?['expiresAt'] as Timestamp?)?.toDate();
        if (data == null || expiresAt == null || expiresAt.isBefore(DateTime.now())) {
          throw const HouseholdNotFoundException();
        }
        final householdId = data['householdId'] as String;
        // A non-member can't read the household, so this writes blind -
        // firestore.rules checks the invite and that there's room.
        tx.update(_households.doc(householdId), {
          'members': FieldValue.arrayUnion([uid]),
          'memberInfo.$uid': HouseholdMemberInfo(name: displayName).toMap(),
          'joinedVia': inviteRef.id,
          'activeInvite': null,
        });
        tx.delete(inviteRef);
        return householdId;
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const HouseholdFullException();
      rethrow;
    }
    return Household.fromFirestore(await _households.doc(householdId).get());
  }

  /// Takes [uid] out of the household, removing what belongs only to them
  /// (push tokens, notification prefs). If they're the last member, the
  /// whole household and every subcollection is deleted - nobody could ever
  /// reach that data again anyway.
  Future<void> leaveHousehold(String householdId, String uid) async {
    final docRef = _households.doc(householdId);
    final data = (await docRef.get()).data() ?? const {};
    final members = List<String>.from(data['members'] as List? ?? const []);
    if (members.length <= 1) {
      await _wipeHousehold(householdId, data['activeInvite'] as String?);
      return;
    }

    final myTokens = await docRef.collection('fcmTokens').where('uid', isEqualTo: uid).get();
    final batch = _db.batch();
    for (final doc in myTokens.docs) {
      batch.delete(doc.reference);
    }
    batch
      ..delete(docRef.collection('memberPrefs').doc(uid))
      ..update(docRef, {
        'members': FieldValue.arrayRemove([uid]),
        'memberInfo.$uid': FieldValue.delete(),
      });
    await batch.commit();
  }

  Future<void> _wipeHousehold(String householdId, String? activeInvite) async {
    final docRef = _households.doc(householdId);
    // First and on its own: the invite rule checks membership in the
    // household *after* the write, which fails once the household is gone.
    if (activeInvite != null) await _invites.doc(activeInvite).delete();
    await _securityDoc(householdId, 'recovery').delete();

    // Background jobs (scanners, token refresh) can still write while this
    // runs, and anything left once the household doc is gone is out of
    // every client's reach - so sweep until a full pass finds nothing.
    for (var pass = 0; pass < 3; pass++) {
      var deletedAny = false;
      for (final name in householdSubcollections) {
        if (name == 'security') continue; // Not listable; its docs are known.
        final collection = docRef.collection(name);
        while (true) {
          final page = await collection.limit(400).get();
          if (page.docs.isEmpty) break;
          deletedAny = true;
          final batch = _db.batch();
          for (final doc in page.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }
      if (!deletedAny) break;
    }
    await docRef.delete();
  }

  /// One encrypted amount from the household, if it has any - lets a pasted
  /// key be checked against real data before it's stored.
  Future<String?> sampleCiphertext(String householdId) async {
    final docRef = _households.doc(householdId);
    for (final (collection, field) in const [('accounts', 'balance'), ('transactions', 'amount')]) {
      final page = await docRef.collection(collection).limit(1).get();
      final value = page.docs.isEmpty ? null : page.docs.first.data()[field];
      if (value is String) return value;
    }
    return null;
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

  DocumentReference<Map<String, dynamic>> _securityDoc(String householdId, String id) =>
      _households.doc(householdId).collection('security').doc(id);

  Future<KeyRecovery?> getKeyRecovery(String householdId) async {
    final snap = await _securityDoc(householdId, 'recovery').get();
    return snap.exists ? KeyRecovery.fromFirestore(snap) : null;
  }

  /// Saves a new recovery wrap, replacing any previous one.
  Future<void> setKeyRecovery(String householdId, String uid, WrappedKey wrapped) {
    return _securityDoc(householdId, 'recovery').set({
      'salt': wrapped.salt,
      'wrappedKey': wrapped.ciphertext,
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
