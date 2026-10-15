import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/household_notification.dart';

HouseholdNotification householdNotificationFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
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

extension HouseholdNotificationFirestore on HouseholdNotification {
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
