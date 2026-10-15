import 'notification_scanner.dart';

/// The words NotificationScanner writes into each notification, in the
/// language of the device running the scan.
abstract interface class NotificationTexts {
  String debtDueTodayTitle(String debtName);
  String debtDueTodayBody(String debtName);
  String debtDueSoonTitle(String debtName);
  String debtDueSoonBody(String debtName, int days);
  String get goalNearTitle;
  String goalNearBody(String goalName, int percent);
  String get budgetExceededTitle;
  String budgetExceededBody(String categoryName);

  /// Stands in for a budgeted category that no longer exists.
  String get unknownCategory;
  String get contributionTitle;
  String contributionBody(String goalName);
  String partnerTitle(PartnerRecordKind kind);

  /// For a partner's movement without a description.
  String get partnerMovementBody;
  String get partnerTransferBody;
}
