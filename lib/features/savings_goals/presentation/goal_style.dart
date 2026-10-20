import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/finan2_tone.dart';
import '../../../core/utils/stable_index.dart';
import '../data/savings_goal_model.dart';

/// Icon per goal slug (the slug is what's stored).
const goalIcons = <String, IconData>{
  'viaje': Icons.flight_outlined,
  'emergencia': Icons.shield_outlined,
  'casa': Icons.home_outlined,
  'estudio': Icons.school_outlined,
  'otro': Icons.card_giftcard_outlined,
};

IconData goalIcon(String slug) => goalIcons[slug] ?? Icons.card_giftcard_outlined;

/// A goal's own color, picked from its ID since goals store none: the
/// same goal keeps its color when the list is reordered or another one is
/// deleted. [goals] is unused and kept so the call sites read the same.
Finan2Tone goalTone(BuildContext context, List<SavingsGoal> goals, String goalId) =>
    Finan2Tone.swatch(context, Finan2Palette.goalSwatches, stableIndex(goalId));

/// «diciembre» within this year, «jun 2027» beyond it - «junio 2027» when
/// [long], for a sentence rather than a row.
String goalDateLabel(DateTime date, DateTime now, {bool long = false}) {
  if (date.year == now.year) return DateFormat.MMMM().format(date);
  if (long) return DateFormat('MMMM y').format(date);
  return '${DateFormat.MMM().format(date).replaceAll('.', '')} ${date.year}';
}
