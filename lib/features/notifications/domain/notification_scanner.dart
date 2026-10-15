import '../../debts/domain/entities/debt.dart';
import '../../transactions/domain/entities/movement.dart';
import 'entities/household_notification.dart';
import 'notification_texts.dart';
import 'repositories/notification_writer.dart';

/// A notification the scan just created, plus who its push should skip.
/// For a household-level alert (debt due, budget exceeded...) that's the
/// current device, since whoever's scan just detected it is presumably
/// looking at the app right now. For something a household member DID
/// (partner activity, a contribution), it's THAT member - not the current
/// device - since they're the one who already sees it live; the whole point
/// of the push is to reach the other member who didn't just act.
class ScannedNotification {
  const ScannedNotification({required this.notification, required this.excludePushUid});

  final HouseholdNotification notification;
  final String excludePushUid;
}

/// Which of the scanner's rules the household has turned on.
class NotificationRules {
  const NotificationRules({
    required this.debtPayments,
    required this.goalProgress,
    required this.budgetExceeded,
    required this.partnerActivity,
  });

  final bool debtPayments;
  final bool goalProgress;
  final bool budgetExceeded;
  final bool partnerActivity;
}

/// A savings goal as the scanner sees it.
class TrackedGoal {
  const TrackedGoal({
    required this.id,
    required this.name,
    required this.progressFraction,
    this.contributions = const [],
  });

  final String id;
  final String name;

  /// How far along it is right now, 0-1.
  final double progressFraction;
  final List<TrackedContribution> contributions;
}

class TrackedContribution {
  const TrackedContribution({required this.createdBy, required this.date});

  final String createdBy;
  final DateTime date;
}

/// Everything that records a `createdBy`, for partner-activity alerts.
enum PartnerRecordKind {
  movement,
  transfer,
  debt,
  account,
  investment,
  bill,
  category,
  challenge,
  goal,
}

class PartnerRecord {
  const PartnerRecord({
    required this.kind,
    required this.id,
    required this.createdBy,
    required this.name,
    required this.createdAt,
  });

  final PartnerRecordKind kind;
  final String id;
  final String createdBy;

  /// What the alert's body shows - a movement's description, a debt's name...
  final String name;
  final DateTime createdAt;
}

/// Detects the household's alert-worthy conditions and writes any missing
/// notification (deterministic IDs keep re-scans idempotent). Titles and
/// bodies are stored text, written in the language of the device whose scan
/// creates them - whoever reads them later sees that language. Runs entirely
/// on the client - there's no backend to trigger this on a schedule, so it
/// re-checks whenever the relevant data changes while the app is open.
class NotificationScanner {
  const NotificationScanner(this._repository, this._texts);

  final NotificationWriter _repository;
  final NotificationTexts _texts;

  /// Returns every notification actually created this scan (as opposed to
  /// ones that already existed) - callers use this to trigger a real push
  /// only for genuinely new alerts. [partnerRecords] are notified in order.
  Future<List<ScannedNotification>> detect({
    required String householdId,
    required String currentUid,
    required NotificationRules rules,
    required List<Debt> debts,
    required List<TrackedGoal> goals,
    required Map<String, int> budget,
    required List<Movement> transactionsThisMonth,
    required Map<String, String> categoryNames,
    required List<PartnerRecord> partnerRecords,
    required DateTime now,
  }) async {
    final created = <ScannedNotification>[];

    if (rules.debtPayments) {
      await _scanDebts(created, householdId, debts, now, currentUid);
    }
    if (rules.goalProgress) {
      await _scanGoalProgress(created, householdId, goals, now, currentUid);
    }
    if (rules.budgetExceeded) {
      await _scanBudget(
        created,
        householdId,
        budget,
        transactionsThisMonth,
        categoryNames,
        now,
        currentUid,
      );
    }
    if (rules.partnerActivity) {
      await _scanContributions(created, householdId, goals, currentUid);
      await _scanPartnerCreated(created, householdId, currentUid, partnerRecords);
    }
    return created;
  }

