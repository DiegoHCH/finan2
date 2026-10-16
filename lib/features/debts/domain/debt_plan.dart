import 'avalanche_calculator.dart';
import 'entities/card_payment.dart';
import 'entities/debt.dart';

/// Debts in the Avalancha order: the ones still owed by highest rate first
/// (the one getting the extra), then the paid-off ones.
List<Debt> avalancheOrder(List<Debt> debts) {
  final owed = debts.where((d) => d.balance > 0).toList()..sort((a, b) => b.rate.compareTo(a.rate));
  return [...owed, ...debts.where((d) => d.balance <= 0)];
}

/// The contractual payment: a card's minimum, a loan's installment.
int debtMinimum(Debt debt) => debt.type.isCard ? debt.minPayment : debt.monthlyPayment;

/// The next time [paymentDay] comes around from [today] (today included),
/// clamped to the month's last day.
DateTime nextPaymentDate(int paymentDay, DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  DateTime inMonth(int year, int month) {
    final last = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, paymentDay.clamp(1, last));
  }

  final thisMonth = inMonth(day.year, day.month);
  return thisMonth.isBefore(day) ? inMonth(day.year, day.month + 1) : thisMonth;
}

/// [date] [months] months later, on the same day or the month's last one.
DateTime addMonthsClamped(DateTime date, int months, int paymentDay) {
  final first = DateTime(date.year, date.month + months);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, paymentDay.clamp(1, last));
}

/// Whole days from [today] to [date]: 0 today, 1 tomorrow.
int daysUntil(DateTime date, DateTime today) {
  final from = DateTime.utc(today.year, today.month, today.day);
  final to = DateTime.utc(date.year, date.month, date.day);
  return to.difference(from).inDays;
}

enum DebtCalendarKind { paid, next, planned }

/// A line of a debt's payment calendar: a payment already made, the next
/// one, or one the Avalancha plan expects.
class DebtCalendarEntry {
  const DebtCalendarEntry({
    required this.kind,
    required this.date,
    required this.amount,
    this.payment,
  });

  final DebtCalendarKind kind;
  final DateTime date;
  final int amount;

  /// The recorded payment behind a [DebtCalendarKind.paid] entry.
  final CardPayment? payment;
}

/// A debt's calendar: the last [paidShown] recorded [payments] (oldest
/// first), then the projected [schedule] dated on the debt's payment day
/// from the next one on - the first of them is [DebtCalendarKind.next].
List<DebtCalendarEntry> debtCalendar({
  required List<CardPayment> payments,
  required List<DebtScheduleEntry> schedule,
  required int paymentDay,
  required DateTime today,
  int paidShown = 3,
  int plannedShown = 6,
}) {
  final paid = [...payments]..sort((a, b) => a.date.compareTo(b.date));
  final next = nextPaymentDate(paymentDay, today);
  return [
    for (final p in paid.skip(paid.length > paidShown ? paid.length - paidShown : 0))
      DebtCalendarEntry(kind: DebtCalendarKind.paid, date: p.date, amount: p.amount, payment: p),
    for (final (i, entry) in schedule.take(plannedShown).indexed)
      DebtCalendarEntry(
        kind: i == 0 ? DebtCalendarKind.next : DebtCalendarKind.planned,
        date: addMonthsClamped(next, i, paymentDay),
        amount: entry.payment,
      ),
  ];
}

/// The payment due soonest across [debts] still owed, with what the
/// Avalancha plan suggests paying then; null with nothing owed.
({Debt debt, DateTime date, int suggested})? soonestPayment(
  List<Debt> debts,
  AvalancheResult avalanche,
  DateTime today,
) {
  ({Debt debt, DateTime date, int suggested})? soonest;
  for (final debt in debts.where((d) => d.balance > 0)) {
    final date = nextPaymentDate(debt.paymentDay, today);
    if (soonest != null && !date.isBefore(soonest.date)) continue;
    final schedule = avalanche.scheduleByDebtId[debt.id];
    final suggested = schedule == null || schedule.isEmpty
        ? debt.monthlyBasePayment
        : schedule.first.payment;
    soonest = (debt: debt, date: date, suggested: suggested);
  }
  return soonest;
}
