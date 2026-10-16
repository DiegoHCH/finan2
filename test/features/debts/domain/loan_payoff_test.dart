import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:finan2/features/debts/domain/loan_payoff.dart';
import 'package:flutter_test/flutter_test.dart';

Debt _loan({int balance = 5710000, double rate = 16, int payment = 420000, int extra = 0}) => Debt(
  id: '',
  name: 'Crédito carro',
  type: DebtType.vehiculo,
  balance: balance,
  rate: rate,
  paymentDay: 2,
  monthlyPayment: payment,
  extraPayment: extra,
);

void main() {
  final now = DateTime(2026, 10, 14);

  test('nudgeAmount is about a quarter of the payment, rounded to its leading digit', () {
    expect(nudgeAmount(420000), 100000);
    expect(nudgeAmount(1000000), 200000);
    expect(nudgeAmount(180000), 40000);
    expect(nudgeAmount(3), 0);
    expect(nudgeAmount(0), 0);
  });

  test('the loan ends sooner paying a bit more each month', () {
    final preview = loanPayoffPreview(_loan(), now)!;
    // 5,71M at 16% E.A. paying 420k: 15 payments, the last in January 2028.
    expect(preview.end, DateTime(2028, 1, 14));
    expect(preview.more, 100000);
    expect(preview.endWithMore!.isBefore(preview.end!), isTrue);
  });

  test('the extra already declared counts toward the payment', () {
    final base = loanPayoffPreview(_loan(), now)!;
    final withExtra = loanPayoffPreview(_loan(extra: 100000), now)!;
    expect(withExtra.end, base.endWithMore);
  });

  test('a payment that does not cover the interest never ends', () {
    final preview = loanPayoffPreview(_loan(balance: 50000000, rate: 30, payment: 100000), now)!;
    expect(preview.end, isNull);
  });

  test('nothing to say without a balance or a payment', () {
    expect(loanPayoffPreview(_loan(balance: 0), now), isNull);
    expect(loanPayoffPreview(_loan(payment: 0), now), isNull);
  });
}
