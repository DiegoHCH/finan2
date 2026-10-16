import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../../notifications/domain/entities/household_notification.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_providers.dart';
import '../../../transactions/domain/entities/movement.dart';
import '../../../transactions/presentation/movement_actions.dart';
import '../../domain/month_overview.dart';
import '../viewmodels/dashboard_providers.dart';

/// «Inicio»: one question answered at the top - how much of the month's
/// plan is left - then where the money went, who paid it, and the latest
/// movements.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.household, super.key});

  final Household household;

  void _openNotifications(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overview = ref.watch(monthOverviewProvider);
    final recent = ref.watch(recentMovementsProvider);
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final categoryById = {for (final c in categories) c.id: c};
    final formatMoney = ref.watch(moneyFormatterProvider);
    final memberLabel = ref.watch(memberLabelProvider);
    final uid = ref.watch(authStateChangesProvider).value?.uid;
    final notifications = ref.watch(notificationsProvider).value ?? const [];
    final latestUnread = notifications.where((n) => !n.read).firstOrNull;
    final unread = ref.watch(unreadNotificationsCountProvider);
    final month = DateFormat.MMMM().format(DateTime.now());
    final name = uid == null ? '?' : memberLabel(uid).firstName;
    const gap = SizedBox(height: Finan2Space.lg);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: '${household.name} · $month',
              title: name == '?' ? household.name : l10n.dashboardGreeting(name),
              action: Finan2HeadAction(
                icon: Icons.notifications_none_rounded,
                tooltip: l10n.notificationsTitle,
                badge: unread,
                onTap: () => _openNotifications(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.xs,
                  Finan2Space.lg,
                  Finan2Space.xl,
                ),
                children: [
                  _MonthFigure(overview: overview, month: month, formatMoney: formatMoney),
                  gap,
                  if (overview.slices.isEmpty && !overview.hasPlan)
                    Text(
                      l10n.dashboardNoCategorizedSpending,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    _SpendBar(overview: overview, categoryById: categoryById),
                  if (latestUnread != null) ...[
                    gap,
                    Finan2Notice(
                      icon: _noticeIcon(latestUnread.type),
                      title: latestUnread.title,
                      message: latestUnread.body,
                      actionLabel: l10n.dashboardNoticeSee,
                      kind: latestUnread.type == NotificationType.budgetExceeded
                          ? Finan2NoticeKind.over
                          : Finan2NoticeKind.now,
                      onTap: () => _openNotifications(context),
                    ),
                  ],
                  // «Quién pagó» only says something with two people.
                  if (household.members.length > 1) ...[
                    gap,
                    Text(l10n.dashboardWhoPaid, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: Finan2Space.sm),
                    Row(
                      children: [
                        for (final (i, member) in household.members.take(2).indexed) ...[
                          if (i > 0) const SizedBox(width: Finan2Space.sm),
                          Expanded(
                            child: _PayerColumn(
                              label: memberLabel(member),
                              total: overview.byPayer[member],
                              formatMoney: formatMoney,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (recent.isNotEmpty) ...[
                    gap,
                    Text(l10n.dashboardRecent, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: Finan2Space.sm),
                    Finan2Sheet(
                      children: [
                        for (final tx in recent)
                          _RecentRow(
                            tx: tx,
                            category: categoryById[tx.categoryId],
                            payer: memberLabel(tx.payer),
                            formatMoney: formatMoney,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _noticeIcon(NotificationType type) => switch (type) {
  NotificationType.debtDue => Icons.event_outlined,
  NotificationType.goalNear => Icons.track_changes_outlined,
  NotificationType.budgetExceeded => Finan2Icons.alerta,
  NotificationType.contribution => Icons.savings_outlined,
  NotificationType.partnerActivity => Icons.autorenew,
};

/// «Les queda del plan»: the month's one number, as type.
class _MonthFigure extends StatelessWidget {
  const _MonthFigure({required this.overview, required this.month, required this.formatMoney});

  final MonthOverview overview;
  final String month;
  final String Function(num) formatMoney;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final bold = TextStyle(
      fontWeight: FontWeight.w700,
      color: colors.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (!overview.hasPlan) {
      final income = formatMoney(overview.income);
      return Finan2Figure(
        label: l10n.dashboardSpentIn(month),
        amountText: formatMoney(overview.spent),
        subtitle: _boldAmounts(
          [
            l10n.dashboardNoPlan,
            if (overview.income > 0) l10n.dashboardIncomeIn(income),
          ].join(' · '),
          [income],
          bold,
        ),
      );
    }

    final left = overview.left;
    final planned = formatMoney(overview.planned);
    final perDay = overview.perDay == null ? null : formatMoney(overview.perDay!);
    return Finan2Figure(
      label: left < 0 ? l10n.dashboardOverPlan(month) : l10n.dashboardLeftOfPlan(month),
      amountText: formatMoney(left.abs()),
      amountColor: left < 0 ? colors.expense : null,
      subtitle: _boldAmounts(
        [
          l10n.dashboardOfPlan(planned),
          if (left > 0) l10n.dashboardDaysLeft(overview.daysLeft),
          ?(perDay == null ? null : l10n.dashboardPerDay(perDay)),
        ].join(' · '),
        [planned, ?perDay],
        bold,
      ),
    );
  }
}

/// [text] with each of [amounts] in [bold], like the mockup's `.sub b`.
Widget _boldAmounts(String text, List<String> amounts, TextStyle bold) {
  final spans = <InlineSpan>[];
  var rest = text;
  for (final amount in amounts) {
    final at = rest.indexOf(amount);
    if (at < 0) continue;
    spans
      ..add(TextSpan(text: rest.substring(0, at)))
      ..add(TextSpan(text: amount, style: bold));
    rest = rest.substring(at + amount.length);
  }
  spans.add(TextSpan(text: rest));
  return Text.rich(TextSpan(children: spans));
}

/// The stacked bar: one slice per category in its color, the rest of the
/// plan left as the sunken track, and a legend underneath.
class _SpendBar extends StatelessWidget {
  const _SpendBar({required this.overview, required this.categoryById});

  final MonthOverview overview;
  final Map<String, Category> categoryById;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final scale = overview.scale <= 0 ? 1 : overview.scale;
    final slices = [
      for (final slice in overview.slices)
        (
          name: slice.categoryId == null
              ? l10n.dashboardLegendOther
              : (categoryById[slice.categoryId]?.name ?? '?'),
          color: switch (categoryById[slice.categoryId]) {
            final category? => Finan2Tone.of(context, Color(category.color)).color,
            null => colors.inkFaint,
          },
          flex: (slice.amount * 1000 / scale).round().clamp(1, 1000),
        ),
    ];
    final leftFlex = overview.left > 0 ? (overview.left * 1000 / scale).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 12,
            color: colors.surfaceAlt,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, slice) in slices.indexed) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: slice.flex,
                    child: ColoredBox(color: slice.color),
                  ),
                ],
                if (leftFlex > 0) Expanded(flex: leftFlex, child: const SizedBox()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (final slice in slices) _LegendItem(color: slice.color, label: slice.name),
            if (leftFlex > 0)
              _LegendItem(
                color: colors.surfaceAlt,
                border: colors.line,
                label: l10n.dashboardLegendLeft,
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, this.border});

  final Color color;
  final String label;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            border: border == null ? null : Border.all(color: border!),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11.5, color: colors.inkSoft)),
      ],
    );
  }
}

/// One of «Quién pagó»'s two blocks, on the member's own tint.
class _PayerColumn extends StatelessWidget {
  const _PayerColumn({required this.label, required this.total, required this.formatMoney});

  final MemberLabel label;
  final PayerTotal? total;
  final String Function(num) formatMoney;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final tone = Finan2Tone.member(context, label.index);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tone.color),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(total?.amount ?? 0),
              style: Finan2Type.money.copyWith(fontSize: 19, color: colors.ink),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            context.l10n.dashboardMovementCount(total?.count ?? 0),
            style: TextStyle(fontSize: 11, color: colors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.tx,
    required this.category,
    required this.payer,
    required this.formatMoney,
  });

  final Movement tx;
  final Category? category;
  final MemberLabel payer;
  final String Function(num) formatMoney;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final category = this.category;
    return Finan2TransactionRow(
      icon: category != null ? Finan2Icons.categoria(category.iconSlug) : Icons.label_outline,
      iconColor: category != null ? Color(category.color) : colors.inkSoft,
      description: tx.description.isEmpty ? (category?.name ?? '') : tx.description,
      subLabel: '· ${DateFormat('d MMM').format(tx.date)}',
      avatarLabel: payer.firstName,
      avatarIndex: payer.index,
      amountText: tx.isIncome ? '+${formatMoney(tx.amount)}' : '−${formatMoney(tx.amount)}',
      amountColor: tx.isIncome ? colors.income : colors.ink,
      onTap: () => openMovement(context, tx),
    );
  }
}
