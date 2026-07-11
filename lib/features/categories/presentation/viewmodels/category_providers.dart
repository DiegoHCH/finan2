import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/category_model.dart';
import '../../data/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(const []);
  return ref.watch(categoryRepositoryProvider).watchCategories(householdId);
});

class CategoryController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Category category) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final repo = ref.read(categoryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => category.id.isEmpty
          ? repo.createCategory(householdId, category)
          : repo.updateCategory(householdId, category),
    );
  }

  Future<void> delete(String categoryId) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).deleteCategory(
            householdId,
            categoryId,
          ),
    );
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, void>(CategoryController.new);
