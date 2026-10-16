import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/viewmodels/transaction_providers.dart';
import '../../domain/annual_summary.dart';

export '../../domain/annual_summary.dart' show AnnualSummary;

/// [year]'s totals and its odd month - see computeAnnualSummary.
final annualSummaryProvider = Provider.autoDispose.family<AnnualSummary, int>((ref, year) {
  final transactions = ref.watch(transactionsForYearProvider(year)).value ?? const [];
  return computeAnnualSummary(year: year, transactions: transactions, now: DateTime.now());
});
