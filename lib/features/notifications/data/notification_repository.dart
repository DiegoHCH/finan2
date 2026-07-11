import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_model.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _notifications(String householdId) =>
      _db.collection('households').doc(householdId).collection('notifications');

  Stream<List<HouseholdNotification>> watchNotifications(String householdId) {
    return _notifications(householdId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(HouseholdNotification.fromFirestore).toList());
  }

  /// Writes the notification only if [id] doesn't already exist - the
  /// scanner uses deterministic IDs so re-running the scan never creates
  /// duplicates for the same condition. Returns the notification if it was
  /// actually created, or null if it already existed (so callers can tell
  /// genuinely new alerts apart from a no-op re-scan).
  Future<HouseholdNotification?> createIfAbsent(
    String householdId,
    String id,
    HouseholdNotification notification,
  ) async {
    final ref = _notifications(householdId).doc(id);
    final snap = await ref.get();
    if (snap.exists) return null;
    await ref.set(notification.toFirestore());
    return notification;
  }

  Future<void> markAllRead(String householdId, List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_notifications(householdId).doc(id), {'read': true});
    }
    await batch.commit();
  }
}
