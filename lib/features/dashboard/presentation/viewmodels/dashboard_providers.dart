import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/year_month.dart';
import '../../../budget/presentation/viewmodels/budget_providers.dart';
import '../../../transactions/domain/entities/movement.dart';
import '../../../transactions/presentation/viewmodels/transaction_providers.dart';
import '../../domain/month_overview.dart';

/// Inicio's answer for the current month - see computeMonthOverview.
final monthOverviewProvider = Provider.autoDispose<MonthOverview>((ref) {
  final pending = ref.watch(pendingMovementDeletionsProvider);
  final transactions = (ref.watch(transactionsForMonthProvider).value ?? const <Movement>[])
      .where((tx) => !pending.contains(tx.id))
      .toList();
  return computeMonthOverview(
    budget: ref.watch(currentMonthBudgetProvider).value ?? const {},
    carryOver: ref.watch(carryOverProvider(currentYearMonth())),
    transactions: transactions,
    today: DateTime.now(),
  );
});

/// The month's latest movements, newest first, for Inicio's short list.
final recentMovementsProvider = Provider.autoDispose<List<Movement>>((ref) {
  final pending = ref.watch(pendingMovementDeletionsProvider);
  final transactions = [
    for (final tx in ref.watch(transactionsForMonthProvider).value ?? const <Movement>[])
      if (!pending.contains(tx.id)) tx,
  ]..sort((a, b) => b.date.compareTo(a.date));
  return transactions.take(4).toList();
});
