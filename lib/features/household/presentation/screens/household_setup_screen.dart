import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_amount_input.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_option_card.dart';
import '../../../accounts/data/account_model.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../viewmodels/household_providers.dart';
import '../widgets/recovery_phrase_flow.dart';
import 'invite_household_screen.dart';

enum _Step { currency, account, recovery }

/// Right after creating a household: currency, a first account and the
/// recovery phrase - each skippable and all of them in Ajustes later - and
/// then the invite for the partner. Joining a household skips this: the
/// partner already set it up.
class HouseholdSetupScreen extends ConsumerStatefulWidget {
  const HouseholdSetupScreen({required this.shareCode, super.key});

  /// Handed on to [InviteHouseholdScreen] at the end.
  final String shareCode;

  @override
  ConsumerState<HouseholdSetupScreen> createState() =>
      _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends ConsumerState<HouseholdSetupScreen> {
  var _step = _Step.currency;
  var _busy = false;
  var _currency = defaultCurrency;
  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController();
  var _accountType = AccountType.banco;

  @override
  void dispose() {
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _guarded(Future<void> Function() action) async {
    setState(() => _busy = true);
    Object? failure;
    try {
      await action();
    } catch (error) {
      failure = error;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (failure != null) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(failure));
    }
  }

  Future<void> _next() async {
    final next = _step.index + 1;
    if (next < _Step.values.length) {
      setState(() => _step = _Step.values[next]);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InviteHouseholdScreen(shareCode: widget.shareCode),
      ),
    );
    if (!mounted) return;
    ref.read(householdSetupProvider.notifier).finish();
    // pop, unlike a back gesture, isn't held by the PopScope below.
    Navigator.of(context).pop();
  }

  Future<void> _saveCurrency() => _guarded(() async {
    final household = ref.read(currentHouseholdProvider).value;
    if (household != null && household.currency != _currency) {
      await ref
          .read(householdRepositoryProvider)
          .updateSettings(household.id, currency: _currency);
    }
    _next();
  });

  Future<void> _saveAccount() async {
    final name = toTitleCase(_accountNameController.text);
    if (name.isEmpty) {
      await showFinan2InfoSheet(
        context,
        title: 'Ponle un nombre',
        message:
            'Por ejemplo el banco o «Efectivo». Si prefieres, omite este paso.',
      );
      return;
    }
    await _guarded(() async {
      final controller = ref.read(accountControllerProvider.notifier);
      await controller.save(
        Account(
          id: '',
          name: name,
          type: _accountType,
          balance: int.tryParse(_balanceController.text) ?? 0,
          includeInAvailable: true,
          createdBy: ref.read(authStateChangesProvider).value?.uid ?? '',
        ),
      );
      final result = ref.read(accountControllerProvider);
      if (result.hasError) throw result.error!;
      await _next();
    });
  }

  Future<void> _createPhrase() async {
    final household = ref.read(currentHouseholdProvider).value;
    if (household == null) return;
    final saved = await createRecoveryPhrase(
      context,
      ref,
      household,
      askFirst: false,
    );
    if (saved && mounted) _next();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final textTheme = Theme.of(context).textTheme;
    final (title, description, body, primaryLabel, onPrimary) = switch (_step) {
      _Step.currency => (
        'Moneda del hogar',
        'En la que llevan las cuentas. Se puede cambiar en Ajustes.',
        Column(
          children: [
            Finan2OptionCard(
              icon: Icons.payments_outlined,
              title: 'Peso colombiano',
              subtitle: 'COP · \$',
              selected: _currency == 'COP',
              onTap: () => setState(() => _currency = 'COP'),
            ),
            const SizedBox(height: Finan2Space.sm),
            Finan2OptionCard(
              icon: Icons.attach_money,
              title: 'Dólar estadounidense',
              subtitle: 'USD · US\$',
              selected: _currency == 'USD',
              onTap: () => setState(() => _currency = 'USD'),
            ),
          ],
        ),
        'Siguiente',
        _saveCurrency,
      ),
      _Step.account => (
        'Tu primera cuenta',
        'De donde sale y a donde llega la plata: el banco, una billetera o el '
            'efectivo. Pon lo que tiene hoy para empezar con el saldo real.',
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Field(label: 'Nombre', controller: _accountNameController),
            const SizedBox(height: Finan2Space.md),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final type in AccountType.values)
                  Finan2Chip(
                    icon: Finan2Icons.cuenta(type.name),
                    label: type.label,
                    selected: _accountType == type,
                    onTap: () => setState(() => _accountType = type),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.md),
            Text(
              'Saldo de hoy',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium,
            ),
            Finan2AmountInput(
              controller: _balanceController,
              currencySymbol: currencySymbolFor(_currency),
            ),
          ],
        ),
        'Crear cuenta',
        _saveAccount,
      ),
      _Step.recovery => (
        'Frase de recuperación',
        'Los montos se cifran con una llave que vive solo en sus teléfonos. Si '
            'los dos la pierden, estas 12 palabras la recuperan. Se muestran una '
            'sola vez: anótalas en papel y guárdalas con tu pareja.',
        const SizedBox.shrink(),
        'Generar frase',
        _createPhrase,
      ),
    };

    return PopScope(
      // The household already exists: backing out would land on the
      // create/join screen, which no longer applies.
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(Finan2Space.xl),
            children: [
              Text(
                'Paso ${_step.index + 1} de ${_Step.values.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.inkFaint,
                ),
              ),
              const SizedBox(height: Finan2Space.sm),
              LinearProgressIndicator(
                value: (_step.index + 1) / _Step.values.length,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: Finan2Space.xl),
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: Finan2Space.xs),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(color: colors.inkSoft),
              ),
              const SizedBox(height: Finan2Space.lg),
              body,
              const SizedBox(height: Finan2Space.xl),
              FilledButton(
                onPressed: _busy ? null : onPrimary,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(primaryLabel),
              ),
              if (_step != _Step.currency) ...[
                const SizedBox(height: Finan2Space.sm),
                TextButton(
                  onPressed: _busy ? null : _next,
                  child: Text(
                    _step == _Step.recovery
                        ? 'Más tarde, desde Ajustes'
                        : 'Omitir',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
