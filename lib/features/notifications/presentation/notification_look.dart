import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/finan2_tone.dart';
import '../../accounts/presentation/viewmodels/account_providers.dart';
import '../../categories/presentation/viewmodels/category_providers.dart';
import '../../debts/domain/entities/debt.dart';
import '../../debts/presentation/debt_style.dart';
import '../../debts/presentation/viewmodels/debt_providers.dart';
import '../../household/presentation/viewmodels/member_providers.dart';
import '../../investments/presentation/viewmodels/investment_providers.dart';
import '../../recurring_bills/presentation/viewmodels/recurring_bill_providers.dart';
import '../../savings_challenge/presentation/viewmodels/savings_challenge_providers.dart';
import '../../savings_goals/presentation/goal_style.dart';
import '../../savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import '../../transactions/presentation/viewmodels/transaction_providers.dart';
import '../../transfers/presentation/viewmodels/transfer_providers.dart';
import '../domain/entities/household_notification.dart';
import '../domain/notification_scanner.dart';
import '../domain/notification_subject.dart';

/// Who added each record a partner notice can be about, by the record's ID
/// - to paint the notice in that person's color.
final recordCreatorsProvider = Provider<Map<String, String>>((ref) {
  return {
    for (final tx in [...?ref.watch(transactionsForMonthProvider).value]) tx.id: tx.createdBy,
    for (final t in [...?ref.watch(transfersProvider).value]) t.id: t.createdBy,
    for (final d in [...?ref.watch(debtsProvider).value]) d.id: d.createdBy,
    for (final a in [...?ref.watch(accountsProvider).value]) a.id: a.createdBy,
    for (final i in [...?ref.watch(investmentsProvider).value]) i.id: i.createdBy,
    for (final b in [...?ref.watch(recurringBillsProvider).value]) b.id: b.createdBy,
    for (final c in [...?ref.watch(categoriesProvider).value]) c.id: c.createdBy,
    for (final g in [...?ref.watch(savingsGoalsProvider).value]) g.id: g.createdBy,
    if (ref.watch(savingsChallengeProvider).value case final challenge?)
      challenge.id: challenge.createdBy,
  };
});

/// A notice's icon and the tone of what it's about: the person who did
/// it, the debt or goal in their own colors, or red when something went
/// over. What can't be traced any more keeps a quiet tone.
class NotificationLook {
  const NotificationLook(this.icon, this.tone);

  final IconData icon;
  final Finan2Tone tone;
}

NotificationLook notificationLook(
  BuildContext context,
  WidgetRef ref,
  HouseholdNotification notification,
) {
  final colors = Theme.of(context).extension<Finan2Colors>()!;
  final quiet = Finan2Tone(colors.inkSoft, colors.surfaceAlt);
  Finan2Tone? person(String? uid) => uid == null || uid.isEmpty
      ? null
      : Finan2Tone.member(context, ref.watch(memberLabelProvider)(uid).index);

  switch (notificationSubject(notification.id)) {
    case OverspentSubject(:final categoryId):
      final category = (ref.watch(categoriesProvider).value ?? const [])
          .where((c) => c.id == categoryId)
          .firstOrNull;
      return NotificationLook(
        category != null ? Finan2Icons.categoria(category.iconSlug) : Finan2Icons.alerta,
        Finan2Tone(colors.expense, colors.expenseTint),
      );
    case DebtSubject(:final debtId):
      final debt = (ref.watch(debtsProvider).value ?? const [])
          .where((d) => d.id == debtId)
          .firstOrNull;
      return NotificationLook(
        debt == null || debt.type.isCard ? Finan2Icons.tarjetaDebito : Finan2Icons.banco,
        Finan2Tone.of(context, debtColor(debtId)),
      );
    case GoalSubject(:final goalId):
      final goal = (ref.watch(savingsGoalsProvider).value ?? const [])
          .where((g) => g.id == goalId)
          .firstOrNull;
      return NotificationLook(
        goal != null ? goalIcon(goal.iconSlug) : Icons.savings_outlined,
        goalTone(context, const [], goalId),
      );
    case ContributionSubject(:final goalId, :final date):
      final goal = (ref.watch(savingsGoalsProvider).value ?? const [])
          .where((g) => g.id == goalId)
          .firstOrNull;
      final contribution = goal?.contributions
          .where((c) => c.date.millisecondsSinceEpoch == date.millisecondsSinceEpoch)
          .firstOrNull;
      return NotificationLook(
        Icons.savings_outlined,
        person(contribution?.createdBy) ?? goalTone(context, const [], goalId),
      );
    case PartnerSubject(:final kind, :final recordId):
      return NotificationLook(
        _partnerIcons[kind]!,
        person(ref.watch(recordCreatorsProvider)[recordId]) ?? quiet,
      );
    case UnknownSubject():
      return NotificationLook(
        _typeIcons[notification.type]!,
        notification.type == NotificationType.budgetExceeded
            ? Finan2Tone(colors.expense, colors.expenseTint)
            : quiet,
      );
  }
}

const _partnerIcons = {
  PartnerRecordKind.movement: Icons.edit_outlined,
  PartnerRecordKind.transfer: Icons.swap_vert,
  PartnerRecordKind.debt: Finan2Icons.tarjetaDebito,
  PartnerRecordKind.account: Finan2Icons.cuentas,
  PartnerRecordKind.investment: Icons.trending_up,
  PartnerRecordKind.bill: Icons.autorenew,
  PartnerRecordKind.category: Finan2Icons.categorias,
  PartnerRecordKind.challenge: Icons.grid_view_rounded,
  PartnerRecordKind.goal: Finan2Icons.metas,
};

const _typeIcons = {
  NotificationType.debtDue: Finan2Icons.tarjetaDebito,
  NotificationType.goalNear: Finan2Icons.metas,
  NotificationType.budgetExceeded: Finan2Icons.alerta,
  NotificationType.contribution: Icons.savings_outlined,
  NotificationType.partnerActivity: Icons.edit_outlined,
};
