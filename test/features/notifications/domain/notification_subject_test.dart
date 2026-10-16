import 'package:finan2/features/notifications/domain/notification_scanner.dart';
import 'package:finan2/features/notifications/domain/notification_subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 10, 14);

  test('each kind of ID reads back as its subject', () {
    expect(
      (notificationSubject(NotificationIds.debtDue('visa_1', day)) as DebtSubject).debtId,
      'visa_1',
    );
    expect((notificationSubject(NotificationIds.goalNear('g1')) as GoalSubject).goalId, 'g1');
    expect(
      (notificationSubject(NotificationIds.budgetExceeded('cat_9', day)) as OverspentSubject)
          .categoryId,
      'cat_9',
    );
    final contribution =
        notificationSubject(NotificationIds.contribution('g1', day)) as ContributionSubject;
    expect(contribution.goalId, 'g1');
    expect(contribution.date, day);
    for (final kind in PartnerRecordKind.values) {
      final partner = notificationSubject(NotificationIds.partner(kind, 'r_1')) as PartnerSubject;
      expect(partner.kind, kind);
      expect(partner.recordId, 'r_1');
    }
  });

  test('the IDs stay what they were, so old notifications still match', () {
    expect(NotificationIds.debtDue('d', day), 'debt_due_d_2026_10_14');
    expect(NotificationIds.budgetExceeded('c', day), 'budget_exceeded_c_2026_10');
    expect(NotificationIds.partner(PartnerRecordKind.movement, 't'), 'partner_tx_t');
  });

  test('an ID from elsewhere has no subject', () {
    expect(notificationSubject('n1'), isA<UnknownSubject>());
    expect(notificationSubject('partner_other_x'), isA<UnknownSubject>());
  });
}
