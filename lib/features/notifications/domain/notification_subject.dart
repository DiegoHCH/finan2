import 'notification_scanner.dart';

/// A notification's document ID says what it's about: NotificationScanner
/// builds it with these, so the same notice is never written twice, and
/// [notificationSubject] reads it back to give the notice the color of its
/// subject.
abstract final class NotificationIds {
  static String debtDue(String debtId, DateTime day) =>
      'debt_due_${debtId}_${day.year}_${day.month}_${day.day}';

  static String goalNear(String goalId) => 'goal_near_$goalId';

  static String budgetExceeded(String categoryId, DateTime month) =>
      'budget_exceeded_${categoryId}_${month.year}_${month.month}';

  static String contribution(String goalId, DateTime date) =>
      'contribution_${goalId}_${date.millisecondsSinceEpoch}';

  static String partner(PartnerRecordKind kind, String recordId) =>
      'partner_${_partnerPrefixes[kind]}_$recordId';
}

const _partnerPrefixes = {
  PartnerRecordKind.movement: 'tx',
  PartnerRecordKind.transfer: 'transfer',
  PartnerRecordKind.debt: 'debt',
  PartnerRecordKind.account: 'account',
  PartnerRecordKind.investment: 'investment',
  PartnerRecordKind.bill: 'bill',
  PartnerRecordKind.category: 'category',
  PartnerRecordKind.challenge: 'challenge',
  PartnerRecordKind.goal: 'goal',
};

/// What a notification is about.
sealed class NotificationSubject {
  const NotificationSubject();
}

/// A debt's payment coming up.
class DebtSubject extends NotificationSubject {
  const DebtSubject(this.debtId);
  final String debtId;
}

/// A goal getting close.
class GoalSubject extends NotificationSubject {
  const GoalSubject(this.goalId);
  final String goalId;
}

/// A category that went over its budget.
class OverspentSubject extends NotificationSubject {
  const OverspentSubject(this.categoryId);
  final String categoryId;
}

/// Someone's contribution to a goal, made at [date].
class ContributionSubject extends NotificationSubject {
  const ContributionSubject(this.goalId, this.date);
  final String goalId;
  final DateTime date;
}

/// Something the other person added.
class PartnerSubject extends NotificationSubject {
  const PartnerSubject(this.kind, this.recordId);
  final PartnerRecordKind kind;
  final String recordId;
}

/// An ID none of [NotificationIds] made.
class UnknownSubject extends NotificationSubject {
  const UnknownSubject();
}

final _debtDue = RegExp(r'^debt_due_(.+)_\d+_\d+_\d+$');
final _goalNear = RegExp(r'^goal_near_(.+)$');
final _budgetExceeded = RegExp(r'^budget_exceeded_(.+)_\d+_\d+$');
final _contribution = RegExp(r'^contribution_(.+)_(\d+)$');
final _partner = RegExp('^partner_(${_partnerPrefixes.values.join('|')})_(.+)\$');

NotificationSubject notificationSubject(String notificationId) {
  if (_debtDue.firstMatch(notificationId) case final m?) return DebtSubject(m[1]!);
  if (_goalNear.firstMatch(notificationId) case final m?) return GoalSubject(m[1]!);
  if (_budgetExceeded.firstMatch(notificationId) case final m?) return OverspentSubject(m[1]!);
  if (_contribution.firstMatch(notificationId) case final m?) {
    return ContributionSubject(m[1]!, DateTime.fromMillisecondsSinceEpoch(int.parse(m[2]!)));
  }
  if (_partner.firstMatch(notificationId) case final m?) {
    final kind = _partnerPrefixes.entries.firstWhere((e) => e.value == m[1]).key;
    return PartnerSubject(kind, m[2]!);
  }
  return const UnknownSubject();
}
