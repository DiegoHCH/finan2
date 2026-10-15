import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/investment_model.dart';
import '../viewmodels/investment_providers.dart';

const _kindIcons = <InvestmentKind, IconData>{
  InvestmentKind.rentaFija: Icons.account_balance_outlined,
  InvestmentKind.rentaVariable: Icons.trending_up,
  InvestmentKind.cripto: Icons.currency_bitcoin,
};

class EditInvestmentScreen extends ConsumerStatefulWidget {
  const EditInvestmentScreen({this.investment, super.key});

  final Investment? investment;

  @override
  ConsumerState<EditInvestmentScreen> createState() => _EditInvestmentScreenState();
}

class _EditInvestmentScreenState extends ConsumerState<EditInvestmentScreen> {
  late final _nameController = TextEditingController(text: widget.investment?.name ?? '');
  late final _investedController = TextEditingController(
    text: widget.investment != null ? widget.investment!.investedAmount.toString() : '',
  );
  late final _currentValueController = TextEditingController(
    text: widget.investment != null ? widget.investment!.currentValue.toString() : '',
  );
  late final _rateController = TextEditingController(
    text: widget.investment != null && widget.investment!.rate > 0
        ? _formatRate(widget.investment!.rate)
        : '',
  );
  late InvestmentKind _kind = widget.investment?.kind ?? InvestmentKind.rentaFija;

  static String _formatRate(double rate) =>
      rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentValueController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = toTitleCase(_nameController.text);
    if (name.isEmpty) return;
    final investment = Investment(
      id: widget.investment?.id ?? '',
      name: name,
      kind: _kind,
      rate: _kind == InvestmentKind.rentaFija
          ? double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0
          : 0,
      investedAmount: int.tryParse(_investedController.text) ?? 0,
      currentValue: int.tryParse(_currentValueController.text) ?? 0,
      createdBy:
          widget.investment?.createdBy ?? ref.read(authStateChangesProvider).value?.uid ?? '',
    );
    await ref.read(investmentControllerProvider.notifier).save(investment);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final investment = widget.investment;
    if (investment == null) return;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: context.l10n.investmentsDelete,
      message: context.l10n.investmentsDeleteMessage(investment.name),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(investmentControllerProvider.notifier).delete(investment.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investment != null;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.investmentsEditTitle : l10n.investmentsNewTitle,
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.investmentsKindField, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final kind in InvestmentKind.values)
                  Finan2Chip(
                    icon: _kindIcons[kind],
                    label: kind.label,
                    selected: _kind == kind,
                    onTap: () => setState(() => _kind = kind),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(label: l10n.commonName, controller: _nameController),
            const SizedBox(height: Finan2Space.lg),
            Row(
              children: [
                Expanded(
                  child: Finan2Field(
                    label: l10n.investmentsInvested,
                    controller: _investedController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Finan2Field(
                    label: l10n.investmentsCurrentValue,
                    controller: _currentValueController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            if (_kind == InvestmentKind.rentaFija) ...[
              const SizedBox(height: Finan2Space.md),
              Finan2Field(
                label: l10n.investmentsRate,
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xxl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: Text(l10n.investmentsDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
