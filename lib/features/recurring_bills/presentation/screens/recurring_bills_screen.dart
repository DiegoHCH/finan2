import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../core/widgets/finan2_transaction_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/entities/recurring_bill.dart';
import '../../domain/recurring_schedule.dart';
import '../recurring_schedule_label.dart';
import '../viewmodels/recurring_bill_providers.dart';
import 'edit_recurring_bill_screen.dart';

/// Fijos: what the household has committed each month, and each fijo with
/// its calendar in words. A paused one fades instead of hiding, so it's
/// there to switch back on.
class RecurringBillsScreen extends ConsumerWidget {
  const RecurringBillsScreen({super.key});

  void _open(BuildContext context, [RecurringBill? bill]) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => EditRecurringBillScreen(bill: bill)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(recurringBillsProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.recurringBillsTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
              action: Finan2HeadAction(
                icon: Finan2Icons.agregar,
                tooltip: l10n.recurringBillsNewTitle,
                filled: true,
                onTap: () => _open(context),
              ),
            ),
            Expanded(
              child: billsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (bills) {
                  if (bills.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.autorenew,
                      tone: Finan2Tone.of(context, Finan2Palette.servicios),
                      title: l10n.recurringBillsEmptyTitle,
                      description: l10n.recurringBillsEmptyDescription,
                      actionLabel: l10n.recurringBillsEmptyAction,
                      onAction: () => _open(context),
                    );
                  }
                  return _BillsList(bills: bills, open: (bill) => _open(context, bill));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillsList extends ConsumerWidget {
  const _BillsList({required this.bills, required this.open});

  final List<RecurringBill> bills;
  final ValueChanged<RecurringBill> open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final categoryById = {for (final c in categories) c.id: c};
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final today = DateTime.now();
    final commitment = monthlyCommitment(bills, today);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xxl,
      ),
      children: [
        Finan2Figure(
          label: l10n.recurringBillsCommittedLabel,
          amountText: formatMoney(commitment.amount),
          fontSize: 36,
          subtitle: Text(
            [
              l10n.recurringBillsCommittedCount(commitment.count),
              if (commitment.averaged) l10n.recurringBillsAveragedNote,
            ].join(' · '),
          ),
        ),
        const SizedBox(height: Finan2Space.lg),
        Finan2Sheet(
          children: [
            for (final bill in billsInListOrder(bills, today))
              _BillRow(
                bill: bill,
                category: categoryById[bill.categoryId],
                formatMoney: formatMoney,
                today: today,
                onTap: () => open(bill),
              ),
          ],
        ),
        const SizedBox(height: Finan2Space.md),
        Text(
          l10n.recurringBillsAutoNote,
          style: TextStyle(fontSize: 12, height: 1.5, color: colors.inkFaint),
        ),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.bill,
    required this.category,
    required this.formatMoney,
    required this.today,
    required this.onTap,
  });

  final RecurringBill bill;
  final Category? category;
  final String Function(num) formatMoney;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final status = billStatus(bill, today);
    final subLabel = switch (status) {
      RecurringBillStatus.paused => l10n.recurringBillsStatusPaused,
      RecurringBillStatus.ended => l10n.recurringBillsStatusEnded,
      RecurringBillStatus.active => [
        describeSchedule(
          scheduleOf(bill.frequency, scheduleAnchor(bill, today), until: bill.endDate),
          l10n: l10n,
          today: today,
        ),
        // What a non-monthly one adds to «Comprometido cada mes», so the
        // total can be checked by eye.
        if (bill.frequency != RecurringFrequency.monthly)
          describeMonthlyCost(bill.amount, bill.frequency, formatMoney, l10n: l10n),
      ].join(' · '),
    };
    final category = this.category;

    final row = Finan2TransactionRow(
      icon: category != null ? Finan2Icons.categoria(category.iconSlug) : Icons.autorenew,
      iconColor: category != null ? Color(category.color) : colors.inkSoft,
      description: bill.name,
      subLabel: subLabel,
      amountText: bill.isIncome ? '+${formatMoney(bill.amount)}' : formatMoney(bill.amount),
      amountColor: bill.isIncome ? colors.income : colors.ink,
      onTap: onTap,
    );
    return status == RecurringBillStatus.active ? row : Opacity(opacity: 0.55, child: row);
  }
}
