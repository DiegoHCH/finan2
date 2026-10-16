import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_section_label.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/domain/entities/debt.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../../transfers/data/transfer_model.dart';
import '../../../transfers/presentation/viewmodels/transfer_providers.dart';
import '../../domain/tags.dart';
import '../../domain/entities/movement.dart';
import '../viewmodels/transaction_providers.dart';

/// What Anotar records: a movement of one of three kinds, or «Pasar» -
/// money moved between two of the household's own accounts (R4).
enum _Kind { ingreso, gasto, ahorro, pasar }

extension on _Kind {
  String label(AppLocalizations l10n) => switch (this) {
    _Kind.ingreso => l10n.categoriesTypeIncome,
    _Kind.gasto => l10n.categoriesTypeExpense,
    _Kind.ahorro => l10n.categoriesTypeSavings,
    _Kind.pasar => l10n.transactionsTypeTransfer,
  };

  bool matches(CategoryType type) => switch (this) {
    _Kind.ingreso => type == CategoryType.ingreso,
    _Kind.gasto => type == CategoryType.gasto || type == CategoryType.factura,
    _Kind.ahorro => type == CategoryType.ahorro,
    _Kind.pasar => false,
  };
}

_Kind _kindFor(CategoryType type) => switch (type) {
  CategoryType.ingreso => _Kind.ingreso,
  CategoryType.factura || CategoryType.gasto => _Kind.gasto,
  CategoryType.ahorro => _Kind.ahorro,
};

