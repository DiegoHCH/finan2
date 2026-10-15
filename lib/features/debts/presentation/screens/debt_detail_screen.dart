import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_with_text_controller.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_stat_box.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/avalanche_calculator.dart';
import '../../domain/entities/card_payment.dart';
import '../../domain/entities/debt.dart';
import '../debt_status_color.dart';
import '../viewmodels/card_payment_providers.dart';
import '../viewmodels/debt_providers.dart';
import 'edit_debt_screen.dart';

class DebtDetailScreen extends ConsumerWidget {
  const DebtDetailScreen({required this.debt, super.key});

  final Debt debt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    final current = debts.firstWhere((d) => d.id == debt.id, orElse: () => debt);
    final avalanche = ref.watch(avalancheResultProvider);
    final schedule = avalanche.scheduleByDebtId[current.id] ?? const [];
    final accent = current.type.isCard ? colors.expense : colors.saving;
    final l10n = context.l10n;

    final ratePct = current.rate == current.rate.roundToDouble()
        ? current.rate.toStringAsFixed(0)
        : current.rate.toStringAsFixed(1);

    final String statusText;
    if (current.balance <= 0) {
      statusText = l10n.debtsStatusPaidOff;
    } else if (schedule.isNotEmpty && schedule.last.endingBalance <= 0) {
      final formatted = DateFormat.yMMMM().format(schedule.last.month);
      statusText = l10n.debtsStatusFreeBy('${formatted[0].toUpperCase()}${formatted.substring(1)}');
    } else {
      statusText = l10n.debtsStatusCannotPayOff;
    }

