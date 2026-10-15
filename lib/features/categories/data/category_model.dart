import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../l10n/l10n.dart';
import '../domain/category_type.dart';

export '../domain/category_type.dart';

extension CategoryTypeLabel on CategoryType {
  /// In the app's language - see currentL10n.
  String get label => switch (this) {
    CategoryType.ingreso => currentL10n.categoriesTypeIncome,
    CategoryType.factura => currentL10n.categoriesTypeBill,
    CategoryType.gasto => currentL10n.categoriesTypeExpense,
    CategoryType.ahorro => currentL10n.categoriesTypeSavings,
  };

  String get plural => switch (this) {
    CategoryType.ingreso => currentL10n.categoriesTypeIncomePlural,
    CategoryType.factura => currentL10n.categoriesTypeBillPlural,
    CategoryType.gasto => currentL10n.categoriesTypeExpensePlural,
    CategoryType.ahorro => currentL10n.categoriesTypeSavingsPlural,
  };

  static CategoryType fromName(String name) =>
      CategoryType.values.firstWhere((t) => t.name == name, orElse: () => CategoryType.gasto);
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconSlug,
    required this.color,
    this.rollover = false,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final CategoryType type;
  final String iconSlug;
  final int color; // ARGB, matches Color(...).toARGB32()

  /// Whether what's left (or overspent) of this category's budget carries
  /// into the next month - see computeCarryOver.
  final bool rollover;
  final String createdBy;

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Category(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: CategoryTypeLabel.fromName(data['type'] as String? ?? 'gasto'),
      iconSlug: data['icon'] as String? ?? 'label',
      color: data['color'] as int? ?? 0xFF0F9D74,
      rollover: data['rollover'] as bool? ?? false,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'icon': iconSlug,
      'color': color,
      'rollover': rollover,
      'createdBy': createdBy,
    };
  }
}
