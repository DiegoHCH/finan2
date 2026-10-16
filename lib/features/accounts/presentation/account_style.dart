import 'package:flutter/widgets.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/finan2_tone.dart';
import '../../../core/utils/stable_index.dart';
import '../data/account_model.dart';

/// An account's own color, picked from its ID since accounts store none:
/// the same account keeps it everywhere - Cuentas, the account picker in
/// Anotar, Pasar and its history - and when another one is added or
/// deleted. The base color, for widgets that make the tone themselves.
Color accountColor(String accountId) =>
    Finan2Palette.accountSwatches[stableIndex(accountId) % Finan2Palette.accountSwatches.length];

/// [accountColor] as a tone for the current theme.
Finan2Tone accountTone(BuildContext context, String accountId) =>
    Finan2Tone.of(context, accountColor(accountId));

/// An account's icon by its type.
IconData accountIcon(AccountType type) => Finan2Icons.cuenta(type.name);
