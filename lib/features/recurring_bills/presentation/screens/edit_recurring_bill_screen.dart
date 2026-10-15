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
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/recurring_bill_model.dart';
import '../recurring_schedule_label.dart';
import '../viewmodels/recurring_bill_providers.dart';

enum _Segment { ingreso, factura }

extension on _Segment {
  String get label => this == _Segment.ingreso ? 'Ingreso' : 'Factura';
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
  late var _startDate = widget.bill == null ? _today() : scheduleAnchor(widget.bill!);
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
    final amount = int.tryParse(_amountController.text) ?? 0;
    final categoryId = _categoryId;
    final accountId = _accountId;
    if (name.isEmpty || amount <= 0 || categoryId == null || accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el nombre, monto, categoría y cuenta.')),
      );
      return;
    }
    if (_frequency == RecurringFrequency.semimonthly && _startDate.day > 15) {
      await showFinan2InfoSheet(
        context,
        title: 'Elige un día hasta el 15',
        message:
            'Una quincenal se repite 15 días después de la primera fecha. '
            'Elige el primer pago entre el 1 y el 15 del mes - por ejemplo el 15 '
            'para cobrar el 15 y el 30.',
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
      title: 'Eliminar factura recurrente',
      message:
          'Se eliminará "${bill.name}" y dejará de generarse. Los movimientos que ya creó se quedan. Esta acción no se puede deshacer. Si solo quieres detenerla un tiempo, ponla en pausa.',
      confirmLabel: 'Eliminar',
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

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? 'Editar factura recurrente' : 'Nueva factura recurrente',
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2SegmentedControl<_Segment>(
              options: {for (final s in _Segment.values) s: s.label},
              selected: _segment,
              onChanged: (s) => setState(() {
                _segment = s;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(label: 'Nombre', controller: _nameController),
            const SizedBox(height: Finan2Space.lg),
            Text(
              'Monto',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Finan2AmountInput(controller: _amountController, currencySymbol: currencySymbol),
            const SizedBox(height: Finan2Space.lg),
            Text('Categoría', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            if (categoriesOfSegment.isEmpty)
              Text(
                'No hay categorías de este tipo todavía. Créalas en Ajustes.',
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              )
            else
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final category in categoriesOfSegment)
                    Finan2Chip(
                      icon: Finan2Icons.categoria(category.iconSlug),
                      label: category.name,
                      selected: _categoryId == category.id,
                      onTap: () => setState(() => _categoryId = category.id),
                    ),
                ],
              ),
            const SizedBox(height: Finan2Space.lg),
            if (accounts.isEmpty)
              Text(
                'No hay cuentas todavía. Créalas en Ajustes.',
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              )
            else
              Finan2TapField(
                label: 'Cuenta',
                value: selectedAccount?.name ?? 'Selecciona una cuenta',
                leading: Icon(
                  Finan2Icons.cuenta(selectedAccount?.type.name ?? 'banco'),
                  size: 18,
                  color: colors.inkSoft,
                ),
                onTap: () => _pickAccount(accounts),
              ),
            const SizedBox(height: Finan2Space.md),
            const SizedBox(height: Finan2Space.sm),
            Text('Se repite', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final f in RecurringFrequency.values)
                  Finan2Chip(
                    label: f.label,
                    selected: _frequency == f,
                    onTap: () => setState(() => _frequency = f),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2TapField(
              label: isEditing ? 'Desde' : 'Primera vez',
              value: DateFormat('dd MMM yyyy', 'es').format(_startDate),
              onTap: _pickStart,
            ),
            const SizedBox(height: Finan2Space.xs),
            Text(
              'Se registra ${describeSchedule(frequency: _frequency, start: _startDate)}.',
              style: TextStyle(fontSize: 12, color: colors.inkSoft),
            ),
            const SizedBox(height: Finan2Space.md),
            Row(
              children: [
                Expanded(
                  child: Finan2TapField(
                    label: 'Hasta',
                    value: _endDate == null
                        ? 'Sin fecha de fin'
                        : DateFormat('dd MMM yyyy', 'es').format(_endDate!),
                    onTap: _pickEnd,
                  ),
                ),
                if (_endDate != null)
                  IconButton(
                    tooltip: 'Quitar fecha de fin',
                    onPressed: () => setState(() => _endDate = null),
                    icon: Icon(Icons.close, color: colors.inkSoft),
                  ),
              ],
            ),
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('En pausa'),
                subtitle: const Text(
                  'No se registra mientras esté en pausa. Al reanudarla, las '
                  'fechas que pasaron no se registran.',
                ),
                value: _paused,
                onChanged: (value) => setState(() => _paused = value),
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xxl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: const Text('Eliminar factura recurrente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
