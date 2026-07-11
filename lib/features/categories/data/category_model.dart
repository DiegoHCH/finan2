import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches the Firestore schema's `type` field for categories/transactions.
enum CategoryType { ingreso, factura, gasto, ahorro }

extension CategoryTypeLabel on CategoryType {
  String get label => switch (this) {
        CategoryType.ingreso => 'Ingreso',
        CategoryType.factura => 'Factura',
        CategoryType.gasto => 'Gasto',
        CategoryType.ahorro => 'Ahorro',
      };

  String get plural => switch (this) {
        CategoryType.ingreso => 'Ingresos',
        CategoryType.factura => 'Facturas',
        CategoryType.gasto => 'Gastos',
        CategoryType.ahorro => 'Ahorros',
      };

  static CategoryType fromName(String name) => CategoryType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => CategoryType.gasto,
      );
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconSlug,
    required this.color,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final CategoryType type;
  final String iconSlug;
  final int color; // ARGB, matches Color(...).toARGB32()
  final String createdBy;

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Category(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: CategoryTypeLabel.fromName(data['type'] as String? ?? 'gasto'),
      iconSlug: data['icon'] as String? ?? 'label',
      color: data['color'] as int? ?? 0xFF0F9D74,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'icon': iconSlug,
      'color': color,
      'createdBy': createdBy,
    };
  }
}
