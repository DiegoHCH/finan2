import 'package:finan2/features/debts/domain/avalanche_calculator.dart';
import 'package:finan2/features/debts/domain/debt_plan.dart';
import 'package:finan2/features/debts/domain/entities/card_payment.dart';
import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:flutter_test/flutter_test.dart';

Debt _debt(String id, double rate, int balance, {int day = 18}) => Debt(
  id: id,
  name: id,
  type: DebtType.tarjeta,
  balance: balance,
  rate: rate,
  paymentDay: day,
  creditLimit: 3000000,
  minPayment: 180000,
);

CardPayment _payment(DateTime date, int amount) => CardPayment(
  id: '${date.month}',
  amount: amount,
  fromAccountId: 'a',
  cardDebtId: 'visa',
  date: date,
  createdBy: 'u1',
);

void main() {
  final today = DateTime(2026, 10, 14, 9);

  test('avalancheOrder puts the highest rate first and the paid-off last', () {
    final order = avalancheOrder([
      _debt('carro', 16, 3710000),
      _debt('vieja', 40, 0),
      _debt('visa', 28, 1140000),
    ]);
    expect(order.map((d) => d.id), ['visa', 'carro', 'vieja']);
  });

  group('nextPaymentDate', () {
    test('this month when the day has not passed, today included', () {
      expect(nextPaymentDate(18, today), DateTime(2026, 10, 18));
      expect(nextPaymentDate(14, today), DateTime(2026, 10, 14));
    });

    test('next month once it passed, clamped to the last day', () {
      expect(nextPaymentDate(2, today), DateTime(2026, 11, 2));
      expect(nextPaymentDate(31, DateTime(2027, 2, 1)), DateTime(2027, 2, 28));
    });
  });

  test('daysUntil counts whole days', () {
    expect(daysUntil(DateTime(2026, 10, 18), today), 4);
    expect(daysUntil(DateTime(2026, 10, 14), today), 0);
  });

  test('debtCalendar: recent payments, then the next, then the plan', () {
    final calendar = debtCalendar(
      payments: [
        _payment(DateTime(2026, 9, 18), 400000),
        _payment(DateTime(2026, 6, 18), 300000),
        _payment(DateTime(2026, 7, 18), 300000),
        _payment(DateTime(2026, 8, 18), 350000),
      ],
      schedule: [
        for (var i = 1; i <= 8; i++)
          DebtScheduleEntry(month: DateTime(2026, 10 + i), payment: 400000, endingBalance: 0),
      ],
      paymentDay: 18,
      today: today,
    );
    expect(calendar.map((e) => e.kind).take(5), [
      DebtCalendarKind.paid,
      DebtCalendarKind.paid,
      DebtCalendarKind.paid,
      DebtCalendarKind.next,
      DebtCalendarKind.planned,
    ]);
    expect(calendar.first.date, DateTime(2026, 7, 18));
    expect(calendar[3].date, DateTime(2026, 10, 18));
    expect(calendar[4].date, DateTime(2026, 11, 18));
    expect(calendar.length, 3 + 6);
  });

  test('soonestPayment picks the closest day and the plan payment', () {
    final debts = [_debt('visa', 28, 1140000), _debt('carro', 16, 3710000, day: 2)];
    final avalanche = computeAvalanche(debts, now: today);
    final soonest = soonestPayment(debts, avalanche, today)!;
    expect(soonest.debt.id, 'visa');
    expect(soonest.date, DateTime(2026, 10, 18));
    expect(soonest.suggested, avalanche.scheduleByDebtId['visa']!.first.payment);
    expect(soonestPayment(const [], avalanche, today), isNull);
  });
}
