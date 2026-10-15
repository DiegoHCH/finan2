import '../entities/household_notification.dart';

/// What NotificationScanner needs from wherever notifications are stored.
abstract interface class NotificationWriter {
  /// Writes [notification] under [id] unless something is already there.
  /// Returns it when it was actually created, null when it already existed.
  Future<HouseholdNotification?> createIfAbsent(
    String householdId,
    String id,
    HouseholdNotification notification,
  );
}
