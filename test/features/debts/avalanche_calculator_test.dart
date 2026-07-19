import 'package:finan2/features/debts/data/avalanche_calculator.dart';
import 'package:finan2/features/debts/data/debt_model.dart';
import 'package:flutter_test/flutter_test.dart';

Debt _card({
  String id = 'card',
  int balance = 1000000,
  double rate = 28,
  int minPayment = 180000,
  int extraPayment = 180000,
  int creditLimit = 5000000,
}) {
  return Debt(
    id: id,
    name: 'Tarjeta',
    type: DebtType.tarjeta,
    balance: balance,
    rate: rate,
    paymentDay: 5,
    creditLimit: creditLimit,
    minPayment: minPayment,
    extraPayment: extraPayment,
  );
}

Debt _loan({
  String id = 'loan',
  int balance = 3000000,
  double rate = 16,
  int monthlyPayment = 420000,
  int extraPayment = 0,
}) {
  return Debt(
    id: id,
    name: 'Crédito',
    type: DebtType.vehiculo,
    balance: balance,
    rate: rate,
    paymentDay: 10,
    originalAmount: balance + 1000000,
    monthlyPayment: monthlyPayment,
    extraPayment: extraPayment,
  );
}

void main() {
  final now = DateTime(2026, 7, 9);

  test('no debts returns an empty result', () {
    final result = computeAvalanche(const [], now: now);
    expect(result.freeDate, isNull);
    expect(result.scheduleByDebtId, isEmpty);
  });

  test('a debt already at zero balance is excluded entirely', () {
    final result = computeAvalanche([_card(balance: 0)], now: now);
    expect(result.freeDate, isNull);
    expect(result.scheduleByDebtId, isEmpty);
  });

  test('a single payable debt reaches zero and reports a freeDate', () {
    final result = computeAvalanche([_card()], now: now);
    expect(result.freeDate, isNotNull);
    final schedule = result.scheduleByDebtId['card']!;
    expect(schedule.last.endingBalance, 0);
    // Every month up to the last must show a strictly decreasing balance.
    for (var i = 1; i < schedule.length; i++) {
      expect(schedule[i].endingBalance, lessThan(schedule[i - 1].endingBalance));
    }
  });

  test('a debt whose payment does not cover interest never frees', () {
    final stuck = _card(balance: 10000000, rate: 60, minPayment: 10000, extraPayment: 0);
    final result = computeAvalanche([stuck], now: now);
    expect(result.freeDate, isNull);
    // Balance should never decrease - it's stuck or growing.
    final schedule = result.scheduleByDebtId['card']!;
    expect(schedule.last.endingBalance, greaterThanOrEqualTo(stuck.balance));
  });

  test('avalanche prioritizes the higher-rate debt for the extra payment', () {
    final card = _card(); // 28% - higher priority
    final loan = _loan(); // 16%
    final result = computeAvalanche([loan, card], now: now);

    final cardSchedule = result.scheduleByDebtId['card']!;
    final loanSchedule = result.scheduleByDebtId['loan']!;

    // The card (highest rate) should receive the full extra payment and pay
    // off before the loan, which only gets its base installment until then.
    expect(cardSchedule.first.payment, card.minPayment + card.extraPayment);
    expect(loanSchedule.first.payment, loan.monthlyPayment);
    expect(cardSchedule.length, lessThan(loanSchedule.length));
  });

  test('once the priority debt is paid off, its payment redirects to the next one', () {
    final card = _card(balance: 300000); // pays off fast
    final loan = _loan();
    final result = computeAvalanche([loan, card], now: now);

    final cardSchedule = result.scheduleByDebtId['card']!;
    final loanSchedule = result.scheduleByDebtId['loan']!;
    final monthsCardTakes = cardSchedule.length;

    // Once the card is gone, the loan's payment for that same month index
    // should jump above its own base monthlyPayment (it now absorbs the
    // card's freed-up base payment).
    expect(
      loanSchedule[monthsCardTakes].payment,
      greaterThan(loan.monthlyPayment),
    );
  });

  test('a loan\'s own extraPayment is added on top of its base cuota', () {
    final loan = _loan(extraPayment: 100000);
    final result = computeAvalanche([loan], now: now);
    final schedule = result.scheduleByDebtId['loan']!;
    expect(schedule.first.payment, loan.monthlyPayment + 100000);
  });

  test('a loan\'s extraPayment also feeds the shared pool for a higher-rate card', () {
    final card = _card(extraPayment: 0); // 28%, no extra of its own
    final loan = _loan(extraPayment: 200000); // 16%, but contributes to the pool
    final result = computeAvalanche([loan, card], now: now);

    // The card is the higher-rate target, so it should receive its own base
    // payment plus the loan's extra, funneled through the shared pool.
    final cardSchedule = result.scheduleByDebtId['card']!;
    expect(cardSchedule.first.payment, card.minPayment + 200000);
    // The loan, not being the target, only pays its own base cuota.
    final loanSchedule = result.scheduleByDebtId['loan']!;
    expect(loanSchedule.first.payment, loan.monthlyPayment);
  });

  test('freeDate lands after the horizon-bounded schedule length in months', () {
    final result = computeAvalanche([_card(balance: 200000)], now: now);
    final schedule = result.scheduleByDebtId['card']!;
    final expected = DateTime(now.year, now.month + schedule.length, now.day);
    expect(result.freeDate, expected);
  });
}
