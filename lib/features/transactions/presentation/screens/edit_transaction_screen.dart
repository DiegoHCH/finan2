import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/text_case.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/data/debt_model.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/tags.dart';
import '../../data/transaction_model.dart';
import '../viewmodels/transaction_providers.dart';

enum _Segment { ingreso, gasto, ahorro }

extension on _Segment {
  String get label => switch (this) {
        _Segment.ingreso => 'Ingreso',
        _Segment.gasto => 'Gasto',
        _Segment.ahorro => 'Ahorro',
      };

  bool matches(CategoryType type) => switch (this) {
        _Segment.ingreso => type == CategoryType.ingreso,
        _Segment.gasto =>
          type == CategoryType.gasto || type == CategoryType.factura,
        _Segment.ahorro => type == CategoryType.ahorro,
      };
}

_Segment _segmentFor(CategoryType type) => switch (type) {
      CategoryType.ingreso => _Segment.ingreso,
      CategoryType.factura || CategoryType.gasto => _Segment.gasto,
      CategoryType.ahorro => _Segment.ahorro,
    };

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({this.transaction, this.initialDate, super.key});

  /// Popping with this movement as the result means "delete it" - see
  /// TransactionsScreen._deleteWithUndo.
  final Movement? transaction;

  /// Date for a new movement - the month being browsed in Movimientos.
  final DateTime? initialDate;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  late final _amountController = TextEditingController(
    text: widget.transaction != null
        ? widget.transaction!.amount.toString()
        : '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.transaction?.description ?? '',
  );
  final _tagController = TextEditingController();
  late final _tags = [...?widget.transaction?.tags];
  late _Segment _segment =
      _segmentFor(widget.transaction?.type ?? CategoryType.gasto);
  late String? _categoryId = widget.transaction?.categoryId;
  late String? _accountId =
      (widget.transaction != null && widget.transaction!.accountId.isNotEmpty)
          ? widget.transaction!.accountId
          : null;
  late String? _cardDebtId =
      (widget.transaction?.cardDebtId.isNotEmpty ?? false) ? widget.transaction!.cardDebtId : null;
  late DateTime _date = widget.transaction?.date ?? widget.initialDate ?? DateTime.now();

  /// null until the user picks - then whoever is logging it.
  late String? _paidBy = widget.transaction?.payer;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String input) {
    final tag = normalizeTag(input);
    _tagController.clear();
    if (tag.isEmpty || _tags.contains(tag)) return;
    if (_tags.length >= maxTagsPerMovement) {
      showFinan2InfoSheet(
        context,
        title: 'Máximo $maxTagsPerMovement etiquetas',
        message: 'Quita una antes de añadir otra.',
      );
      return;
    }
    setState(() => _tags.add(tag));
  }

  Future<void> _pickSource(List<Account> accounts, List<Debt> cards) async {
    final selected = await showModalBottomSheet<(bool isCard, String id)>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final account in accounts)
              ListTile(
                leading: Icon(Finan2Icons.cuenta(account.type.name)),
                title: Text(account.name),
                onTap: () => Navigator.of(context).pop((false, account.id)),
              ),
            if (cards.isNotEmpty) ...[
              const Divider(height: 1),
              for (final card in cards)
                ListTile(
                  leading: const Icon(Icons.credit_card_outlined),
                  title: Text(card.name),
                  subtitle: const Text('Tarjeta de crédito'),
                  onTap: () => Navigator.of(context).pop((true, card.id)),
                ),
            ],
          ],
        ),
      ),
    );
    if (selected == null) return;
    final (isCard, id) = selected;
    setState(() {
      if (isCard) {
        _cardDebtId = id;
        _accountId = null;
      } else {
        _accountId = id;
        _cardDebtId = null;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 3),
      lastDate: DateTime(_date.year + 1),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    final user = ref.read(authStateChangesProvider).value;
    final categories = ref.read(categoriesProvider).value ?? const [];
    Category? category;
    for (final c in categories) {
      if (c.id == _categoryId) category = c;
    }
    final hasSource = _accountId != null || _cardDebtId != null;
    if (amount <= 0 || category == null || !hasSource || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el monto, la categoría y la cuenta.'),
        ),
      );
      return;
    }
    // A tag typed but not added yet still counts.
    final pending = normalizeTag(_tagController.text);
    final tags = {..._tags, if (pending.isNotEmpty) pending}.take(maxTagsPerMovement).toList();
    await ref.read(transactionControllerProvider.notifier).save(
          Movement(
            id: widget.transaction?.id ?? '',
            amount: amount,
            type: category.type,
            categoryId: category.id,
            accountId: _accountId ?? '',
            cardDebtId: _cardDebtId ?? '',
            description: toTitleCase(_descriptionController.text),
            date: _date,
            createdBy: widget.transaction?.createdBy ?? user.uid,
            paidBy: _paidBy ?? user.uid,
            tags: tags,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  /// Hands the movement back to Movimientos instead of deleting it here,
  /// so the list can offer "Deshacer" before anything is written.
  void _delete() {
    final tx = widget.transaction;
    if (tx == null) return;
    Navigator.of(context).pop(tx);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final cards =
        (ref.watch(debtsProvider).value ?? const []).where((d) => d.type.isCard).toList();
    final household = ref.watch(currentHouseholdProvider).value;
    final user = ref.watch(authStateChangesProvider).value;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isEditing = widget.transaction != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));

    final categoriesOfSegment =
        categories.where((c) => _segment.matches(c.type)).toList();
    if (_categoryId != null &&
        !categoriesOfSegment.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
    _categoryId ??=
        categoriesOfSegment.isNotEmpty ? categoriesOfSegment.first.id : null;

    Account? selectedAccount;
    for (final a in accounts) {
      if (a.id == _accountId) selectedAccount = a;
    }
    Debt? selectedCard;
    for (final c in cards) {
      if (c.id == _cardDebtId) selectedCard = c;
    }
    if (_accountId == null && _cardDebtId == null && accounts.isNotEmpty) {
      _accountId = accounts.first.id;
      selectedAccount = accounts.first;
    }

    final creatorUid = widget.transaction?.createdBy ?? user?.uid;
    final creatorName = creatorUid == null
        ? ''
        : (household?.memberInfo[creatorUid]?.name ?? user?.displayName ?? '');
    final creatorIndex =
        creatorUid == null ? 0 : (household?.members.indexOf(creatorUid) ?? 0);
    final members = household?.members ?? const <String>[];
    final payer = _paidBy ?? user?.uid;
    final suggestedTags = tagsByUse(ref.watch(transactionsForYearProvider(_date.year)).value ?? const [])
        .where((t) => !_tags.contains(t))
        .take(8)
        .toList();

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? 'Editar movimiento' : 'Nuevo movimiento',
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2SegmentedControl<_Segment>(
              options: {
                for (final s in _Segment.values) s: s.label,
              },
              selected: _segment,
              onChanged: (s) => setState(() {
                _segment = s;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: Finan2Space.sm),
            Finan2AmountInput(
              controller: _amountController,
              currencySymbol: currencySymbol,
            ),
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
            if (accounts.isEmpty && cards.isEmpty)
              Text(
                'No hay cuentas todavía. Créalas en Ajustes.',
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              )
            else
              Finan2TapField(
                label: 'Cuenta',
                value: selectedCard != null
                    ? selectedCard.name
                    : (selectedAccount?.name ?? 'Selecciona una cuenta'),
                leading: Icon(
                  selectedCard != null
                      ? Icons.credit_card_outlined
                      : Finan2Icons.cuenta(selectedAccount?.type.name ?? 'banco'),
                  size: 18,
                  color: colors.inkSoft,
                ),
                onTap: () => _pickSource(accounts, cards),
              ),
            const SizedBox(height: Finan2Space.md),
            Finan2Field(
              label: 'Descripción',
              controller: _descriptionController,
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2TapField(
              label: 'Fecha',
              value: DateFormat('dd MMM yyyy', 'es').format(_date),
              onTap: _pickDate,
            ),
            const SizedBox(height: Finan2Space.lg),
            Text('Etiquetas', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            if (_tags.isNotEmpty) ...[
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final tag in _tags)
                    Finan2Chip(
                      icon: Icons.close,
                      label: '#$tag',
                      selected: true,
                      onTap: () => setState(() => _tags.remove(tag)),
                    ),
                ],
              ),
              const SizedBox(height: Finan2Space.sm),
            ],
            TextField(
              controller: _tagController,
              onSubmitted: _addTag,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Añadir etiqueta, por ejemplo viaje-cartagena',
                hintStyle: TextStyle(fontSize: 13, color: colors.inkFaint),
                suffixIcon: IconButton(
                  tooltip: 'Añadir etiqueta',
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagController.text),
                ),
              ),
            ),
            if (suggestedTags.isNotEmpty) ...[
              const SizedBox(height: Finan2Space.sm),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final tag in suggestedTags)
                    Finan2Chip(
                      label: '#$tag',
                      selected: false,
                      onTap: () => _addTag(tag),
                    ),
                ],
              ),
            ],
            // Only worth asking once there's a partner to tell apart.
            if (members.length > 1) ...[
              const SizedBox(height: Finan2Space.lg),
              Text(
                _segment == _Segment.ingreso ? 'Lo recibió' : 'Pagó',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: Finan2Space.sm),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final uid in members)
                    Finan2Chip(
                      label: household?.memberInfo[uid]?.name ?? '?',
                      selected: payer == uid,
                      onTap: () => setState(() => _paidBy = uid),
                    ),
                ],
              ),
            ],
            if (isEditing && creatorName.isNotEmpty) ...[
              const SizedBox(height: Finan2Space.md),
              Finan2TapField(
                label: 'Registrado por',
                value: creatorName,
                leading: Finan2Avatar(
                  label: creatorName.substring(0, 1).toUpperCase(),
                  memberIndex: creatorIndex < 0 ? 0 : creatorIndex,
                  size: 22,
                  borderWidth: 0,
                ),
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xxl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: const Text('Eliminar movimiento'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
