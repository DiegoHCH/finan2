import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches the Firestore schema's `type` field - each one maps to one of
/// the [notification_scanner.dart] detection rules.
enum NotificationType { debtDue, goalNear, budgetExceeded, contribution, partnerActivity }

extension NotificationTypeLabel on NotificationType {
  static NotificationType fromName(String name) => NotificationType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => NotificationType.contribution,
  );
}

class HouseholdNotification {
  const HouseholdNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  factory HouseholdNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return HouseholdNotification(
      id: doc.id,
      type: NotificationTypeLabel.fromName(data['type'] as String? ?? 'contribution'),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
    };
  }
}
