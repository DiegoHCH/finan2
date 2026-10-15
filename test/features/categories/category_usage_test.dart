import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/categories/data/category_repository.dart';
import 'package:finan2/features/categories/data/category_usage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  const householdId = 'h1';
  late FakeFirebaseFirestore firestore;
  late CategoryRepository repository;

  CollectionReference<Map<String, dynamic>> col(String name) =>
      firestore.collection('households/$householdId/$name');

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = CategoryRepository(firestore: firestore);
  });

  test('counts movements and recurring bills filed under a category', () async {
    await col('transactions').add({'categoryId': 'mercado'});
    await col('transactions').add({'categoryId': 'mercado'});
    await col('transactions').add({'categoryId': 'ocio'});
    await col('recurringBills').add({'categoryId': 'mercado'});

    final usage = await repository.usage(householdId, 'mercado');

    expect(usage.movements, 2);
    expect(usage.recurringBills, 1);
    expect(usage.describe(), '2 movimientos y 1 factura recurrente');
    expect((await repository.usage(householdId, 'salud')).isEmpty, isTrue);
  });

  test('reassigning moves every movement and bill to the new category', () async {
    await col('transactions').add({'categoryId': 'mercado', 'description': 'Éxito'});
    await col('recurringBills').add({'categoryId': 'mercado'});
    await col('transactions').add({'categoryId': 'ocio'});

    await repository.reassign(householdId, fromId: 'mercado', toId: 'hogar');

    expect((await repository.usage(householdId, 'mercado')).isEmpty, isTrue);
    final moved = await repository.usage(householdId, 'hogar');
    expect(moved.movements, 1);
    expect(moved.recurringBills, 1);
    expect((await repository.usage(householdId, 'ocio')).movements, 1);
  });

  test('deleting a category drops its planned amount from every month', () async {
    await col('categories').doc('mercado').set({'name': 'Mercado'});
    await col('budgets').doc('2026_7').set({'mercado': 'x', 'ocio': 'y'});
    await col('budgets').doc('2026_8').set({'ocio': 'z'});

    await repository.deleteCategory(householdId, 'mercado');

    expect((await col('categories').doc('mercado').get()).exists, isFalse);
    expect((await col('budgets').doc('2026_7').get()).data(), {'ocio': 'y'});
    expect((await col('budgets').doc('2026_8').get()).data(), {'ocio': 'z'});
  });

  test('describe uses singular and plural', () {
    expect(const CategoryUsage(movements: 1, recurringBills: 0).describe(), '1 movimiento');
    expect(
      const CategoryUsage(movements: 0, recurringBills: 2).describe(),
      '2 facturas recurrentes',
    );
  });

  test('describe follows the app language', () {
    Intl.defaultLocale = 'en';
    addTearDown(() => Intl.defaultLocale = 'es');
    expect(
      const CategoryUsage(movements: 2, recurringBills: 1).describe(),
      '2 transactions and 1 recurring bill',
    );
  });
}
