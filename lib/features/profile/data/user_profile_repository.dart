import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_profile.dart';

/// `users/{uid}`: readable and writable by its owner alone (firestore.rules).
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<UserProfile?> watch(String uid) => _doc(uid).snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) return null;
    return UserProfile(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      language: data['language'] as String?,
      theme: data['theme'] as String?,
    );
  });

  /// Creates the profile on the account's first sign-in after this existed;
  /// later sign-ins only refresh the email, which can change in Auth.
  Future<void> ensure(String uid, {required String name, required String email}) async {
    final ref = _doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      if (snapshot.data()?['email'] != email) {
        await ref.update({'email': email, 'updatedAt': FieldValue.serverTimestamp()});
      }
      return;
    }
    await ref.set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// With the account: the profile goes too (the app-lock PIN is deleted
  /// by AppLockRepository.clear).
  Future<void> delete(String uid) => _doc(uid).delete();

  Future<void> updateName(String uid, String name) =>
      _doc(uid).update({'name': name, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> updatePreferences(String uid, {String? language, String? theme}) => _doc(
    uid,
  ).update({'language': ?language, 'theme': ?theme, 'updatedAt': FieldValue.serverTimestamp()});
}
