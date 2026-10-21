import 'package:cloud_firestore/cloud_firestore.dart';

/// Where an account's PIN record (salt and HMAC, never the PIN) lives so
/// every phone signed in to it opens with the same PIN.
abstract class AppLockCloud {
  Future<String?> fetch(String account);
  Future<void> save(String account, String record);
  Future<void> delete(String account);
}

/// `users/{uid}/private/appLock`, readable and writable by that user only
/// (firestore.rules).
class FirestoreAppLockCloud implements AppLockCloud {
  FirestoreAppLockCloud({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String account) =>
      _firestore.collection('users').doc(account).collection('private').doc('appLock');

  @override
  Future<String?> fetch(String account) async {
    final snapshot = await _doc(account).get(const GetOptions(source: Source.server));
    return snapshot.data()?['pin'] as String?;
  }

  @override
  Future<void> save(String account, String record) =>
      _doc(account).set({'pin': record, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> delete(String account) => _doc(account).delete();
}
