import 'package:finan2/features/debts/data/debt_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Debt _cardWithPaid(int paid, {int creditLimit = 1000}) {
  return Debt(
    id: 'd',
    name: 'Tarjeta',
    type: DebtType.tarjeta,
    balance: creditLimit - paid,
    rate: 28,
    paymentDay: 5,
    creditLimit: creditLimit,
  );
}

void main() {
  test('status is critical below 40% paid', () {
    expect(_cardWithPaid(0).status, DebtStatus.critical);
    expect(_cardWithPaid(390).status, DebtStatus.critical);
  });

  test('status is warning from 40% up to (not including) 75% paid', () {
    expect(_cardWithPaid(400).status, DebtStatus.warning);
    expect(_cardWithPaid(620).status, DebtStatus.warning);
    expect(_cardWithPaid(749).status, DebtStatus.warning);
  });

  test('status is good from 75% paid through fully paid off', () {
    expect(_cardWithPaid(750).status, DebtStatus.good);
    expect(_cardWithPaid(1000).status, DebtStatus.good);
  });

  test('a debt with no reference amount (0 credit limit) reads as critical', () {
    expect(_cardWithPaid(0, creditLimit: 0).status, DebtStatus.critical);
  });

  test('type labels follow the app language; the stored name does not', () {
    addTearDown(() => Intl.defaultLocale = 'es');
    expect(DebtType.vehiculo.label, 'Vehículo');
    Intl.defaultLocale = 'en';
    expect(DebtType.vehiculo.label, 'Car loan');
    expect(DebtType.vehiculo.name, 'vehiculo');
  });
}
