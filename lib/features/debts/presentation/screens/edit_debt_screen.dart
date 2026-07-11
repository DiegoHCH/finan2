import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/debt_model.dart';
import '../viewmodels/debt_providers.dart';

const _debtTypeIcons = <DebtType, IconData>{
  DebtType.tarjeta: Icons.credit_card_outlined,
  DebtType.credito: Icons.account_balance_outlined,
  DebtType.hipoteca: Icons.home_outlined,
  DebtType.vehiculo: Icons.directions_car_outlined,
};

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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final debt = Debt(
      id: widget.debt?.id ?? '',
      name: name,
      type: _type,
      balance: int.tryParse(_balanceController.text) ?? 0,
      rate: double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0,
      paymentDay: int.tryParse(_paymentDayController.text) ?? 1,
      creditLimit: int.tryParse(_creditLimitController.text) ?? 0,
      minPayment: int.tryParse(_minPaymentController.text) ?? 0,
      extraPayment: int.tryParse(_extraPaymentController.text) ?? 0,
      cutoffDay: int.tryParse(_cutoffDayController.text) ?? 0,
      originalAmount: int.tryParse(_originalAmountController.text) ?? 0,
      monthlyPayment: int.tryParse(_monthlyPaymentController.text) ?? 0,
      termMonths: int.tryParse(_termMonthsController.text) ?? 0,
      paidInstallments: int.tryParse(_paidInstallmentsController.text) ?? 0,
    );
    await ref.read(debtControllerProvider.notifier).save(debt);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final debt = widget.debt;
    if (debt == null) return;
    await ref.read(debtControllerProvider.notifier).delete(debt.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debt != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? 'Editar deuda' : 'Nueva deuda',
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de deuda', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
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
            Finan2Field(label: 'Nombre', controller: _nameController),
            const SizedBox(height: Finan2Space.lg),
            Text(
              'Saldo actual',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Finan2AmountInput(
              controller: _balanceController,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: Finan2Space.lg),
            if (_type.isCard) ...[
              _FieldRow(
                left: Finan2Field(
                  label: 'Cupo total',
                  controller: _creditLimitController,
                  keyboardType: TextInputType.number,
                ),
                right: Finan2Field(
                  label: 'Tasa E.A. %',
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(height: 9),
              _FieldRow(
                left: Finan2Field(
                  label: 'Pago mínimo',
                  controller: _minPaymentController,
                  keyboardType: TextInputType.number,
                ),
                right: Finan2Field(
                  label: 'Abono extra',
                  controller: _extraPaymentController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 9),
              _FieldRow(
                left: Finan2Field(
                  label: 'Día de corte',
                  controller: _cutoffDayController,
                  keyboardType: TextInputType.number,
                ),
                right: Finan2Field(
                  label: 'Día de pago',
                  controller: _paymentDayController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ] else ...[
              _FieldRow(
                left: Finan2Field(
                  label: 'Monto original',
                  controller: _originalAmountController,
                  keyboardType: TextInputType.number,
                ),
                right: Finan2Field(
                  label: 'Tasa E.A. %',
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(height: 9),
              _FieldRow(
                left: Finan2Field(
                  label: 'Cuota mensual',
                  controller: _monthlyPaymentController,
                  keyboardType: TextInputType.number,
                ),
                right: Finan2Field(
                  label: 'Plazo (cuotas)',
                  controller: _termMonthsController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 9),
              _FieldRow(
                left: Finan2Field(
                  label: 'Cuotas pagadas',
                  controller: _paidInstallmentsController,
                  keyboardType: TextInputType.number,
                ),
                right: Finan2Field(
                  label: 'Día de pago',
                  controller: _paymentDayController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.lg),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: const Text('Eliminar deuda'),
              ),
            ],
          ],
        ),
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