  Future<void> _scanDebts(
    List<ScannedNotification> created,
    String householdId,
    List<Debt> debts,
    DateTime now,
    String currentUid,
  ) async {
    for (final debt in debts) {
      if (debt.balance <= 0) continue;
      final daysUntil = _daysUntilDayOfMonth(debt.paymentDay, now);
      if (daysUntil < 0 || daysUntil > 3) continue;
      // One notification per day of the countdown (day included in the ID),
      // not one per month - re-scanning the same day never duplicates it,
      // but each new day of the 4-day window (3, 2, 1, 0 días) gets its own.
      final id = 'debt_due_${debt.id}_${now.year}_${now.month}_${now.day}';
      final isToday = daysUntil == 0;
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.debtDue,
          title: isToday ? _texts.debtDueTodayTitle(debt.name) : _texts.debtDueSoonTitle(debt.name),
          body: isToday
              ? _texts.debtDueTodayBody(debt.name)
              : _texts.debtDueSoonBody(debt.name, daysUntil),
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: currentUid));
      }
    }
  }

  Future<void> _scanGoalProgress(
    List<ScannedNotification> created,
    String householdId,
    List<TrackedGoal> goals,
    DateTime now,
    String currentUid,
  ) async {
    for (final goal in goals) {
      final fraction = goal.progressFraction;
      if (fraction < 0.9 || fraction >= 1.0) continue;
      final id = 'goal_near_${goal.id}';
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.goalNear,
          title: _texts.goalNearTitle,
          body: _texts.goalNearBody(goal.name, (fraction * 100).round()),
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: currentUid));
      }
    }
  }

  Future<void> _scanBudget(
    List<ScannedNotification> created,
    String householdId,
    Map<String, int> budget,
    List<Movement> transactionsThisMonth,
    Map<String, String> categoryNames,
    DateTime now,
    String currentUid,
  ) async {
    final spendByCategory = <String, int>{};
    for (final tx in transactionsThisMonth) {
      if (tx.isIncome) continue;
      spendByCategory[tx.categoryId] = (spendByCategory[tx.categoryId] ?? 0) + tx.amount;
    }

    for (final entry in budget.entries) {
      final planned = entry.value;
      if (planned <= 0) continue;
      final real = spendByCategory[entry.key] ?? 0;
      if (real <= planned) continue;
      final id = 'budget_exceeded_${entry.key}_${now.year}_${now.month}';
      final categoryName = categoryNames[entry.key] ?? _texts.unknownCategory;
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.budgetExceeded,
          title: _texts.budgetExceededTitle,
          body: _texts.budgetExceededBody(categoryName),
          createdAt: now,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(ScannedNotification(notification: notification, excludePushUid: currentUid));
      }
    }
  }

  Future<void> _scanContributions(
    List<ScannedNotification> created,
    String householdId,
    List<TrackedGoal> goals,
    String currentUid,
  ) async {
    for (final goal in goals) {
      for (final contribution in goal.contributions) {
        if (contribution.createdBy.isEmpty || contribution.createdBy == currentUid) {
          continue;
        }
        final id = 'contribution_${goal.id}_${contribution.date.millisecondsSinceEpoch}';
        final notification = await _repository.createIfAbsent(
          householdId,
          id,
          HouseholdNotification(
            id: id,
            type: NotificationType.contribution,
            title: _texts.contributionTitle,
            body: _texts.contributionBody(goal.name),
            createdAt: contribution.date,
            read: false,
          ),
        );
        if (notification != null) {
          created.add(
            ScannedNotification(notification: notification, excludePushUid: contribution.createdBy),
          );
        }
      }
    }
  }

  /// One notification per record the OTHER member created, across every
  /// entity that tracks a `createdBy`. Deterministic per-record IDs keep
  /// this idempotent the same way every other scan is.
  Future<void> _scanPartnerCreated(
    List<ScannedNotification> created,
    String householdId,
    String currentUid,
    List<PartnerRecord> records,
  ) async {
    for (final record in records) {
      if (record.createdBy.isEmpty || record.createdBy == currentUid) continue;
      final id = 'partner_${_partnerIdPrefix(record.kind)}_${record.id}';
      final notification = await _repository.createIfAbsent(
        householdId,
        id,
        HouseholdNotification(
          id: id,
          type: NotificationType.partnerActivity,
          title: _texts.partnerTitle(record.kind),
          body: switch (record.kind) {
            PartnerRecordKind.movement =>
              record.name.isEmpty ? _texts.partnerMovementBody : record.name,
            PartnerRecordKind.transfer => _texts.partnerTransferBody,
            _ => record.name,
          },
          createdAt: record.createdAt,
          read: false,
        ),
      );
      if (notification != null) {
        created.add(
          ScannedNotification(notification: notification, excludePushUid: record.createdBy),
        );
      }
    }
  }
}

/// Part of the stored notification IDs - changing one would notify again.
String _partnerIdPrefix(PartnerRecordKind kind) => switch (kind) {
  PartnerRecordKind.movement => 'tx',
  PartnerRecordKind.transfer => 'transfer',
  PartnerRecordKind.debt => 'debt',
  PartnerRecordKind.account => 'account',
  PartnerRecordKind.investment => 'investment',
  PartnerRecordKind.bill => 'bill',
  PartnerRecordKind.category => 'category',
  PartnerRecordKind.challenge => 'challenge',
  PartnerRecordKind.goal => 'goal',
};

/// Days from today until the next occurrence of [dayOfMonth] (0 = today).
int _daysUntilDayOfMonth(int dayOfMonth, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var target = DateTime(now.year, now.month, dayOfMonth);
  if (target.isBefore(today)) {
    target = DateTime(now.year, now.month + 1, dayOfMonth);
  }
  return target.difference(today).inDays;
}