    return Scaffold(
      floatingActionButton: current.type.isCard
          ? FloatingActionButton(
              heroTag: 'debtDetailFab',
              backgroundColor: colors.expense,
              onPressed: () => _registerPayment(context, ref, current.id),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Finan2BackHead(
              title: current.name,
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined, size: 20, color: colors.inkSoft),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => EditDebtScreen(debt: current))),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.debtsCurrentBalance,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.inkFaint,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatMoney(current.balance),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: colors.expense,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          l10n.debtsRateWithStatus(ratePct, statusText),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, color: colors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Row(
                    children: current.type.isCard
                        ? [
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: l10n.debtsMinPaymentShort,
                                value: formatMoney(current.minPayment),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: l10n.debtsExtraPayment,
                                value: formatMoney(current.extraPayment),
                                valueColor: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: l10n.debtsPaid,
                                value: '${(current.paidFraction * 100).round()}%',
                                valueColor: current.status.of(colors),
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: l10n.debtsMonthlyInstallment,
                                value: formatMoney(current.monthlyPayment),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: current.extraPayment > 0
                                  ? Finan2StatBox(
                                      dense: true,
                                      label: l10n.debtsExtraPayment,
                                      value: formatMoney(current.extraPayment),
                                      valueColor: Theme.of(context).colorScheme.primary,
                                    )
                                  : Finan2StatBox(
                                      dense: true,
                                      label: l10n.debtsInstallmentsLeft,
                                      value:
                                          '${(current.termMonths - current.paidInstallments).clamp(0, current.termMonths)}',
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Finan2StatBox(
                                dense: true,
                                label: l10n.debtsPaid,
                                value: '${(current.paidFraction * 100).round()}%',
                                valueColor: current.status.of(colors),
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(Finan2Radius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Text(
                            l10n.debtsPaymentSchedule,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        if (schedule.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              current.balance <= 0
                                  ? l10n.debtsAlreadyPaidOff
                                  : l10n.debtsNoProjection,
                              style: TextStyle(fontSize: 12, color: colors.inkSoft),
                            ),
                          )
                        else
                          for (var i = 0; i < schedule.length.clamp(0, 6); i++)
                            _ScheduleRow(
                              entry: schedule[i],
                              paymentDay: current.paymentDay,
                              label: i == 0 ? l10n.debtsNextPayment : l10n.debtsScheduledPayment,
                              accent: accent,
                              showDivider: i < schedule.length.clamp(0, 6) - 1,
                            ),
                      ],
                    ),
                  ),
                  if (current.type.isCard) ...[
                    const SizedBox(height: Finan2Space.lg),
                    _CardPaymentsSection(cardDebtId: current.id),
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

Future<void> _registerPayment(BuildContext context, WidgetRef ref, String cardDebtId) async {
  final accounts = ref.read(accountsProvider).value ?? const <Account>[];
  if (accounts.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.debtsNeedAccountFirst)));
    return;
  }
  final currencySymbol = currencySymbolFor(ref.read(currentCurrencyProvider));
  var selectedAccountId = accounts.first.id;
  var submitting = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Finan2WithTextController(
      builder: (_, controller) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            Finan2Space.xl,
            Finan2Space.lg,
            Finan2Space.xl,
            MediaQuery.of(sheetContext).viewInsets.bottom + Finan2Space.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sheetContext.l10n.debtsRecordPayment,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: Finan2Space.md),
              Finan2AmountInput(
                controller: controller,
                autofocus: true,
                currencySymbol: currencySymbol,
              ),
              const SizedBox(height: Finan2Space.md),
              Text(
                sheetContext.l10n.debtsPaymentFrom,
                style: Theme.of(sheetContext).textTheme.labelMedium,
              ),
              const SizedBox(height: Finan2Space.sm),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final account in accounts)
                    Finan2Chip(
                      label: account.name,
                      selected: selectedAccountId == account.id,
                      onTap: () => setSheetState(() => selectedAccountId = account.id),
                    ),
                ],
              ),
              const SizedBox(height: Finan2Space.lg),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        final amount = int.tryParse(controller.text) ?? 0;
                        if (amount > 0) {
                          setSheetState(() => submitting = true);
                          await ref
                              .read(cardPaymentControllerProvider.notifier)
                              .createPayment(
                                CardPayment(
                                  id: '',
                                  amount: amount,
                                  fromAccountId: selectedAccountId,
                                  cardDebtId: cardDebtId,
                                  date: DateTime.now(),
                                  createdBy: ref.read(authStateChangesProvider).value?.uid ?? '',
                                ),
                              );
                        }
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      },
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(sheetContext.l10n.debtsRecordPayment),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CardPaymentsSection extends ConsumerWidget {
  const _CardPaymentsSection({required this.cardDebtId});

  final String cardDebtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final payments = ref.watch(cardPaymentsProvider(cardDebtId)).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountById = {for (final a in accounts) a.id: a};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(Finan2Radius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text(
              context.l10n.debtsRecordedPayments,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.ink),
            ),
          ),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                context.l10n.debtsNoCardPayments,
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              ),
            )
          else
            for (var i = 0; i < payments.length; i++)
              _CardPaymentRow(
                payment: payments[i],
                accountName:
                    accountById[payments[i].fromAccountId]?.name ??
                    context.l10n.debtsDeletedAccount,
                showDivider: i < payments.length - 1,
              ),
        ],
      ),
    );
  }
}

class _CardPaymentRow extends ConsumerWidget {
  const _CardPaymentRow({
    required this.payment,
    required this.accountName,
    required this.showDivider,
  });

  final CardPayment payment;
  final String accountName;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.line)),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(payment.date),
                  style: TextStyle(fontSize: 10.5, color: colors.inkFaint),
                ),
              ],
            ),
          ),
          Text(
            '−${formatMoney(payment.amount)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.expense),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: colors.inkFaint),
            onPressed: () =>
                ref.read(cardPaymentControllerProvider.notifier).deletePayment(payment),
            tooltip: context.l10n.debtsDeletePayment,
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({
    required this.entry,
    required this.paymentDay,
    required this.label,
    required this.accent,
    required this.showDivider,
  });

  final DebtScheduleEntry entry;
  final int paymentDay;
  final String label;
  final Color accent;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.line)),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Text(
                  _monthAbbrev(entry.month),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: colors.inkFaint,
                  ),
                ),
                Text(
                  paymentDay.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(
                  context.l10n.debtsScheduleBalance(formatMoney(entry.endingBalance)),
                  style: TextStyle(fontSize: 10.5, color: colors.inkFaint),
                ),
              ],
            ),
          ),
          Text(
            formatMoney(entry.payment),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accent),
          ),
        ],
      ),
    );
  }
}

String _monthAbbrev(DateTime date) {
  final raw = DateFormat('MMM').format(date).replaceAll('.', '');
  return raw.isEmpty ? raw : '${raw[0].toUpperCase()}${raw.substring(1)}';
}
