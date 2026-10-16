import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../domain/entities/debt.dart';
import '../../domain/loan_payoff.dart';
import '../../data/debt_mapper.dart';
import '../viewmodels/debt_providers.dart';
import '../widgets/card_preview.dart';

const _debtTypeIcons = <DebtType, IconData>{
  DebtType.tarjeta: Icons.credit_card_outlined,
  DebtType.credito: Icons.account_balance_outlined,
  DebtType.hipoteca: Icons.home_outlined,
  DebtType.vehiculo: Icons.directions_car_outlined,
};

/// Tarjetas y créditos · configurar. A card is drawn as a card while it's
/// typed; a loan says when it ends and how much sooner paying a bit more.
class EditDebtScreen extends ConsumerStatefulWidget {
  const EditDebtScreen({this.debt, super.key});

  final Debt? debt;

  @override
  ConsumerState<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends ConsumerState<EditDebtScreen> {
  late final _nameController = TextEditingController(text: widget.debt?.name ?? '');
  late final _balanceController = TextEditingController(
    text: widget.debt != null ? widget.debt!.balance.toString() : '',
  );
  late final _rateController = TextEditingController(
    text: widget.debt != null ? _formatRate(widget.debt!.rate) : '',
  );
  late final _paymentDayController = TextEditingController(
    text: widget.debt != null ? widget.debt!.paymentDay.toString() : '',
  );
  late final _creditLimitController = TextEditingController(
    text: widget.debt != null ? widget.debt!.creditLimit.toString() : '',
  );
  late final _minPaymentController = TextEditingController(
    text: widget.debt != null ? widget.debt!.minPayment.toString() : '',
  );
  late final _extraPaymentController = TextEditingController(
    text: widget.debt != null ? widget.debt!.extraPayment.toString() : '',
  );
  late final _cutoffDayController = TextEditingController(
    text: widget.debt != null ? widget.debt!.cutoffDay.toString() : '',
  );
  late final _originalAmountController = TextEditingController(
    text: widget.debt != null ? widget.debt!.originalAmount.toString() : '',
  );
  late final _monthlyPaymentController = TextEditingController(
    text: widget.debt != null ? widget.debt!.monthlyPayment.toString() : '',
  );
  late final _termMonthsController = TextEditingController(
    text: widget.debt != null ? widget.debt!.termMonths.toString() : '',
  );
  late final _paidInstallmentsController = TextEditingController(
    text: widget.debt != null ? widget.debt!.paidInstallments.toString() : '',
  );
  late DebtType _type = widget.debt?.type ?? DebtType.tarjeta;

  static String _formatRate(double rate) =>
      rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _rateController.dispose();
    _paymentDayController.dispose();
    _creditLimitController.dispose();
    _minPaymentController.dispose();
    _extraPaymentController.dispose();
    _cutoffDayController.dispose();
    _originalAmountController.dispose();
    _monthlyPaymentController.dispose();
    _termMonthsController.dispose();
    _paidInstallmentsController.dispose();
    super.dispose();
  }

  /// The debt as typed so far - what's saved, and what the card preview
  /// and the loan's end date are drawn from.
  Debt _draft() => Debt(
    id: widget.debt?.id ?? '',
    name: toTitleCase(_nameController.text),
    type: _type,
    balance: Finan2AmountInput.parse(_balanceController.text) ?? 0,
    rate: double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0,
    paymentDay: int.tryParse(_paymentDayController.text) ?? 1,
    creditLimit: Finan2AmountInput.parse(_creditLimitController.text) ?? 0,
    minPayment: Finan2AmountInput.parse(_minPaymentController.text) ?? 0,
    extraPayment: Finan2AmountInput.parse(_extraPaymentController.text) ?? 0,
    cutoffDay: int.tryParse(_cutoffDayController.text) ?? 0,
    originalAmount: Finan2AmountInput.parse(_originalAmountController.text) ?? 0,
    monthlyPayment: Finan2AmountInput.parse(_monthlyPaymentController.text) ?? 0,
    termMonths: int.tryParse(_termMonthsController.text) ?? 0,
    paidInstallments: int.tryParse(_paidInstallmentsController.text) ?? 0,
    createdBy: widget.debt?.createdBy ?? ref.read(authStateChangesProvider).value?.uid ?? '',
  );

