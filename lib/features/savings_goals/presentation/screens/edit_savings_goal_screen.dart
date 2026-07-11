import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_goal_model.dart';
import '../viewmodels/savings_goal_providers.dart';

const _iconOptions = <String, IconData>{
  'viaje': Icons.flight_outlined,
  'emergencia': Icons.shield_outlined,
  'casa': Icons.home_outlined,
  'estudio': Icons.school_outlined,
  'otro': Icons.card_giftcard_outlined,
};

const _iconLabels = <String, String>{
  'viaje': 'Viaje',
  'emergencia': 'Emergencia',
  'casa': 'Casa',
  'estudio': 'Estudio',
  'otro': 'Otro',
};

class EditSavingsGoalScreen extends ConsumerStatefulWidget {
  const EditSavingsGoalScreen({this.goal, super.key});

  final SavingsGoal? goal;

  @override
  ConsumerState<EditSavingsGoalScreen> createState() =>
      _EditSavingsGoalScreenState();
}

class _EditSavingsGoalScreenState extends ConsumerState<EditSavingsGoalScreen> {
  late final _nameController = TextEditingController(text: widget.goal?.name ?? '');
  late final _targetController = TextEditingController(
    text: widget.goal != null ? widget.goal!.targetAmount.toString() : '',
  );
  late final _monthlyController = TextEditingController(
    text: widget.goal != null ? widget.goal!.monthlyContribution.toString() : '',
  );
  late final _rateController = TextEditingController(
    text: widget.goal != null && widget.goal!.interestRate > 0
        ? _formatRate(widget.goal!.interestRate)
        : '',
  );
  late final _seedController = TextEditingController();
  late String _iconSlug = widget.goal?.iconSlug ?? 'viaje';
  late DateTime? _targetDate = widget.goal?.targetDate;

  static String _formatRate(double rate) =>
      rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime(now.year, now.month + 6),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final isEditing = widget.goal != null;
    final contributions = [...widget.goal?.contributions ?? const []];
    if (!isEditing) {
      final seed = int.tryParse(_seedController.text) ?? 0;
      if (seed > 0) {
        final user = ref.read(authStateChangesProvider).value;
        contributions.add(
          Contribution(date: DateTime.now(), amount: seed, createdBy: user?.uid ?? ''),
        );
      }
    }
    final goal = SavingsGoal(
      id: widget.goal?.id ?? '',
      name: name,
      iconSlug: _iconSlug,
      targetAmount: int.tryParse(_targetController.text) ?? 0,
      targetDate: _targetDate,
      monthlyContribution: int.tryParse(_monthlyController.text) ?? 0,
      interestRate: double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0,
      contributions: contributions,
    );
    await ref.read(savingsGoalControllerProvider.notifier).save(goal);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final goal = widget.goal;
    if (goal == null) return;
    await ref.read(savingsGoalControllerProvider.notifier).delete(goal.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? 'Editar meta' : 'Nueva meta',
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ícono', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final slug in _iconOptions.keys)
                  Finan2Chip(
                    icon: _iconOptions[slug],
                    label: _iconLabels[slug],
                    selected: _iconSlug == slug,
                    onTap: () => setState(() => _iconSlug = slug),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(label: 'Nombre', controller: _nameController),
            const SizedBox(height: Finan2Space.lg),
            Text(
              'Meta',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Finan2AmountInput(
              controller: _targetController,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: Finan2Space.lg),
            Row(
              children: [
                Expanded(
                  child: Finan2Field(
                    label: 'Aporte mensual',
                    controller: _monthlyController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Finan2TapField(
                    label: 'Fecha meta',
                    value: _targetDate == null
                        ? 'Sin fecha'
                        : DateFormat('MMM yyyy', 'es').format(_targetDate!),
                    onTap: _pickTargetDate,
                  ),
                ),
              ],
            ),
            if (_targetDate != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _targetDate = null),
                  child: const Text('Quitar fecha'),
                ),
              ),
            const SizedBox(height: Finan2Space.md),
            Row(
              children: [
                if (!isEditing)
                  Expanded(
                    child: Finan2Field(
                      label: 'Ya tengo ahorrado',
                      controller: _seedController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                if (!isEditing) const SizedBox(width: 9),
                Expanded(
                  child: Finan2Field(
                    label: 'Interés E.A. (opcional)',
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xxl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: const Text('Eliminar meta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
