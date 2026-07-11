import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/transfer_model.dart';
import '../viewmodels/transfer_providers.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _amountController = TextEditingController();
  String? _fromAccountId;
  String? _toAccountId;
  var _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAccount({
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
    if (selected != null) onPicked(selected);
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
    final from = _fromAccountId;
    final to = _toAccountId;
    final user = ref.read(authStateChangesProvider).value;
    if (amount <= 0 || from == null || to == null || from == to || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige un monto y dos cuentas distintas.'),
        ),
      );
      return;
    }
    await ref.read(transferControllerProvider.notifier).createTransfer(
          Transfer(
            id: '',
            amount: amount,
            fromAccountId: from,
            toAccountId: to,
            date: _date,
            createdBy: user.uid,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final formatMoney = ref.watch(moneyFormatterProvider);

    Account? findAccount(String? id) {
      for (final a in accounts) {
        if (a.id == id) return a;
      }
      return null;
    }

    final fromAccount = findAccount(_fromAccountId);
    final toAccount = findAccount(_toAccountId);

    return Scaffold(
      appBar: Finan2FormTop(title: 'Transferir', onSave: _save),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Monto a transferir',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Finan2AmountInput(
              controller: _amountController,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2TapField(
              label: 'Desde',
              value: fromAccount == null
                  ? 'Selecciona una cuenta'
                  : '${fromAccount.name} · ${formatMoney(fromAccount.balance)}',
              leading: fromAccount == null
                  ? null
                  : Icon(
                      Finan2Icons.cuenta(fromAccount.type.name),
                      size: 18,
                      color: colors.inkSoft,
                    ),
              onTap: () => _pickAccount(
                accounts: accounts,
                exclude: _toAccountId,
                onPicked: (id) => setState(() => _fromAccountId = id),
              ),
            ),
            const SizedBox(height: Finan2Space.sm),
            Center(
              child: Icon(Icons.arrow_downward, color: colors.inkFaint, size: 20),
            ),
            const SizedBox(height: Finan2Space.sm),
            Finan2TapField(
              label: 'Hacia',
              value: toAccount == null
                  ? 'Selecciona una cuenta'
                  : '${toAccount.name} · ${formatMoney(toAccount.balance)}',
              leading: toAccount == null
                  ? null
                  : Icon(
                      Finan2Icons.cuenta(toAccount.type.name),
                      size: 18,
                      color: colors.inkSoft,
                    ),
              onTap: () => _pickAccount(
                accounts: accounts,
                exclude: _fromAccountId,
                onPicked: (id) => setState(() => _toAccountId = id),
              ),
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2TapField(
              label: 'Fecha',
              value: DateFormat('dd MMM yyyy', 'es').format(_date),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
    );
  }
}
