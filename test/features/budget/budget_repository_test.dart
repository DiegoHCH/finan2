import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/budget/data/budget_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

void main() {
  const householdId = 'h1';
  const july = (year: 2026, month: 7);
  const august = (year: 2026, month: 8);
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late BudgetRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(householdId);
    repository = BudgetRepository(firestore: firestore, crypto: crypto);
  });

  // Read with get(): fake_cloud_firestore's snapshots() misses a doc first
  // created inside a transaction.
  Future<Map<String, int>> budgetOf(({int year, int month}) month) async {
    final doc = await firestore
        .doc('households/$householdId/budgets/${month.year}_${month.month}')
        .get();
    return {
      for (final entry in (doc.data() ?? const {}).entries)
        entry.key: await crypto.decryptAmount(householdId, entry.value as String),
    };
  }

  Future<void> plan(({int year, int month}) month, String categoryId, int amount) =>
      repository.setCategoryAmount(
        householdId,
        year: month.year,
        month: month.month,
        categoryId: categoryId,
        amount: amount,
      );

  test('copies every category into an empty month', () async {
    await plan(july, 'mercado', 800000);
    await plan(july, 'ocio', 200000);

    final copied = await repository.copyBudget(householdId, from: july, to: august);

    expect(copied, 2);
    expect(await budgetOf(august), {'mercado': 800000, 'ocio': 200000});
  });

  test('never overwrites a month that already has a budget', () async {
    await plan(july, 'mercado', 800000);
    await plan(august, 'ocio', 50000);

    final copied = await repository.copyBudget(householdId, from: july, to: august);

    expect(copied, 0);
    expect(await budgetOf(august), {'ocio': 50000});
  });

  test('copying from an empty month does nothing', () async {
    final copied = await repository.copyBudget(householdId, from: july, to: august);

    expect(copied, 0);
    expect(await budgetOf(august), isEmpty);
  });
}
