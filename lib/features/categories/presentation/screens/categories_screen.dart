import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_empty_state.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../data/category_model.dart';
import '../viewmodels/category_providers.dart';
import 'edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? const [];
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    return Scaffold(
      floatingActionButton: categories.isEmpty
          ? null
          : FloatingActionButton(
              heroTag: 'categoriesFab',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const EditCategoryScreen()),
              ),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Categorías',
              title: '${categories.length} activa${categories.length == 1 ? '' : 's'}',
              showBackButton: true,
            ),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (categories) {
                  if (categories.isEmpty) {
                    return Finan2EmptyState(
                      icon: Icons.sell_outlined,
                      title: 'Aún no hay categorías',
                      description:
                          'Crea tu primera categoría para poder registrar '
                          'movimientos.',
                      actionLabel: '+ Nueva categoría',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditCategoryScreen(),
                        ),
                      ),
                    );
                  }
                  final byType = <CategoryType, List<Category>>{};
                  for (final category in categories) {
                    byType.putIfAbsent(category.type, () => []).add(category);
                  }
                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      for (final type in CategoryType.values)
                        if (byType[type]?.isNotEmpty ?? false) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              type.plural.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: colors.inkFaint,
                              ),
                            ),
                          ),
                          Finan2ListCard(
                            children: [
                              for (final category in byType[type]!)
                                Finan2ListRow(
                                  icon: Finan2Icons.categoria(category.iconSlug),
                                  label: category.name,
                                  iconBackground: Color(
                                    category.color,
                                  ).withValues(alpha: 0.14),
                                  iconColor: Color(category.color),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EditCategoryScreen(
                                        category: category,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: Finan2Space.lg),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
