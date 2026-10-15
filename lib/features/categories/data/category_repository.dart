import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_model.dart';
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

  Future<void> deleteCategory(String householdId, String categoryId) {
    return _categories(householdId).doc(categoryId).delete();
  }
}
