import '../../accounts/data/account_model.dart';
import '../../categories/data/category_model.dart';
import '../../debts/domain/entities/debt.dart';
import '../../investments/data/investment_model.dart';
import '../../notification_prefs/data/notification_prefs.dart';
import '../../recurring_bills/domain/entities/recurring_bill.dart';
import '../../savings_challenge/data/savings_challenge_model.dart';
import '../../savings_goals/data/savings_goal_model.dart';
import '../../transactions/domain/entities/movement.dart';
import '../../transfers/data/transfer_model.dart';
import '../domain/notification_scanner.dart';

/// Feeds NotificationScanner from the household's data as the app holds
/// it, turning each feature's records into what the scanner's rules read.
extension NotificationScanSources on NotificationScanner {
  Future<List<ScannedNotification>> scan({
    required String householdId,
    required String currentUid,
    required List<Debt> debts,
    required List<SavingsGoal> goals,
    required Map<String, int> budget,
    required List<Movement> transactionsThisMonth,
    required List<Category> categories,
    required NotificationPrefs prefs,
    List<Account> accounts = const [],
    List<Investment> investments = const [],
    List<RecurringBill> recurringBills = const [],
    List<Transfer> transfers = const [],
    SavingsChallenge? savingsChallenge,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    PartnerRecord record(
      PartnerRecordKind kind,
      String id,
      String createdBy,
      String name, [
      DateTime? createdAt,
    ]) => PartnerRecord(
      kind: kind,
      id: id,
      createdBy: createdBy,
      name: name,
      createdAt: createdAt ?? at,
    );

    return detect(
      householdId: householdId,
      currentUid: currentUid,
      rules: NotificationRules(
        debtPayments: prefs.debtPayments,
        goalProgress: prefs.goalProgress,
        budgetExceeded: prefs.budgetExceeded,
        partnerActivity: prefs.partnerActivity,
      ),
      debts: debts,
      goals: [
        for (final goal in goals)
          TrackedGoal(
            id: goal.id,
            name: goal.name,
            progressFraction: goal.progressFractionAsOf(at),
            contributions: [
              for (final c in goal.contributions)
                TrackedContribution(createdBy: c.createdBy, date: c.date),
            ],
          ),
      ],
      budget: budget,
      transactionsThisMonth: transactionsThisMonth,
      categoryNames: {for (final c in categories) c.id: c.name},
      partnerRecords: [
        for (final tx in transactionsThisMonth)
          record(PartnerRecordKind.movement, tx.id, tx.createdBy, tx.description, tx.date),
        for (final t in transfers)
          record(PartnerRecordKind.transfer, t.id, t.createdBy, '', t.date),
        for (final d in debts) record(PartnerRecordKind.debt, d.id, d.createdBy, d.name),
        for (final a in accounts) record(PartnerRecordKind.account, a.id, a.createdBy, a.name),
        for (final i in investments)
          record(PartnerRecordKind.investment, i.id, i.createdBy, i.name),
        for (final b in recurringBills) record(PartnerRecordKind.bill, b.id, b.createdBy, b.name),
        for (final c in categories) record(PartnerRecordKind.category, c.id, c.createdBy, c.name),
        if (savingsChallenge case final challenge?)
          record(PartnerRecordKind.challenge, challenge.id, challenge.createdBy, challenge.name),
        for (final g in goals) record(PartnerRecordKind.goal, g.id, g.createdBy, g.name),
      ],
      now: at,
    );
  }
}
