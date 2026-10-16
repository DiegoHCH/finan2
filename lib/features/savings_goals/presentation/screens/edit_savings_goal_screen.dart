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
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_goal_model.dart';
import '../../domain/goal_plan.dart';
import '../goal_style.dart';
import '../viewmodels/savings_goal_providers.dart';

/// Display name for each icon slug (the slug itself is what's stored).
String _iconLabel(AppLocalizations l10n, String slug) => switch (slug) {
  'viaje' => l10n.savingsGoalsIconTrip,
  'emergencia' => l10n.savingsGoalsIconEmergency,
  'casa' => l10n.savingsGoalsIconHome,
  'estudio' => l10n.savingsGoalsIconStudy,
  _ => l10n.savingsGoalsIconOther,
};

class EditSavingsGoalScreen extends ConsumerStatefulWidget {
  const EditSavingsGoalScreen({this.goal, super.key});

  final SavingsGoal? goal;

  @override
  ConsumerState<EditSavingsGoalScreen> createState() => _EditSavingsGoalScreenState();
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
    final name = toTitleCase(_nameController.text);
    if (name.isEmpty) return;
    final isEditing = widget.goal != null;
    final contributions = <Contribution>[...widget.goal?.contributions ?? const <Contribution>[]];
    if (!isEditing) {
      final seed = Finan2AmountInput.parse(_seedController.text) ?? 0;
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
      targetAmount: Finan2AmountInput.parse(_targetController.text) ?? 0,
      targetDate: _targetDate,
      monthlyContribution: Finan2AmountInput.parse(_monthlyController.text) ?? _needed() ?? 0,
      interestRate: double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0,
      contributions: contributions,
      createdBy: widget.goal?.createdBy ?? ref.read(authStateChangesProvider).value?.uid ?? '',
    );
    await ref.read(savingsGoalControllerProvider.notifier).save(goal);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final goal = widget.goal;
    if (goal == null) return;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: context.l10n.savingsGoalsDelete,
      message: context.l10n.savingsGoalsDeleteMessage(goal.name),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(savingsGoalControllerProvider.notifier).delete(goal.id);
    if (mounted) Navigator.of(context).pop();
  }

  /// What has to go in each month to make it by the date - shown before
  /// the goal is created, and saved as its monthly contribution when that
  /// field is left empty.
  int? _needed() => monthlyNeeded(
    target: Finan2AmountInput.parse(_targetController.text) ?? 0,
    saved:
        widget.goal?.currentAmountAsOf(DateTime.now()) ??
        (Finan2AmountInput.parse(_seedController.text) ?? 0),
    targetDate: _targetDate,
    now: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final formatMoney = ref.watch(moneyFormatterProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    const gap = SizedBox(height: Finan2Space.md);

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.savingsGoalsEditTitle : l10n.savingsGoalsNewTitle,
        closeIcon: true,
        saveLabel: isEditing ? null : l10n.goalCreate,
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
            Finan2Field(label: l10n.commonName, controller: _nameController),
            const SizedBox(height: Finan2Space.lg),
            Finan2AmountInput(
              controller: _targetController,
              currencySymbol: currencySymbol,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 44),
            ),
            const SizedBox(height: Finan2Space.xxs),
            Text(
              l10n.savingsGoalsTarget,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: colors.inkFaint),
            ),
            const SizedBox(height: Finan2Space.lg),
            Row(
              children: [
                Expanded(
                  child: Finan2TapField(
                    label: l10n.savingsGoalsTargetDate,
                    value: _targetDate == null
                        ? l10n.savingsGoalsNoDateValue
                        : _capitalized(DateFormat('MMMM y').format(_targetDate!)),
                    onTap: _pickTargetDate,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: isEditing
                      ? Finan2Field(
                          label: l10n.savingsGoalsMonthlyContribution,
                          controller: _monthlyController,
                          keyboardType: TextInputType.number,
                        )
                      : Finan2Field(
                          label: l10n.savingsGoalsAlreadySaved,
                          controller: _seedController,
                          keyboardType: TextInputType.number,
                        ),
                ),
              ],
            ),
            if (_targetDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _targetDate = null),
                  child: Text(l10n.savingsGoalsClearDate),
                ),
              )
            else
              gap,
            Text(l10n.savingsGoalsIconField, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final slug in goalIcons.keys)
                  Finan2Chip(
                    icon: goalIcons[slug],
                    label: _iconLabel(l10n, slug),
                    selected: _iconSlug == slug,
                    onTap: () => setState(() => _iconSlug = slug),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Row(
              children: [
                if (!isEditing) ...[
                  Expanded(
                    child: Finan2Field(
                      label: l10n.savingsGoalsMonthlyContribution,
                      controller: _monthlyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 9),
                ],
                Expanded(
                  child: Finan2Field(
                    label: l10n.savingsGoalsInterestOptional,
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            ListenableBuilder(
              listenable: Listenable.merge([_targetController, _seedController]),
              builder: (context, _) {
                final needed = _needed();
                final date = _targetDate;
                if (needed == null || needed <= 0 || date == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: Finan2Space.lg),
                  child: Finan2Notice(
                    kind: Finan2NoticeKind.calm,
                    icon: Icons.event_outlined,
                    title: l10n.goalNeededTitle(formatMoney(needed)),
                    message: l10n.goalNeededMessage(
                      goalDateLabel(date, DateTime.now(), long: true),
                    ),
                  ),
                );
              },
            ),
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xxl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: Text(l10n.savingsGoalsDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _capitalized(String text) =>
    text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
