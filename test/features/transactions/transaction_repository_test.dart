import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/debts/data/debt_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/data/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

const _householdId = 'h1';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late TransactionRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_householdId);
    repository = TransactionRepository(firestore: firestore, crypto: crypto);
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

  Future<int> readBalance(String accountId) async {
    final doc = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('accounts')
        .doc(accountId)
        .get();
    return (await Account.fromFirestore(doc, crypto, _householdId)).balance;
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

  Future<int> readDebtBalance(String debtId) async {
    final doc = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('debts')
        .doc(debtId)
        .get();
    return (await Debt.fromFirestore(doc, crypto, _householdId)).balance;
  }

  Movement movement({
    String id = '',
    int amount = 50000,
    CategoryType type = CategoryType.gasto,
    String accountId = 'acc1',
    String cardDebtId = '',
  }) {
    return Movement(
      id: id,
      amount: amount,
      type: type,
      categoryId: 'cat',
      accountId: accountId,
      cardDebtId: cardDebtId,
      description: 'test',
      date: DateTime(2026, 7, 15),
      createdBy: 'u1',
    );
  }

  Movement cardMovement({
    String id = '',
    int amount = 50000,
    CategoryType type = CategoryType.gasto,
    String cardDebtId = 'card1',
  }) =>
      movement(id: id, amount: amount, type: type, accountId: '', cardDebtId: cardDebtId);

  test('creating an expense debits the account balance', () async {
    await seedAccount('acc1', 500000);
    await repository.createTransaction(_householdId, movement(amount: 50000));
    expect(await readBalance('acc1'), 450000);
  });

  test('creating income credits the account balance', () async {
    await seedAccount('acc1', 500000);
    await repository.createTransaction(
      _householdId,
      movement(amount: 50000, type: CategoryType.ingreso),
    );
    expect(await readBalance('acc1'), 550000);
  });

  test('deleting a transaction reverses its effect on the balance', () async {
    await seedAccount('acc1', 500000);
    await repository.createTransaction(_householdId, movement(amount: 50000));
    expect(await readBalance('acc1'), 450000);

    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    await repository.deleteTransaction(_householdId, snap.docs.single.id);
    expect(await readBalance('acc1'), 500000);
  });

  test('editing the amount on the same account applies only the net delta', () async {
    await seedAccount('acc1', 500000);
    await repository.createTransaction(_householdId, movement(amount: 50000));
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    final id = snap.docs.single.id;

    await repository.updateTransaction(
      _householdId,
      movement(id: id, amount: 80000),
    );
    expect(await readBalance('acc1'), 420000);
  });

  test('editing the account moves the effect from the old account to the new one', () async {
    await seedAccount('acc1', 500000);
    await seedAccount('acc2', 100000);
    await repository.createTransaction(_householdId, movement(amount: 50000, accountId: 'acc1'));
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    final id = snap.docs.single.id;

    await repository.updateTransaction(
      _householdId,
      movement(id: id, amount: 50000, accountId: 'acc2'),
    );
    expect(await readBalance('acc1'), 500000);
    expect(await readBalance('acc2'), 50000);
  });

  test('creating a transaction for a deleted account still records it, balance untouched', () async {
    await repository.createTransaction(_householdId, movement(accountId: 'ghost'));
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    expect(snap.docs, hasLength(1));
  });

  test('a card purchase increases what is owed instead of debiting an account', () async {
    await seedCard('card1', 1000000);
    await repository.createTransaction(_householdId, cardMovement(amount: 50000));
    expect(await readDebtBalance('card1'), 1050000);
  });

  test('an income on a card (e.g. a refund) reduces what is owed', () async {
    await seedCard('card1', 1000000);
    await repository.createTransaction(
      _householdId,
      cardMovement(amount: 50000, type: CategoryType.ingreso),
    );
    expect(await readDebtBalance('card1'), 950000);
  });

  test('deleting a card purchase reverses the increase', () async {
    await seedCard('card1', 1000000);
    await repository.createTransaction(_householdId, cardMovement(amount: 50000));
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    await repository.deleteTransaction(_householdId, snap.docs.single.id);
    expect(await readDebtBalance('card1'), 1000000);
  });

  test('editing a movement from an account to a card moves the effect across', () async {
    await seedAccount('acc1', 500000);
    await seedCard('card1', 1000000);
    await repository.createTransaction(_householdId, movement(amount: 50000, accountId: 'acc1'));
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    final id = snap.docs.single.id;

    await repository.updateTransaction(_householdId, cardMovement(id: id, amount: 50000));
    expect(await readBalance('acc1'), 500000);
    expect(await readDebtBalance('card1'), 1050000);
  });
}