/// «Anotar»: one thumb, top to bottom - the amount, the category, who paid.
/// Date and account sit under the amount already filled in.
class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({
    this.transaction,
    this.initialDate,
    this.startWithTransfer = false,
    super.key,
  });

  /// The movement being edited; null to record a new one.
  final Movement? transaction;

  /// Date for a new movement - the month being browsed in Movimientos.
  final DateTime? initialDate;

  /// Opens on «Pasar», for the entry points that used to open a separate
  /// transfer screen.
  final bool startWithTransfer;

  @override
  ConsumerState<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  late final _amountController = TextEditingController(
    text: widget.transaction != null ? widget.transaction!.amount.toString() : '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.transaction?.description ?? '',
  );
  final _tagController = TextEditingController();
  late final _tags = [...?widget.transaction?.tags];
  late _Kind _kind = widget.transaction != null
      ? _kindFor(widget.transaction!.type)
      : (widget.startWithTransfer ? _Kind.pasar : _Kind.gasto);
  late String? _categoryId = widget.transaction?.categoryId;
  late String? _accountId = (widget.transaction != null && widget.transaction!.accountId.isNotEmpty)
      ? widget.transaction!.accountId
      : null;
  late String? _cardDebtId = (widget.transaction?.cardDebtId.isNotEmpty ?? false)
      ? widget.transaction!.cardDebtId
      : null;
  late DateTime _date = widget.transaction?.date ?? widget.initialDate ?? DateTime.now();

  /// null until the user picks - then whoever is logging it.
  late String? _paidBy = widget.transaction?.payer;

  /// «Pasar»: from one account to another.
  String? _fromAccountId;
  String? _toAccountId;

  @override
  void initState() {
    super.initState();
    // The amount drives the resulting balances shown under «Pasar».
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_kind == _Kind.pasar) setState(() {});
  }

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
        title: context.l10n.transactionsMaxTagsTitle(maxTagsPerMovement),
        message: context.l10n.transactionsMaxTagsMessage,
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
                  subtitle: Text(context.l10n.transactionsCreditCard),
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

  Future<void> _pickTransferAccount({
    required List<Account> accounts,
    required String? exclude,
    required ValueChanged<String> onPicked,
  }) async {
    final options = accounts.where((a) => a.id != exclude).toList();
    final formatMoney = ref.read(moneyFormatterProvider);
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final account in options)
              ListTile(
                leading: Icon(Finan2Icons.cuenta(account.type.name)),
                title: Text(account.name),
                subtitle: Text(formatMoney(account.balance)),
                onTap: () => Navigator.of(context).pop(account.id),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => onPicked(selected));
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

  Future<void> _save() => _kind == _Kind.pasar ? _saveTransfer() : _saveMovement();

  Future<void> _saveMovement() async {
    final l10n = context.l10n;
    final amount = int.tryParse(_amountController.text) ?? 0;
    final user = ref.read(authStateChangesProvider).value;
    final categories = ref.read(categoriesProvider).value ?? const [];
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    final hasSource = _accountId != null || _cardDebtId != null;
    if (amount <= 0 || category == null || !hasSource || user == null) {
      await showFinan2ErrorSheet(
        context,
        title: l10n.transactionsIncompleteTitle,
        message: l10n.transactionsIncomplete,
      );
      return;
    }
    // A tag typed but not added yet still counts.
    final pending = normalizeTag(_tagController.text);
    final tags = {..._tags, if (pending.isNotEmpty) pending}.take(maxTagsPerMovement).toList();
    final controller = ref.read(transactionControllerProvider.notifier);
    await controller.save(
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
    await _finish(ref.read(transactionControllerProvider));
  }

  Future<void> _saveTransfer() async {
    final l10n = context.l10n;
    final amount = int.tryParse(_amountController.text) ?? 0;
    final from = _fromAccountId;
    final to = _toAccountId;
    final user = ref.read(authStateChangesProvider).value;
    if (amount <= 0 || from == null || to == null || from == to || user == null) {
      await showFinan2ErrorSheet(
        context,
        title: l10n.transactionsIncompleteTitle,
        message: l10n.transfersInvalid,
      );
      return;
    }
    await ref
        .read(transferControllerProvider.notifier)
        .createTransfer(
          Transfer(
            id: '',
            amount: amount,
            fromAccountId: from,
            toAccountId: to,
            date: _date,
            createdBy: user.uid,
          ),
        );
    await _finish(ref.read(transferControllerProvider));
  }

  /// Closes Anotar, or says why it couldn't save.
  Future<void> _finish(AsyncValue<void> result) async {
    if (!mounted) return;
    if (result.hasError) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final cards = (ref.watch(debtsProvider).value ?? const []).where((d) => d.type.isCard).toList();
    final household = ref.watch(currentHouseholdProvider).value;
    final user = ref.watch(authStateChangesProvider).value;
    final memberLabel = ref.watch(memberLabelProvider);
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isEditing = widget.transaction != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final l10n = context.l10n;

    final categoriesOfKind = categories.where((c) => _kind.matches(c.type)).toList();
    if (_categoryId != null && !categoriesOfKind.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
    _categoryId ??= categoriesOfKind.isNotEmpty ? categoriesOfKind.first.id : null;

    if (_accountId == null && _cardDebtId == null && accounts.isNotEmpty) {
      _accountId = accounts.first.id;
    }
    if (_kind == _Kind.pasar && accounts.isNotEmpty) {
      _fromAccountId ??= accounts.first.id;
      _toAccountId ??= accounts.where((a) => a.id != _fromAccountId).firstOrNull?.id;
    }
    final selectedAccount = accounts.where((a) => a.id == _accountId).firstOrNull;
    final selectedCard = cards.where((c) => c.id == _cardDebtId).firstOrNull;

    final members = household?.members ?? const <String>[];
    final payer = _paidBy ?? user?.uid;
    final suggestedTags = tagsByUse(
      ref.watch(transactionsForYearProvider(_date.year)).value ?? const [],
    ).where((t) => !_tags.contains(t)).take(6).toList();

    final now = DateTime.now();
    final isToday = _date.year == now.year && _date.month == now.month && _date.day == now.day;
    final dateLabel = isToday
        ? l10n.transactionsDateToday(DateFormat('EEEE d').format(_date))
        : DateFormat.MMMEd().format(_date);
    final sourceLabel = selectedCard?.name ?? selectedAccount?.name;
    final kinds = [
      for (final kind in _Kind.values)
        // A movement already saved can't turn into a transfer.
        if (!(isEditing && kind == _Kind.pasar)) kind,
    ];

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.transactionsEditTitle : l10n.transactionsNewTitle,
        onSave: _save,
        closeIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Finan2Space.lg,
          Finan2Space.xs,
          Finan2Space.lg,
          Finan2Space.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2SegmentedControl<_Kind>(
              options: {for (final k in kinds) k: k.label(l10n)},
              selected: _kind,
              onChanged: (k) => setState(() {
                _kind = k;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2AmountInput(controller: _amountController, currencySymbol: currencySymbol),
            const SizedBox(height: Finan2Space.xs),
            // Date and account: already filled in, rarely changed.
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _HintButton(label: dateLabel, onTap: _pickDate),
                if (_kind != _Kind.pasar) ...[
                  Text(' · ', style: TextStyle(fontSize: 12, color: colors.inkFaint)),
                  if (accounts.isEmpty && cards.isEmpty)
                    Text(
                      l10n.transactionsNoAccounts,
                      style: TextStyle(fontSize: 12, color: colors.inkSoft),
                    )
                  else
                    _HintButton(
                      key: const Key('anotarSource'),
                      label: sourceLabel ?? l10n.transactionsSelectAccount,
                      onTap: () => _pickSource(accounts, cards),
                    ),
                ],
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            if (_kind == _Kind.pasar)
              ..._transferFields(accounts)
            else ...[
              Finan2SectionLabel(l10n.commonCategory),
              if (categoriesOfKind.isEmpty)
                Text(
                  l10n.transactionsNoCategoriesOfType,
                  style: TextStyle(fontSize: 12, color: colors.inkSoft),
                )
              else
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final category in categoriesOfKind)
                      Finan2Chip(
                        icon: Finan2Icons.categoria(category.iconSlug),
                        label: category.name,
                        tone: Finan2Tone.of(context, Color(category.color)),
                        selected: _categoryId == category.id,
                        onTap: () => setState(() => _categoryId = category.id),
                      ),
                  ],
                ),
              const SizedBox(height: Finan2Space.md),
              Finan2Field(label: l10n.commonDescription, controller: _descriptionController),
              // Only worth asking once there's a partner to tell apart.
              if (members.length > 1) ...[
                const SizedBox(height: Finan2Space.md),
                Finan2SectionLabel(
                  _kind == _Kind.ingreso ? l10n.transactionsReceivedBy : l10n.transactionsPaidBy,
                ),
                Finan2SegmentedControl<String>(
                  options: {for (final uid in members) uid: memberLabel(uid).firstName},
                  dots: {
                    for (final uid in members)
                      uid: Finan2Tone.member(context, memberLabel(uid).index).color,
                  },
                  tones: {
                    for (final uid in members)
                      uid: Finan2Tone.member(context, memberLabel(uid).index),
                  },
                  selected: payer ?? members.first,
                  onChanged: (uid) => setState(() => _paidBy = uid),
                ),
              ],
              const SizedBox(height: Finan2Space.md),
              Finan2SectionLabel(l10n.transactionsTags),
              if (_tags.isNotEmpty || suggestedTags.isNotEmpty) ...[
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final tag in _tags)
                      Finan2Chip(
                        label: '#$tag',
                        selected: true,
                        removable: true,
                        onTap: () => setState(() => _tags.remove(tag)),
                      ),
                    for (final tag in suggestedTags)
                      Finan2Chip(label: '+ #$tag', selected: false, onTap: () => _addTag(tag)),
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
                  hintText: l10n.transactionsAddTagHint,
                  hintStyle: TextStyle(fontSize: 13, color: colors.inkFaint),
                  suffixIcon: IconButton(
                    tooltip: l10n.transactionsAddTag,
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_tagController.text),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// «Pasar»: from, to, and what each balance becomes.
  List<Widget> _transferFields(List<Account> accounts) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final amount = int.tryParse(_amountController.text) ?? 0;
    final from = accounts.where((a) => a.id == _fromAccountId).firstOrNull;
    final to = accounts.where((a) => a.id == _toAccountId).firstOrNull;

    String describe(Account? account, int delta) {
      if (account == null) return l10n.transfersSelectAccount;
      final now = formatMoney(account.balance);
      if (amount <= 0) return '${account.name} · $now';
      return '${account.name} · $now → ${formatMoney(account.balance + delta)}';
    }

    if (accounts.length < 2) {
      return [
        Text(
          l10n.transactionsTransferNeedsTwoAccounts,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: colors.inkSoft),
        ),
      ];
    }
    return [
      Finan2TapField(
        label: l10n.transfersFrom,
        value: describe(from, -amount),
        leading: Icon(
          Finan2Icons.cuenta(from?.type.name ?? 'banco'),
          size: 18,
          color: colors.inkSoft,
        ),
        onTap: () => _pickTransferAccount(
          accounts: accounts,
          exclude: _toAccountId,
          onPicked: (id) => _fromAccountId = id,
        ),
      ),
      const SizedBox(height: Finan2Space.xs),
      Center(child: Icon(Icons.arrow_downward, color: colors.inkFaint, size: 20)),
      const SizedBox(height: Finan2Space.xs),
      Finan2TapField(
        label: l10n.transfersTo,
        value: describe(to, amount),
        leading: Icon(
          Finan2Icons.cuenta(to?.type.name ?? 'banco'),
          size: 18,
          color: colors.inkSoft,
        ),
        onTap: () => _pickTransferAccount(
          accounts: accounts,
          exclude: _fromAccountId,
          onPicked: (id) => _toAccountId = id,
        ),
      ),
    ];
  }
}

/// A faint, tappable part of the line under the amount (`.amount .h`).
class _HintButton extends StatelessWidget {
  const _HintButton({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.inkSoft),
            ),
            Icon(Icons.expand_more, size: 15, color: colors.inkFaint),
          ],
        ),
      ),
    );
  }
}
