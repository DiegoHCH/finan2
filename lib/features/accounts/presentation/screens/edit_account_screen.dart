import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/account_model.dart';
import '../viewmodels/account_providers.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({this.account, super.key});

  final Account? account;

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  late final _nameController = TextEditingController(text: widget.account?.name ?? '');
  late final _balanceController = TextEditingController(
    text: widget.account != null ? widget.account!.balance.toString() : '',
  );
  late AccountType _type = widget.account?.type ?? AccountType.banco;
  late bool _includeInAvailable = widget.account?.includeInAvailable ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = toTitleCase(_nameController.text);
    if (name.isEmpty) return;
    final balance = Finan2AmountInput.parse(_balanceController.text) ?? 0;
    await ref
        .read(accountControllerProvider.notifier)
        .save(
          Account(
            id: widget.account?.id ?? '',
            name: name,
            type: _type,
            balance: balance,
            includeInAvailable: _includeInAvailable,
            createdBy:
                widget.account?.createdBy ?? ref.read(authStateChangesProvider).value?.uid ?? '',
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final account = widget.account;
    if (account == null) return;
    final controller = ref.read(accountControllerProvider.notifier);
    final usage = await controller.usage(account.id);
    if (!mounted) return;
    final l10n = context.l10n;
    // Moving those records to another account would change both balances
    // after the fact, so the account simply stays until they're gone.
    if (usage > 0) {
      await showFinan2InfoSheet(
        context,
        title: l10n.accountsCannotDeleteTitle,
        message: l10n.accountsCannotDeleteMessage(account.name, usage),
      );
      return;
    }
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: l10n.accountsDeleteTitle,
      message: l10n.accountsDeleteMessage(account.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await controller.delete(account.id);
    if (!mounted) return;
    final result = ref.read(accountControllerProvider);
    if (result.hasError) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error!));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    final currencySymbol = currencySymbolFor(ref.watch(currentCurrencyProvider));
    final l10n = context.l10n;

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.accountsEditTitle : l10n.accountsNewTitle,
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.accountsTypeLabel, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final type in AccountType.values)
                  Finan2Chip(
                    icon: Finan2Icons.cuenta(type.name),
                    label: type.label,
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(label: l10n.commonName, controller: _nameController),
            const SizedBox(height: Finan2Space.lg),
            Text(
              l10n.accountsCurrentBalance,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Finan2AmountInput(controller: _balanceController, currencySymbol: currencySymbol),
            const SizedBox(height: Finan2Space.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.accountsIncludeInAvailable),
              value: _includeInAvailable,
              onChanged: (value) => setState(() => _includeInAvailable = value),
            ),
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.lg),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).extension<Finan2Colors>()!.expense,
                ),
                child: Text(l10n.accountsDeleteTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
