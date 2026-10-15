import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/recurring_bills/data/recurring_bill_model.dart';
import 'package:finan2/features/recurring_bills/data/recurring_bill_scanner.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/data/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

const _householdId = 'h1';
final _now = DateTime(2026, 7, 9); // day 9

RecurringBill _bill({
  String id = 'b1',
  CategoryType type = CategoryType.factura,
  int dayOfMonth = 5,
  int amount = 1300000,
}) {
  return RecurringBill(
    id: id,
    name: 'Arriendo',
    type: type,
    categoryId: 'cat',
    accountId: 'acc',
    amount: amount,
    dayOfMonth: dayOfMonth,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late TransactionRepository transactionRepository;
  late RecurringBillScanner scanner;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_householdId);
    transactionRepository =
        TransactionRepository(firestore: firestore, crypto: crypto);
    scanner = RecurringBillScanner(transactionRepository);
  });

  Future<List<Movement>> readTransactions() async {
    final snap = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .get();
    return Future.wait(
      snap.docs.map((doc) => Movement.fromFirestore(doc, crypto, _householdId)),
    );
  }

  test('generates the Movement once the bill day has arrived', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: _now.day)],
      now: _now,
    );
    final transactions = await readTransactions();
    expect(transactions, hasLength(1));
    expect(transactions.single.amount, 1300000);
    expect(transactions.single.date, DateTime(_now.year, _now.month, _now.day));
  });

  test('generates the Movement on the day itself, not only after', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: _now.day - 1)],
      now: _now,
    );
    expect(await readTransactions(), hasLength(1));
  });

  test('does not generate before the bill day arrives', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: _now.day + 5)],
      now: _now,
    );
    expect(await readTransactions(), isEmpty);
  });

  test('re-scanning the same month never duplicates the transaction', () async {
    final bills = [_bill(dayOfMonth: _now.day)];
    for (var i = 0; i < 3; i++) {
      await scanner.scan(
        householdId: _householdId,
        currentUid: 'u1',
        bills: bills,
        now: _now,
      );
    }
    expect(await readTransactions(), hasLength(1));
  });

  test('an edited amount on an already-generated transaction is not clobbered '
      'by a later re-scan', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: _now.day, amount: 1300000)],
      now: _now,
    );
    final id = 'recurring_b1_${_now.year}_${_now.month}';
    await firestore
        .collection('households')
        .doc(_householdId)
        .collection('transactions')
        .doc(id)
        .update({'amount': await crypto.encryptAmount(_householdId, 1250000)});

    // Re-scan with the template still saying 1,300,000 - the user's manual
    // correction on the generated transaction should survive.
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: _now.day, amount: 1300000)],
      now: _now,
    );
    final transactions = await readTransactions();
    expect(transactions, hasLength(1));
    expect(transactions.single.amount, 1250000);
  });

  test('clamps a day-of-month beyond what the current month has', () async {
    // 2026 is not a leap year: February only has 28 days, so a day-31 bill
    // should clamp to the 28th and fire once that day arrives.
    final februaryNow = DateTime(2026, 2, 28);
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: 31)],
      now: februaryNow,
    );
    final transactions = await readTransactions();
    expect(transactions, hasLength(1));
    expect(transactions.single.date, DateTime(2026, 2, 28));
  });

  test('a clamped day-of-month does not fire before the clamped day arrives', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(dayOfMonth: 31)],
      now: DateTime(2026, 2, 27),
    );
    expect(await readTransactions(), isEmpty);
  });

  test('multiple bills only generate the ones whose day has arrived', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [
        _bill(id: 'due', dayOfMonth: _now.day),
        _bill(id: 'notYet', dayOfMonth: _now.day + 5),
      ],
      now: _now,
    );
    final transactions = await readTransactions();
    expect(transactions, hasLength(1));
    expect(transactions.single.id, 'recurring_due_${_now.year}_${_now.month}');
  });

  test('an income-type bill generates a Movement flagged as income', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [_bill(type: CategoryType.ingreso, dayOfMonth: _now.day)],
      now: _now,
    );
    final transactions = await readTransactions();
    expect(transactions.single.isIncome, isTrue);
  });

  test('a paused bill generates nothing', () async {
    await scanner.scan(
      householdId: _householdId,
      currentUid: 'u1',
      bills: [
        RecurringBill(
          id: 'p',
          name: 'Gym',
          type: CategoryType.factura,
          categoryId: 'cat',
          accountId: 'acc',
          amount: 90000,
          dayOfMonth: 1,
          paused: true,
        ),
      ],
      now: _now,
    );
    expect(await readTransactions(), isEmpty);
  });

  test('a weekly bill generates every date of the month so far, once each', () async {
    // Wednesdays from 2026-07-01; _now is the 9th.
    final bill = RecurringBill(
      id: 'w',
      name: 'Mercado',
      type: CategoryType.factura,
      categoryId: 'cat',
      accountId: 'acc',
      amount: 150000,
      dayOfMonth: 1,
      frequency: RecurringFrequency.weekly,
      startDate: DateTime(2026, 7, 1),
    );
    for (var i = 0; i < 2; i++) {
      await scanner.scan(householdId: _householdId, currentUid: 'u1', bills: [bill], now: _now);
    }
    final transactions = await readTransactions();
    expect(transactions.map((t) => t.date).toList()..sort(), [
      DateTime(2026, 7, 1),
      DateTime(2026, 7, 8),
    ]);
    expect(transactions.map((t) => t.id), contains('recurring_w_2026_7_8'));
  });
}
