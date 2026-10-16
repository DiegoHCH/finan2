import 'entities/movement.dart';

/// A day of Movimientos: its movements and what they add up to.
class MovementDay {
  const MovementDay({required this.date, required this.movements});

  /// The calendar day, no time.
  final DateTime date;
  final List<Movement> movements;

  /// Income minus everything else.
  int get net => movements.fold(0, (sum, tx) => sum + tx.signedAmount);
}

extension SignedMovement on Movement {
  /// Positive for income, negative for anything that went out.
  int get signedAmount => isIncome ? amount : -amount;
}

/// [movements] grouped by calendar day, newest day first, keeping each
/// day's movements in the order they came.
List<MovementDay> groupByDay(List<Movement> movements) {
  final byDay = <DateTime, List<Movement>>{};
  for (final tx in movements) {
    final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
    byDay.putIfAbsent(day, () => []).add(tx);
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final day in days) MovementDay(date: day, movements: byDay[day]!)];
}

/// Net of [movements]: income minus everything else.
int netOf(Iterable<Movement> movements) => movements.fold(0, (sum, tx) => sum + tx.signedAmount);
