import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/debt_model.dart';

/// Maps [DebtStatus] to the app's existing semantic colors - reuses
/// `expense`/`saving`/`income` rather than adding a dedicated debt-status
/// trio, since they're already the same red/gold/green used everywhere else.
extension DebtStatusColor on DebtStatus {
  Color of(Finan2Colors colors) => switch (this) {
    DebtStatus.critical => colors.expense,
    DebtStatus.warning => colors.saving,
    DebtStatus.good => colors.income,
  };
}
