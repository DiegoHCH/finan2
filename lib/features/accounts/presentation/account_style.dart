import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/finan2_tone.dart';
import '../../../core/utils/stable_index.dart';
import '../../../core/utils/swatch_assignment.dart';
import '../data/account_model.dart';
import 'viewmodels/account_providers.dart';

/// Each account's own color slot. Accounts store no color, so it comes from
/// the ID, moved to a free slot if another account has it - two accounts
/// side by side in Cuentas or in Anotar's picker never share a color.
final accountSwatchesProvider = Provider<Map<String, int>>((ref) {
  final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
  return assignSwatches([for (final a in accounts) a.id], Finan2Palette.accountSwatches.length);
});

/// An account's color: the same in Cuentas, Anotar, Mover and its history.
/// The base color, for widgets that make the tone themselves.
Color accountColor(WidgetRef ref, String accountId) {
  final slot = ref.watch(accountSwatchesProvider)[accountId] ?? stableIndex(accountId);
  return Finan2Palette.accountSwatches[slot % Finan2Palette.accountSwatches.length];
}

/// [accountColor] as a tone for the current theme.
Finan2Tone accountTone(BuildContext context, WidgetRef ref, String accountId) =>
    Finan2Tone.of(context, accountColor(ref, accountId));

/// The types as offered to pick from, the most common first: a bank, a
/// wallet, cash, a debit card.
const accountTypeOrder = [
  AccountType.banco,
  AccountType.billetera,
  AccountType.efectivo,
  AccountType.debito,
];

/// An account's icon by its type.
IconData accountIcon(AccountType type) => Finan2Icons.cuenta(type.name);
