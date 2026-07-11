import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transaction_model.dart';
import '../viewmodels/transaction_providers.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({this.transaction, super.key});

  final Movement? transaction;

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
  late CategoryType _type = widget.transaction?.type ?? CategoryType.gasto;
  late String? _categoryId = widget.transaction?.categoryId;
  late String? _accountId = widget.transaction?.accountId;
  late DateTime _date = widget.transaction?.date ?? DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
                title: Text(account.name),
                onTap: () => Navigator.of(context).pop(account.id),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _accountId = selected);
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
    if (amount <= 0 || _categoryId == null || _accountId == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el monto, la categoría y la cuenta.'),
        ),
      );
      return;
    }
    await ref.read(transactionControllerProvider.notifier).save(
          Movement(
            id: widget.transaction?.id ?? '',
            amount: amount,
            type: _type,
            categoryId: _categoryId!,
            accountId: _accountId!,
            description: _descriptionController.text.trim(),
            date: _date,
            createdBy: widget.transaction?.createdBy ?? user.uid,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final tx = widget.transaction;
    if (tx == null) return;
    await ref.read(transactionControllerProvider.notifier).delete(tx.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final household = ref.watch(currentHouseholdProvider).value;
    final user = ref.watch(authStateChangesProvider).value;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isEditing = widget.transaction != null;

    final categoriesOfType =
        categories.where((c) => c.type == _type).toList();
    if (_categoryId != null &&
        !categoriesOfType.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
    _categoryId ??= categoriesOfType.isNotEmpty ? categoriesOfType.first.id : null;

    Account? selectedAccount;
    for (final a in accounts) {
      if (a.id == _accountId) selectedAccount = a;
    }
    if (_accountId == null && accounts.isNotEmpty) {
      _accountId = accounts.first.id;
      selectedAccount = accounts.first;
    }

    final creatorUid = widget.transaction?.createdBy ?? user?.uid;
    final creatorName = creatorUid == null
        ? ''
        : (household?.memberInfo[creatorUid]?.name ?? user?.displayName ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar movimiento' : 'Nuevo movimiento'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 7,
              runSpacing: 7,
              alignment: WrapAlignment.center,
              children: [
                for (final type in CategoryType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) => setState(() {
                      _type = type;
                      _categoryId = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.sm),
            Finan2AmountInput(controller: _amountController),
            const SizedBox(height: Finan2Space.lg),
            Text('Categoría', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            if (categoriesOfType.isEmpty)
              Text(
                'No hay categorías de este tipo todavía. Créalas en Ajustes.',
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              )
            else
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final category in categoriesOfType)
                    ChoiceChip(
                      avatar: Icon(
                        Finan2Icons.categoria(category.iconSlug),
                        size: 16,
                        color: _categoryId == category.id
                            ? Colors.white
                            : Color(category.color),
                      ),
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      onSelected: (_) =>
                          setState(() => _categoryId = category.id),
                    ),
                ],
              ),
            const SizedBox(height: Finan2Space.lg),
            Text('Cuenta', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            if (accounts.isEmpty)
              Text(
                'No hay cuentas todavía. Créalas en Ajustes.',
                style: TextStyle(fontSize: 12, color: colors.inkSoft),
              )
            else
              InkWell(
                onTap: () => _pickAccount(accounts),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.line),
                    borderRadius: BorderRadius.circular(Finan2Radius.field),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedAccount?.name ?? 'Selecciona una cuenta',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.inkFaint),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: Finan2Space.md),
            Finan2Field(
              label: 'Descripción',
              controller: _descriptionController,
            ),
            const SizedBox(height: Finan2Space.md),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.line),
                  borderRadius: BorderRadius.circular(Finan2Radius.field),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy', 'es').format(_date),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: colors.inkFaint),
                  ],
                ),
              ),
            ),
            if (creatorName.isNotEmpty) ...[
              const SizedBox(height: Finan2Space.md),
              Text(
                'Registrado por $creatorName',
                style: TextStyle(fontSize: 12, color: colors.inkFaint),
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
