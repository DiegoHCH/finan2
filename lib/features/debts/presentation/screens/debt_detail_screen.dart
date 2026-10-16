import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_person_tag.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_tile.dart';
import '../../../../core/widgets/finan2_with_text_controller.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../domain/debt_plan.dart';
import '../../domain/entities/card_payment.dart';
import '../../domain/entities/debt.dart';
import '../debt_style.dart';
import '../viewmodels/card_payment_providers.dart';
import '../viewmodels/debt_providers.dart';
import 'edit_debt_screen.dart';

/// Deudas · detalle: what's left to pay, and the calendar - payments made
/// dimmed with a check, the next one the only one in the action color
/// saying in how many days, the rest as planned.
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
    final payments = current.type.isCard
        ? (ref.watch(cardPaymentsProvider(current.id)).value ?? const <CardPayment>[])
        : const <CardPayment>[];
    final today = DateTime.now();
    final calendar = debtCalendar(
      payments: payments,
      schedule: current.balance > 0 ? schedule : const [],
      paymentDay: current.paymentDay,
      today: today,
    );
    final l10n = context.l10n;
    final rate = ratePercent(current.rate);

    final String status;
    if (current.balance <= 0) {
      status = l10n.debtsStatusPaidOff;
    } else if (schedule.isNotEmpty && schedule.last.endingBalance <= 0) {
      status = l10n.debtsStatusFreeBy(DateFormat('MMMM y').format(schedule.last.month));
    } else {
      status = l10n.debtsStatusCannotPayOff;
    }

    return Scaffold(
      appBar: Finan2FormTop(
        title: current.name,
        backIcon: true,
        saveLabel: l10n.commonEdit,
        onSave: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => EditDebtScreen(debt: current))),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.md,
                  Finan2Space.lg,
                  Finan2Space.xl,
                ),
                children: [
                  Finan2Figure(
                    centered: true,
                    label: l10n.debtsCurrentBalance,
                    amountText: formatMoney(current.balance),
                    subtitle: Column(
                      children: [
                        Text(
                          l10n.debtsDetailSub(
                            formatMoney(current.referenceAmount),
                            (current.paidFraction * 100).round(),
                            status,
                          ),
                        ),
                        Text(
                          current.extraPayment > 0
                              ? l10n.debtsRateExtra(rate, formatMoney(current.extraPayment))
                              : l10n.debtsRateOnly(rate),
                          style: TextStyle(fontSize: 12, color: colors.inkFaint),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Finan2Space.xl),
                  Text(l10n.debtsPaymentSchedule, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: Finan2Space.sm),
                  Finan2Sheet(
                    children: [
                      if (calendar.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Finan2Space.md),
                          child: Text(
                            current.balance <= 0
                                ? l10n.debtsAlreadyPaidOff
                                : l10n.debtsNoProjection,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      else
                        for (final entry in calendar)
                          _CalendarRow(
                            entry: entry,
                            today: today,
                            onTap: entry.payment == null
                                ? null
                                : () => _deletePayment(context, ref, entry.payment!),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            if (current.type.isCard)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.sm,
                  Finan2Space.lg,
                  Finan2Space.lg,
                ),
                child: FilledButton(
                  onPressed: () => _registerPayment(context, ref, current.id),
                  child: Text(l10n.debtsRecordPayment),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A line of the calendar. Made: faint, with a check and who paid. Next:
/// the action color and how soon. Planned: the sunken tone.
class _CalendarRow extends ConsumerWidget {
  const _CalendarRow({required this.entry, required this.today, this.onTap});

  final DebtCalendarEntry entry;
  final DateTime today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = context.l10n;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final memberLabel = ref.watch(memberLabelProvider);
    final paid = entry.kind == DebtCalendarKind.paid;

    final (IconData icon, Finan2Tone tone) = switch (entry.kind) {
      DebtCalendarKind.paid => (Icons.check_rounded, Finan2Tone(colors.saving, colors.savingTint)),
      DebtCalendarKind.next => (Icons.schedule_rounded, Finan2Tone(accent, colors.brandTint)),
      DebtCalendarKind.planned => (
        Icons.calendar_today_outlined,
        Finan2Tone(colors.inkFaint, colors.surfaceAlt),
      ),
    };
    final faint = TextStyle(fontSize: 11.5, color: colors.inkFaint);
    final Widget sub = switch (entry.kind) {
      DebtCalendarKind.paid => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l10n.debtsPaidBy} ', style: faint),
          Flexible(
            child: Finan2PersonTag(
              label: memberLabel(entry.payment!.createdBy).firstName,
              memberIndex: memberLabel(entry.payment!.createdBy).index,
            ),
          ),
        ],
      ),
      DebtCalendarKind.next => Text(
        l10n.debtsInDays(daysUntil(entry.date, today)),
        style: faint.copyWith(color: accent, fontWeight: FontWeight.w600),
      ),
      DebtCalendarKind.planned => Text(l10n.debtsScheduledPayment, style: faint),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Finan2Tile(icon: icon, tone: tone),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.MMMMd().format(entry.date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: paid ? colors.inkFaint : colors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  sub,
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatMoney(entry.amount),
              style: Finan2Type.money.copyWith(
                fontSize: 15,
                letterSpacing: -0.15,
                color: paid ? colors.inkFaint : colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _deletePayment(BuildContext context, WidgetRef ref, CardPayment payment) async {
  final l10n = context.l10n;
  final confirmed = await showFinan2ConfirmSheet(
    context,
    title: l10n.debtsDeletePayment,
    message: l10n.debtsDeletePaymentMessage(
      ref.read(moneyFormatterProvider)(payment.amount),
      DateFormat.MMMMd().format(payment.date),
    ),
    confirmLabel: l10n.commonDelete,
    destructive: true,
  );
  if (!confirmed) return;
  await ref.read(cardPaymentControllerProvider.notifier).deletePayment(payment);
  final result = ref.read(cardPaymentControllerProvider);
  if (result.hasError && context.mounted) {
    await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error!));
  }
}

Future<void> _registerPayment(BuildContext context, WidgetRef ref, String cardDebtId) async {
  final accounts = ref.read(accountsProvider).value ?? const <Account>[];
  if (accounts.isEmpty) {
    await showFinan2ErrorSheet(context, message: context.l10n.debtsNeedAccountFirst);
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
                        final amount = Finan2AmountInput.parse(controller.text) ?? 0;
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
