import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_model.dart';
import 'category_usage.dart';
import 'default_categories.dart';

class CategoryRepository {
  CategoryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _categories(String householdId) =>
      _db.collection('households').doc(householdId).collection('categories');

  Stream<List<Category>> watchCategories(String householdId) {
    return _categories(householdId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Category.fromFirestore).toList(),
        );
  }

  /// Returns the new category's generated ID.
  Future<String> createCategory(String householdId, Category category) async {
    final doc = await _categories(householdId).add(category.toFirestore());
    return doc.id;
  }

  /// Adds [defaultCategories] to a new household, attributed to [uid].
  Future<void> addDefaults(String householdId, String uid) {
    final batch = _db.batch();
    for (final category in defaultCategories) {
      batch.set(_categories(householdId).doc(), {
        ...category.toFirestore(),
        'createdBy': uid,
      });
    }
    return batch.commit();
  }

  Future<void> updateCategory(String householdId, Category category) {
    return _categories(householdId)
        .doc(category.id)
        .update(category.toFirestore());
  }

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  /// Movements and recurring bills still filed under [categoryId].
  Future<CategoryUsage> usage(String householdId, String categoryId) async {
    final household = _household(householdId);
    final movements = await household
        .collection('transactions')
        .where('categoryId', isEqualTo: categoryId)
        .count()
        .get();
    final bills = await household
        .collection('recurringBills')
        .where('categoryId', isEqualTo: categoryId)
        .count()
        .get();
    return CategoryUsage(
      movements: movements.count ?? 0,
      recurringBills: bills.count ?? 0,
    );
  }

  /// Files everything under [fromId] under [toId] instead. Only the
  /// category changes, so no balance moves.
  Future<void> reassign(String householdId, {required String fromId, required String toId}) async {
    final household = _household(householdId);
    for (final collection in const ['transactions', 'recurringBills']) {
      while (true) {
        final page = await household
            .collection(collection)
            .where('categoryId', isEqualTo: fromId)
            .limit(400)
            .get();
        if (page.docs.isEmpty) break;
        final batch = _db.batch();
        for (final doc in page.docs) {
          batch.update(doc.reference, {'categoryId': toId});
        }
        await batch.commit();
      }
    }
  }

  /// Deletes the category and its planned amount in every month's budget -
  /// left behind, those amounts would still count toward the totals with
  /// no category to show them under.
  Future<void> deleteCategory(String householdId, String categoryId) async {
    final budgets = await _household(householdId).collection('budgets').get();
    final batch = _db.batch();
    for (final doc in budgets.docs) {
      if (doc.data().containsKey(categoryId)) {
        batch.update(doc.reference, {categoryId: FieldValue.delete()});
      }
    }
    batch.delete(_categories(householdId).doc(categoryId));
    await batch.commit();
  }
}
