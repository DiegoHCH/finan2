import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/data/category_repository.dart';
import 'package:finan2/features/categories/data/default_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a new household gets the default categories, attributed to its creator', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = CategoryRepository(firestore: firestore);

    await repository.addDefaults('h1', 'u1');

    final categories = await repository.watchCategories('h1').first;
    expect(categories, hasLength(defaultCategories.length));
    expect(categories.map((c) => c.createdBy).toSet(), {'u1'});
    expect(
      categories.map((c) => c.type).toSet(),
      CategoryType.values.toSet(),
      reason: 'every type has something to pick from',
    );
  });

  test('every default category has a known icon and a unique name', () {
    for (final category in defaultCategories) {
      expect(
        Finan2Icons.categoria(category.iconSlug),
        isNot(Icons.label_outline),
        reason: category.name,
      );
    }
    final names = defaultCategories.map((c) => c.name).toList();
    expect(names.toSet(), hasLength(names.length));
  });
}