  Future<void> _save() async {
    final debt = _draft();
    if (debt.name.isEmpty) return;
    await ref.read(debtControllerProvider.notifier).save(debt);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final debt = widget.debt;
    if (debt == null) return;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: context.l10n.debtsDelete,
      message: context.l10n.debtsDeleteMessage(debt.name),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(debtControllerProvider.notifier).delete(debt.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debt != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    const gap = SizedBox(height: 9);

    Finan2Field number(String label, TextEditingController controller, {bool decimal = false}) =>
        Finan2Field(
          label: label,
          controller: controller,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
        );
    Finan2Field money(String label, TextEditingController controller) =>
        Finan2Field(label: label, controller: controller, moneySymbol: currencySymbol);

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.debtsEditTitle : l10n.debtsFormTitle(_type.name),
        closeIcon: true,
        saveLabel: isEditing ? null : l10n.commonCreate,
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Finan2Space.lg,
          Finan2Space.sm,
          Finan2Space.lg,
          Finan2Space.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final type in DebtType.values)
                  Finan2Chip(
                    icon: _debtTypeIcons[type],
                    label: type.label,
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            if (_type.isCard) ...[
              _LiveCardPreview(
                name: _nameController,
                limit: _creditLimitController,
                cutoffDay: _cutoffDayController,
                paymentDay: _paymentDayController,
              ),
              const SizedBox(height: Finan2Space.md),
              Finan2Field(label: l10n.commonName, controller: _nameController),
              gap,
              _FieldRow(
                left: money(l10n.debtsCreditLimit, _creditLimitController),
                right: number(l10n.debtsRatePercent, _rateController, decimal: true),
              ),
              gap,
              _FieldRow(
                left: number(l10n.debtsCutoffDay, _cutoffDayController),
                right: number(l10n.debtsPaymentDay, _paymentDayController),
              ),
              gap,
              _FieldRow(
                left: money(l10n.debtsOwedToday, _balanceController),
                right: money(l10n.debtsMinPayment, _minPaymentController),
              ),
              gap,
              money(l10n.debtsExtraPayment, _extraPaymentController),
            ] else ...[
              Finan2Field(label: l10n.commonName, controller: _nameController),
              const SizedBox(height: Finan2Space.lg),
              Finan2AmountInput(
                controller: _balanceController,
                currencySymbol: currencySymbol,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 44),
              ),
              const SizedBox(height: Finan2Space.xxs),
              Text(
                l10n.debtsOwedToday,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.inkFaint),
              ),
              const SizedBox(height: Finan2Space.lg),
              _FieldRow(
                left: number(l10n.debtsRatePercent, _rateController, decimal: true),
                right: money(l10n.debtsMonthlyInstallment, _monthlyPaymentController),
              ),
              gap,
              _FieldRow(
                left: number(l10n.debtsPaymentDay, _paymentDayController),
                right: money(l10n.debtsExtraPayment, _extraPaymentController),
              ),
              gap,
              _FieldRow(
                left: number(l10n.debtsTermInstallments, _termMonthsController),
                right: number(l10n.debtsPaidInstallments, _paidInstallmentsController),
              ),
              gap,
              money(l10n.debtsOriginalAmount, _originalAmountController),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _balanceController,
                  _rateController,
                  _monthlyPaymentController,
                  _extraPaymentController,
                ]),
                builder: (context, _) => _PayoffNotice(draft: _draft()),
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.lg),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: Text(l10n.debtsDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// [CardPreview] redrawn as the name, the limit and the days are typed.
class _LiveCardPreview extends ConsumerWidget {
  const _LiveCardPreview({
    required this.name,
    required this.limit,
    required this.cutoffDay,
    required this.paymentDay,
  });

  final TextEditingController name;
  final TextEditingController limit;
  final TextEditingController cutoffDay;
  final TextEditingController paymentDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatMoney = ref.watch(moneyFormatterProvider);
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([name, limit, cutoffDay, paymentDay]),
      builder: (context, _) {
        final cutoff = int.tryParse(cutoffDay.text) ?? 0;
        final pay = int.tryParse(paymentDay.text) ?? 0;
        final typed = toTitleCase(name.text);
        return CardPreview(
          name: typed.isEmpty ? l10n.debtsCardPlaceholder : typed,
          limitLabel: l10n.debtsCreditLimit,
          limitText: formatMoney(Finan2AmountInput.parse(limit.text) ?? 0),
          daysText: cutoff > 0 && pay > 0
              ? l10n.debtsCardDays(cutoff, pay)
              : pay > 0
              ? l10n.debtsCardPayDay(pay)
              : '—',
        );
      },
    );
  }
}

/// Créditos · configurar: once the balance and the payment are in, when
/// the loan ends - and how much sooner paying a bit more each month.
class _PayoffNotice extends ConsumerWidget {
  const _PayoffNotice({required this.draft});

  final Debt draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = loanPayoffPreview(draft, DateTime.now());
    if (preview == null) return const SizedBox.shrink();
    final formatMoney = ref.watch(moneyFormatterProvider);
    final l10n = context.l10n;
    final month = DateFormat.yMMMM();
    final end = preview.end;
    final sooner = preview.endWithMore;

    return Padding(
      padding: const EdgeInsets.only(top: Finan2Space.lg),
      child: end == null
          ? Finan2Notice(
              kind: Finan2NoticeKind.over,
              icon: Icons.event_busy_outlined,
              title: l10n.debtsNeverEnds,
              message: l10n.debtsNeverEndsHint,
            )
          : Finan2Notice(
              kind: Finan2NoticeKind.calm,
              icon: Icons.event_outlined,
              title: l10n.debtsEndsIn(month.format(end)),
              message: sooner == null || !sooner.isBefore(end)
                  ? null
                  : l10n.debtsEndsSooner(formatMoney(preview.more), month.format(sooner)),
            ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 9),
        Expanded(child: right),
      ],
    );
  }
}
