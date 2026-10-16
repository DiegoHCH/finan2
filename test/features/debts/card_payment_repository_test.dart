import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/debts/domain/entities/card_payment.dart';
import 'package:finan2/features/debts/data/card_payment_mapper.dart';
import 'package:finan2/features/debts/data/card_payment_repository.dart';
import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:finan2/features/debts/data/debt_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_balance_ledger.dart';
import '../../helpers/test_household_crypto.dart';

const _householdId = 'h1';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late CardPaymentRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_householdId);
    repository = CardPaymentRepository(
      firestore: firestore,
      crypto: crypto,
      ledger: testBalanceLedger(firestore, crypto),
    );
  });

  Future<void> seedAccount(String id, int balance) async {
    final account = Account(
      id: id,
      name: id,
      type: AccountType.banco,
      balance: balance,
      includeInAvailable: true,
    );
    await firestore
        .collection('households')
        .doc(_householdId)
        .collection('accounts')
        .doc(id)
        .set(await account.toFirestore(crypto, _householdId));
  }

  Future<void> seedCard(String id, int balance) async {
    final debt = Debt(
      id: id,
      name: id,
      type: DebtType.tarjeta,
      balance: balance,
      rate: 28,
      paymentDay: 5,
      creditLimit: 5000000,
    );
    await firestore
        .collection('households')
        .doc(_householdId)
        .collection('debts')
        .doc(id)
        .set(await debt.toFirestore(crypto, _householdId));
  }

  Future<int> readBalance(String accountId) async {
    final doc = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('accounts')
        .doc(accountId)
        .get();
    return (await Account.fromFirestore(doc, crypto, _householdId)).balance;
  }

  Future<int> readDebtBalance(String debtId) async {
    final doc = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('debts')
        .doc(debtId)
        .get();
    return (await debtFromFirestore(doc, crypto, _householdId)).balance;
  }

  CardPayment payment({String id = '', int amount = 100000}) {
    return CardPayment(
      id: id,
      amount: amount,
      fromAccountId: 'acc1',
      cardDebtId: 'card1',
      date: DateTime(2026, 7, 20),
      createdBy: 'u1',
    );
  }

  test('paying a card debits the account and credits down the debt', () async {
    await seedAccount('acc1', 500000);
    await seedCard('card1', 1000000);
    await repository.createPayment(_householdId, payment(amount: 100000));
    expect(await readBalance('acc1'), 400000);
    expect(await readDebtBalance('card1'), 900000);
  });

  test('deleting a payment reverses both balances', () async {
    await seedAccount('acc1', 500000);
    await seedCard('card1', 1000000);
    await repository.createPayment(_householdId, payment(amount: 100000));

    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('cardPayments')
        .get();
    final saved = await cardPaymentFromFirestore(snap.docs.single, crypto, _householdId);
    await repository.deletePayment(_householdId, saved);

    expect(await readBalance('acc1'), 500000);
    expect(await readDebtBalance('card1'), 1000000);
  });

  test('a payment against a deleted account still logs and adjusts the card', () async {
    await seedCard('card1', 1000000);
    await repository.createPayment(_householdId, payment(amount: 100000));
    expect(await readDebtBalance('card1'), 900000);
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('cardPayments')
        .get();
    expect(snap.docs, hasLength(1));
  });
}
