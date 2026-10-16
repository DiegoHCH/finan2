import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/demo/data/demo_data_repository.dart';
import 'package:finan2/features/demo/domain/demo_ids.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_household_crypto.dart';

const _householdId = 'h1';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late DemoDataRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_householdId);
    repository = DemoDataRepository(firestore: firestore, crypto: crypto);
  });

  DocumentReference<Map<String, dynamic>> household() =>
      firestore.collection('households').doc(_householdId);
  final now = DateTime(2026, 10, 16, 18);

  Future<void> seedOwnData() async {
    await household()
        .collection('categories')
        .doc('own_mercado')
        .set(
          const Category(
            id: 'own_mercado',
            name: 'Mercado',
            type: CategoryType.gasto,
            iconSlug: 'mercado',
            color: 0xFFEA580C,
          ).toFirestore(),
        );
    await household()
        .collection('accounts')
        .doc('own_account')
        .set(
          await const Account(
            id: 'own_account',
            name: 'Mía',
            type: AccountType.banco,
            balance: 1000,
            includeInAvailable: true,
          ).toFirestore(crypto, _householdId),
        );
    await household().collection('budgets').doc('2026_10').set({
      'own_mercado': await crypto.encryptAmount(_householdId, 999),
    });
  }

  test('fills three months, reusing the household\'s own categories', () async {
    await seedOwnData();
    await repository.seed(_householdId, uid: 'u1', partnerUid: 'u2', now: now);

    final movements = (await household().collection('transactions').get()).docs;
    expect(movements.length, greaterThan(60));
    expect(movements.every((d) => isDemoId(d.id)), isTrue);
    expect(movements.every((d) => !(d.data()['date'] as Timestamp).toDate().isAfter(now)), isTrue);
    expect(movements.where((d) => d.data()['categoryId'] == 'own_mercado'), isNotEmpty);
    expect(movements.where((d) => d.data()['paidBy'] == 'u2'), isNotEmpty);

    final categories = (await household().collection('categories').get()).docs.map((d) => d.id);
    expect(categories, isNot(contains('${demoIdPrefix}cat_mercado')));

    // A month already planned keeps its amount; the rest are filled in.
    final budget = (await household().collection('budgets').doc('2026_10').get()).data()!;
    expect(await crypto.decryptAmount(_householdId, budget['own_mercado'] as String), 999);
    expect(budget.length, greaterThan(1));

    // Demo debts stay out of the Worker's payment reminders.
    final debts = (await household().collection('debts').get()).docs;
    expect(debts.every((d) => d.data()['hasBalance'] == false), isTrue);
  });

  test('seeding twice writes the same records, not twice as many', () async {
    await repository.seed(_householdId, uid: 'u1', now: now);
    final first = (await household().collection('transactions').get()).size;
    await repository.seed(_householdId, uid: 'u1', now: now);
    expect((await household().collection('transactions').get()).size, first);
  });

  test('removing takes only the demo data and the budget amounts it set', () async {
    await seedOwnData();
    await repository.seed(_householdId, uid: 'u1', now: now);
    await household()
        .collection('transactions')
        .doc('recurring_${demoIdPrefix}bill_arriendo_2026_10')
        .set({'description': 'made by the app from a demo bill'});
    await household().collection('transactions').doc('own_tx').set({'description': 'mine'});

    await repository.remove(_householdId);

    for (final name in [
      'accounts',
      'debts',
      'savingsGoals',
      'investments',
      'recurringBills',
      'transfers',
      'cardPayments',
    ]) {
      final ids = (await household().collection(name).get()).docs.map((d) => d.id);
      expect(ids.where(isDemoId), isEmpty, reason: name);
    }
    final movements = (await household().collection('transactions').get()).docs.map((d) => d.id);
    expect(movements, ['own_tx']);
    expect((await household().collection('accounts').get()).docs.map((d) => d.id), ['own_account']);
    expect((await household().collection('categories').get()).docs.map((d) => d.id), [
      'own_mercado',
    ]);
    final budget = (await household().collection('budgets').doc('2026_10').get()).data()!;
    expect(budget.keys, ['own_mercado']);
  });
}
