import 'package:flutter/material.dart';

import '../../../core/widgets/finan2_chip.dart';
import '../../../l10n/l10n.dart';
import '../domain/category_type.dart';
import 'screens/edit_category_screen.dart';

/// «+ Nueva» at the end of a list of category chips: opens the category
/// editor right there, so a missing one (mascotas, gimnasio) doesn't send
/// anyone to look for it in Ajustes. [onCreated] gets the new one's ID.
class NewCategoryChip extends StatelessWidget {
  const NewCategoryChip({required this.type, required this.onCreated, super.key});

  final CategoryType type;
  final ValueChanged<String> onCreated;

  @override
  Widget build(BuildContext context) {
    return Finan2Chip(
      key: const Key('newCategoryChip'),
      icon: Icons.add,
      label: context.l10n.categoriesNewChip,
      selected: false,
      onTap: () async {
        final id = await Navigator.of(
          context,
        ).push<String>(MaterialPageRoute(builder: (_) => EditCategoryScreen(initialType: type)));
        if (id != null) onCreated(id);
      },
    );
  }
}
