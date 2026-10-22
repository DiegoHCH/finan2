import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_section_label.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../categories/presentation/new_category_chip.dart';
import '../../domain/entities/recurring_bill.dart';
import '../../domain/recurring_schedule.dart';
import '../recurring_schedule_label.dart';
import '../viewmodels/recurring_bill_providers.dart';

enum _Segment { ingreso, factura }

extension on _Segment {
  String label(AppLocalizations l10n) =>
      this == _Segment.ingreso ? l10n.recurringBillsTypeIncome : l10n.recurringBillsTypeBill;
  CategoryType get categoryType =>
      this == _Segment.ingreso ? CategoryType.ingreso : CategoryType.factura;
}

_Segment _segmentFor(CategoryType type) =>
    type == CategoryType.ingreso ? _Segment.ingreso : _Segment.factura;

class EditRecurringBillScreen extends ConsumerStatefulWidget {
  const EditRecurringBillScreen({this.bill, super.key});

  final RecurringBill? bill;

  @override
  ConsumerState<EditRecurringBillScreen> createState() => _EditRecurringBillScreenState();
}

class _EditRecurringBillScreenState extends ConsumerState<EditRecurringBillScreen> {
  late final _nameController = TextEditingController(text: widget.bill?.name ?? '');
  late final _amountController = TextEditingController(
    text: widget.bill != null ? widget.bill!.amount.toString() : '',
  );
  late var _frequency = widget.bill?.frequency ?? RecurringFrequency.monthly;
  late var _startDate = widget.bill == null ? _today() : scheduleAnchor(widget.bill!, _today());
  late DateTime? _endDate = widget.bill?.endDate;
  late var _paused = widget.bill?.paused ?? false;
  late _Segment _segment = _segmentFor(widget.bill?.type ?? CategoryType.factura);
  late String? _categoryId = widget.bill?.categoryId;
  late String? _accountId = widget.bill?.accountId;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAccount(List<Account> accounts) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final account in accounts)
              ListTile(
                leading: Icon(Finan2Icons.cuenta(account.type.name)),
                title: Text(account.name),
                onTap: () => Navigator.of(context).pop(account.id),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _accountId = selected);
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<DateTime?> _pickDay(DateTime initial, {DateTime? first}) {
    final firstDate = first ?? DateTime(initial.year - 3);
    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime(_today().year + 10),
    );
  }

  Future<void> _pickStart() async {
    final picked = await _pickDay(_startDate);
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await _pickDay(_endDate ?? _startDate, first: _startDate);
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    final name = toTitleCase(_nameController.text);
    final amount = Finan2AmountInput.parse(_amountController.text) ?? 0;
    final categoryId = _categoryId;
    final accountId = _accountId;
    if (name.isEmpty || amount <= 0 || categoryId == null || accountId == null) {
      await showFinan2ErrorSheet(context, message: context.l10n.recurringBillsMissingFields);
      return;
    }
    if (_frequency == RecurringFrequency.semimonthly && _startDate.day > 15) {
      await showFinan2InfoSheet(
        context,
        title: context.l10n.recurringBillsSemimonthlyDayTitle,
        message: context.l10n.recurringBillsSemimonthlyDayMessage,
      );
      return;
    }
    await ref
        .read(recurringBillControllerProvider.notifier)
        .save(
          RecurringBill(
            id: widget.bill?.id ?? '',
            name: name,
            type: _segment.categoryType,
            categoryId: categoryId,
            accountId: accountId,
            amount: amount,
            dayOfMonth: _startDate.day,
            frequency: _frequency,
            startDate: _startDate,
            endDate: _endDate,
            paused: _paused,
            resumedOn: (widget.bill?.paused ?? false) && !_paused
                ? _today()
                : widget.bill?.resumedOn,
            createdBy:
                widget.bill?.createdBy ?? ref.read(authStateChangesProvider).value?.uid ?? '',
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final bill = widget.bill;
    if (bill == null) return;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: context.l10n.recurringBillsDelete,
      message: context.l10n.recurringBillsDeleteMessage(bill.name),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(recurringBillControllerProvider.notifier).delete(bill.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isEditing = widget.bill != null;
    final l10n = context.l10n;

    final categoriesOfSegment = categories.where((c) => c.type == _segment.categoryType).toList();
    if (_categoryId != null && !categoriesOfSegment.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
    _categoryId ??= categoriesOfSegment.isNotEmpty ? categoriesOfSegment.first.id : null;

    Account? selectedAccount;
    for (final a in accounts) {
      if (a.id == _accountId) selectedAccount = a;
    }
    if (_accountId == null && accounts.isNotEmpty) {
      _accountId = accounts.first.id;
      selectedAccount = accounts.first;
    }

    final formatMoney = ref.watch(moneyFormatterProvider);
    String dateLabel(DateTime date) =>
        DateFormat.yMMMd(l10n.localeName).format(date).replaceAll('.', '');

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.recurringBillsEditTitle : l10n.recurringBillsNewTitle,
        onSave: _save,
        closeIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Finan2Space.lg,
          Finan2Space.sm,
          Finan2Space.lg,
          Finan2Space.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2SegmentedControl<_Segment>(
              options: {for (final s in _Segment.values) s: s.label(l10n)},
              selected: _segment,
              onChanged: (s) => setState(() {
                _segment = s;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2Field(label: l10n.commonName, controller: _nameController),
            Finan2AmountInput(controller: _amountController, currencySymbol: currencySymbol),
            const SizedBox(height: Finan2Space.md),
            Finan2SectionLabel(l10n.commonCategory),
            if (categoriesOfSegment.isEmpty) ...[
              Text(
                l10n.recurringBillsNoCategories,
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              ),
              const SizedBox(height: Finan2Space.xs),
            ],
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final category in categoriesOfSegment)
                  Finan2Chip(
                    icon: Finan2Icons.categoria(category.iconSlug),
                    label: category.name,
                    tone: Finan2Tone.of(context, Color(category.color)),
                    selected: _categoryId == category.id,
                    onTap: () => setState(() => _categoryId = category.id),
                  ),
                NewCategoryChip(
                  type: _segment.categoryType,
                  onCreated: (id) => setState(() => _categoryId = id),
                ),
              ],
            ),
            const SizedBox(height: Finan2Space.md),
            if (accounts.isEmpty)
              Text(
                l10n.recurringBillsNoAccounts,
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              )
            else
              Finan2TapField(
                label: l10n.commonAccount,
                value: selectedAccount?.name ?? l10n.recurringBillsSelectAccount,
                leading: Icon(
                  Finan2Icons.cuenta(selectedAccount?.type.name ?? 'banco'),
                  size: 18,
                  color: colors.inkSoft,
                ),
                onTap: () => _pickAccount(accounts),
              ),
            const SizedBox(height: Finan2Space.lg),
            Finan2SectionLabel(l10n.recurringBillsRepeats),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final f in RecurringFrequency.values)
                  Finan2Chip(
                    label: frequencyLabel(f, l10n: l10n),
                    selected: _frequency == f,
                    onTap: () => setState(() => _frequency = f),
                  ),
              ],
            ),
            if (frequencyHint(_frequency, l10n: l10n) case final hint?) ...[
              const SizedBox(height: Finan2Space.xs),
              Text(
                hint,
                key: const Key('recurringBillFrequencyHint'),
                style: TextStyle(fontSize: 12.5, height: 1.4, color: colors.inkSoft),
              ),
            ],
            const SizedBox(height: Finan2Space.md),
            // Read aloud, to check it was understood: «Cada lunes», and
            // what that comes to in a month.
            // The monthly cost follows the amount as it's typed.
            ListenableBuilder(
              listenable: _amountController,
              builder: (context, _) {
                final amount = Finan2AmountInput.parse(_amountController.text) ?? 0;
                return Finan2Notice(
                  key: const Key('recurringBillReadAloud'),
                  icon: Icons.autorenew,
                  kind: Finan2NoticeKind.calm,
                  title: describeSchedule(
                    scheduleOf(_frequency, _startDate),
                    l10n: l10n,
                    withUntil: false,
                  ),
                  message: amount > 0
                      ? describeMonthlyCost(
                          amount,
                          _frequency,
                          formatMoney,
                          l10n: l10n,
                          withReason: true,
                        )
                      : null,
                );
              },
            ),
            const SizedBox(height: Finan2Space.md),
            Row(
              children: [
                Expanded(
                  child: Finan2TapField(
                    label: l10n.recurringBillsFrom,
                    value: dateLabel(_startDate),
                    onTap: _pickStart,
                  ),
                ),
                const SizedBox(width: Finan2Space.sm),
                Expanded(
                  child: Finan2TapField(
                    label: l10n.recurringBillsUntil,
                    value: _endDate == null ? l10n.recurringBillsNoEndDate : dateLabel(_endDate!),
                    onTap: _pickEnd,
                  ),
                ),
              ],
            ),
            if (_endDate != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _endDate = null),
                  style: TextButton.styleFrom(foregroundColor: colors.inkSoft),
                  child: Text(l10n.recurringBillsRemoveEndDate),
                ),
              ),
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.md),
              Finan2Sheet(
                children: [
                  Finan2SetRow(
                    icon: Icons.pause_rounded,
                    label: l10n.recurringBillsPaused,
                    detail: l10n.recurringBillsPausedHint,
                    trailing: Switch(
                      value: _paused,
                      onChanged: (value) => setState(() => _paused = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Finan2Space.xl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: Text(l10n.recurringBillsDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
