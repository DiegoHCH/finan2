import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/viewmodels/transaction_providers.dart';

/// A year's totals, computed client-side from every transaction in the
/// year - no separate Firestore aggregate needed.
class AnnualSummary {
  const AnnualSummary({
    required this.ganado,
    required this.gastado,
    required this.gastoPorMes,
  });

  final int ganado;
  final int gastado;
  int get ahorrado => ganado - gastado;

  /// Non-income spend per month, index 0 = enero.
  final List<int> gastoPorMes;
}

final annualSummaryProvider = Provider.autoDispose.family<AnnualSummary, int>((ref, year) {
  final transactions = ref.watch(transactionsForYearProvider(year)).value ?? const [];
  var ganado = 0;
  var gastado = 0;
  final perMonth = List<int>.filled(12, 0);
  for (final tx in transactions) {
    if (tx.isIncome) {
      ganado += tx.amount;
    } else {
      gastado += tx.amount;
      final idx = tx.date.month - 1;
      if (idx >= 0 && idx < 12) perMonth[idx] += tx.amount;
    }
  }
  return AnnualSummary(ganado: ganado, gastado: gastado, gastoPorMes: perMonth);
});
