import 'dart:math' as math;

import 'entities/debt.dart';

/// A projected month for a single debt: what would be paid and what the
/// balance would be afterward, assuming the household keeps following the
/// Avalancha strategy from today onward.
class DebtScheduleEntry {
  const DebtScheduleEntry({
    required this.month,
    required this.payment,
    required this.endingBalance,
  });

  final DateTime month;
  final int payment;
  final int endingBalance;
}

class AvalancheResult {
  const AvalancheResult({required this.freeDate, required this.scheduleByDebtId});

  /// The month every debt reaches zero, or null if [_horizonMonths] isn't
  /// enough (payments don't even cover the accruing interest).
  final DateTime? freeDate;
  final Map<String, List<DebtScheduleEntry>> scheduleByDebtId;
}

const _horizonMonths = 360; // 30 años, tope de seguridad.

/// Simulates paying off [debts] month by month using the debt Avalancha
/// strategy: every debt gets its own base payment, and the debt with the
/// highest interest rate additionally gets a shared "extra" pool (funded by
/// each debt's `extraPayment`, card or not). Once a debt is paid off, its
/// base payment joins the pool, accelerating whichever debt is now the
/// highest-rate one left. Pure function, no Firestore dependency - safe to
/// call from a Riverpod `Provider`.
AvalancheResult computeAvalanche(List<Debt> debts, {DateTime? now}) {
  final start = now ?? DateTime.now();
  final active = debts.where((d) => d.balance > 0).toList();
  if (active.isEmpty) {
    return const AvalancheResult(freeDate: null, scheduleByDebtId: {});
  }

  final balances = {for (final d in active) d.id: d.balance.toDouble()};
  // The contractual minimum only (not Debt.monthlyBasePayment, which folds
  // extraPayment into the total) - the extra is handled separately via
  // extraPool below, so a debt's own extra isn't counted twice when it
  // happens to be the current avalanche target.
  final basePayments = {
    for (final d in active) d.id: (d.type.isCard ? d.minPayment : d.monthlyPayment).toDouble(),
  };
  final monthlyRates = {for (final d in active) d.id: math.pow(1 + d.rate / 100, 1 / 12) - 1};
  final rateById = {for (final d in active) d.id: d.rate};

  var extraPool = active.fold<double>(0, (sum, d) => sum + d.extraPayment);

  final schedule = <String, List<DebtScheduleEntry>>{for (final d in active) d.id: []};
  final paidOffIds = <String>{};
  DateTime? freeDate;

  for (var month = 1; month <= _horizonMonths; month++) {
    final activeIds = balances.keys.where((id) => !paidOffIds.contains(id)).toList()
      ..sort((a, b) => rateById[b]!.compareTo(rateById[a]!));
    if (activeIds.isEmpty) break;

    final targetId = activeIds.first;
    final monthDate = _addMonths(start, month);

    for (final id in activeIds) {
      final rate = monthlyRates[id]!;
      var balance = balances[id]!;
      final payment = basePayments[id]! + (id == targetId ? extraPool : 0);
      balance += balance * rate;
      balance -= payment;
      if (balance <= 0) {
        balance = 0;
        paidOffIds.add(id);
        extraPool += basePayments[id]!;
      }
      balances[id] = balance;
      schedule[id]!.add(
        DebtScheduleEntry(
          month: monthDate,
          payment: payment.round(),
          endingBalance: balance.round(),
        ),
      );
    }

    if (paidOffIds.length == balances.length) {
      freeDate = monthDate;
      break;
    }
  }

  return AvalancheResult(freeDate: freeDate, scheduleByDebtId: schedule);
}

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > daysInMonth ? daysInMonth : date.day;
  return DateTime(year, month, day);
}
