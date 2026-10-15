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
}
