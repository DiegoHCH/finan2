import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/entities/debt.dart';

/// Maps [DebtStatus] to the theme's semantic colors: red only when it's
/// critical, amber for a warning, green when it's on track.
extension DebtStatusColor on DebtStatus {
  Color of(Finan2Colors colors) => switch (this) {
    DebtStatus.critical => colors.expense,
    DebtStatus.warning => colors.warning,
    DebtStatus.good => colors.income,
  };
}
