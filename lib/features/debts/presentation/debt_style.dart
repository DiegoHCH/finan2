import 'package:flutter/widgets.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/finan2_tone.dart';
import '../domain/entities/debt.dart';

/// A debt's own color - by its place in [debts], since debts store none -
/// so the list and its detail agree.
Finan2Tone debtTone(BuildContext context, List<Debt> debts, String debtId) {
  final index = debts.indexWhere((d) => d.id == debtId);
  return Finan2Tone.swatch(context, Finan2Palette.debtSwatches, index < 0 ? 0 : index);
}

/// «28» or «16,5»-style rate text without trailing zeros.
String ratePercent(double rate) =>
    rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toStringAsFixed(1);
