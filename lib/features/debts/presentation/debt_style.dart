import 'package:flutter/widgets.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/finan2_tone.dart';
import '../../../core/utils/stable_index.dart';
import '../domain/entities/debt.dart';

/// A debt's own color, picked from its ID since debts store none: the
/// same debt keeps its color when the list is reordered or another one is
/// deleted. [debts] is unused and kept so the call sites read the same.
Finan2Tone debtTone(BuildContext context, List<Debt> debts, String debtId) =>
    Finan2Tone.swatch(context, Finan2Palette.debtSwatches, stableIndex(debtId));

/// «28» or «16,5»-style rate text without trailing zeros.
String ratePercent(double rate) =>
    rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toStringAsFixed(1);
