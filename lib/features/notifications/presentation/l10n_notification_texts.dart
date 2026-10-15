import '../../../l10n/l10n.dart';
import '../domain/notification_scanner.dart';
import '../domain/notification_texts.dart';

/// [NotificationTexts] in the app's current language - see currentL10n.
class L10nNotificationTexts implements NotificationTexts {
  const L10nNotificationTexts();

  @override
  String debtDueTodayTitle(String debtName) => currentL10n.notificationsDebtDueTodayTitle(debtName);

  @override
  String debtDueTodayBody(String debtName) => currentL10n.notificationsDebtDueTodayBody(debtName);

  @override
  String debtDueSoonTitle(String debtName) => currentL10n.notificationsDebtDueSoonTitle(debtName);

  @override
  String debtDueSoonBody(String debtName, int days) =>
      currentL10n.notificationsDebtDueSoonBody(debtName, days);

  @override
  String get goalNearTitle => currentL10n.notificationsGoalNearTitle;

  @override
  String goalNearBody(String goalName, int percent) =>
      currentL10n.notificationsGoalNearBody(goalName, percent);

  @override
  String get budgetExceededTitle => currentL10n.notificationsBudgetExceededTitle;

  @override
  String budgetExceededBody(String categoryName) =>
      currentL10n.notificationsBudgetExceededBody(categoryName);

  @override
  String get unknownCategory => currentL10n.notificationsUnknownCategory;

  @override
  String get contributionTitle => currentL10n.notificationsContributionTitle;

  @override
  String contributionBody(String goalName) => currentL10n.notificationsContributionBody(goalName);

  @override
  String partnerTitle(PartnerRecordKind kind) => switch (kind) {
    PartnerRecordKind.movement => currentL10n.notificationsPartnerMovementTitle,
    PartnerRecordKind.transfer => currentL10n.notificationsPartnerTransferTitle,
    PartnerRecordKind.debt => currentL10n.notificationsPartnerDebtTitle,
    PartnerRecordKind.account => currentL10n.notificationsPartnerAccountTitle,
    PartnerRecordKind.investment => currentL10n.notificationsPartnerInvestmentTitle,
    PartnerRecordKind.bill => currentL10n.notificationsPartnerBillTitle,
    PartnerRecordKind.category => currentL10n.notificationsPartnerCategoryTitle,
    PartnerRecordKind.challenge => currentL10n.notificationsPartnerChallengeTitle,
    PartnerRecordKind.goal => currentL10n.notificationsPartnerGoalTitle,
  };

  @override
  String get partnerMovementBody => currentL10n.notificationsPartnerMovementBody;

  @override
  String get partnerTransferBody => currentL10n.notificationsPartnerTransferBody;
}
