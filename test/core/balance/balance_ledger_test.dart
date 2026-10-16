import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/balance/balance_ledger.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/data/account_repository.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/debts/data/card_payment_repository.dart';
import 'package:finan2/features/debts/data/debt_mapper.dart';
import 'package:finan2/features/debts/data/debt_repository.dart';
import 'package:finan2/features/debts/domain/entities/card_payment.dart';
import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:finan2/features/transactions/data/transaction_repository.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_balance_ledger.dart';
import '../../helpers/test_household_crypto.dart';

const _householdId = 'h1';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_householdId);
  });

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      firestore.collection('households').doc(_householdId).collection(name);

  TransactionRepository movementsOn(String device) => TransactionRepository(
    firestore: firestore,
    crypto: crypto,
    ledger: testBalanceLedger(firestore, crypto, device: device),
  );

  Future<void> seedAccount(int balance) async => collection('accounts')
      .doc('acc1')
      .set(
        await Account(
          id: 'acc1',
          name: 'Banco',
          type: AccountType.banco,
          balance: balance,
          includeInAvailable: true,
        ).toFirestore(crypto, _householdId),
      );

  Future<Account> readAccount() async =>
      Account.fromFirestore(await collection('accounts').doc('acc1').get(), crypto, _householdId);

  Movement expense(int amount) => Movement(
    id: '',
    amount: amount,
    type: CategoryType.gasto,
    categoryId: 'cat',
    accountId: 'acc1',
    description: '',
    date: DateTime(2026, 10, 16),
    createdBy: 'u1',
  );

  test('each device writes only its own share, so both add up', () async {
    await seedAccount(500000);
    await movementsOn('phone-a').createTransaction(_householdId, expense(20000));
    await movementsOn('phone-b').createTransaction(_householdId, expense(30000));
    await movementsOn('phone-a').createTransaction(_householdId, expense(5000));

    expect((await readAccount()).balance, 445000);
    final shares = (await collection('accounts').doc('acc1').get()).data()![deviceBalancesField];
    expect((shares as Map).keys, unorderedEquals(['phone-a', 'phone-b']));
  });

  test('two saves at once on the same device both count', () async {
    await seedAccount(500000);
    final repository = movementsOn('phone-a');
    await Future.wait([
      repository.createTransaction(_householdId, expense(10000)),
      repository.createTransaction(_householdId, expense(20000)),
    ]);
    expect((await readAccount()).balance, 470000);
  });

  test('a balance set by hand is the whole balance, shares included', () async {
    await seedAccount(500000);
    await movementsOn('phone-a').createTransaction(_householdId, expense(20000));
    final accounts = AccountRepository(
      firestore: firestore,
      crypto: crypto,
      ledger: testBalanceLedger(firestore, crypto),
    );

    final account = await readAccount();
    await accounts.updateAccount(
      _householdId,
      Account(
        id: account.id,
        name: 'Banco',
        type: account.type,
        balance: 300000,
        includeInAvailable: true,
      ),
    );
    expect((await readAccount()).balance, 300000);

    await movementsOn('phone-b').createTransaction(_householdId, expense(10000));
    expect((await readAccount()).balance, 290000);
  });

  test("a card's plaintext «anything left to pay» follows its shares", () async {
    await seedAccount(500000);
    const card = Debt(
      id: 'card1',
      name: 'Visa',
      type: DebtType.tarjeta,
      balance: 100000,
      rate: 28,
      paymentDay: 5,
    );
    await collection('debts').doc('card1').set(await card.toFirestore(crypto, _householdId));
    final payments = CardPaymentRepository(
      firestore: firestore,
      crypto: crypto,
      ledger: testBalanceLedger(firestore, crypto),
    );

    await payments.createPayment(
      _householdId,
      CardPayment(
        id: '',
        amount: 100000,
        fromAccountId: 'acc1',
        cardDebtId: 'card1',
        date: DateTime(2026, 10, 16),
        createdBy: 'u1',
      ),
    );

    final doc = await collection('debts').doc('card1').get();
    expect((await debtFromFirestore(doc, crypto, _householdId)).balance, 0);
    expect(doc.data()!['hasBalance'], isFalse);
    expect((await readAccount()).balance, 400000);

    // Editing the card by hand afterwards keeps what the payment moved.
    final debts = DebtRepository(
      firestore: firestore,
      crypto: crypto,
      ledger: testBalanceLedger(firestore, crypto),
    );
    await debts.updateDebt(
      _householdId,
      const Debt(
        id: 'card1',
        name: 'Visa',
        type: DebtType.tarjeta,
        balance: 50000,
        rate: 28,
        paymentDay: 5,
      ),
    );
    final edited = await collection('debts').doc('card1').get();
    expect((await debtFromFirestore(edited, crypto, _householdId)).balance, 50000);
    expect(edited.data()!['hasBalance'], isTrue);
  });
}
