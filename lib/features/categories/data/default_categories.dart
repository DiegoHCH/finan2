import '../../../l10n/l10n.dart';
import 'category_model.dart';

/// What a new household starts with, so the first expense can be logged
/// right away. Icons are slugs from Finan2Icons.categoria and colors come
/// from Finan2Palette.categorySwatches.
///
/// Names are stored as data, so they're written in the language of the
/// phone that creates the household and stay that way after.
List<Category> get defaultCategories {
  final l10n = currentL10n;
  return [
    // Ingresos
    Category(
      id: '',
      name: l10n.categoriesDefaultSalary,
      type: CategoryType.ingreso,
      iconSlug: 'salario',
      color: 0xFF16A34A,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultFreelance,
      type: CategoryType.ingreso,
      iconSlug: 'freelance',
      color: 0xFF16A34A,
    ),
    // Facturas
    Category(
      id: '',
      name: l10n.categoriesDefaultRent,
      type: CategoryType.factura,
      iconSlug: 'arriendo',
      color: 0xFF0F766E,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultUtilities,
      type: CategoryType.factura,
      iconSlug: 'servicios',
      color: 0xFF475569,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultPhoneInternet,
      type: CategoryType.factura,
      iconSlug: 'celular',
      color: 0xFF0284C7,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultStreaming,
      type: CategoryType.factura,
      iconSlug: 'streaming',
      color: 0xFFDB2777,
    ),
    // Gastos
    Category(
      id: '',
      name: l10n.categoriesDefaultGroceries,
      type: CategoryType.gasto,
      iconSlug: 'mercado',
      color: 0xFF65A30D,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultTransport,
      type: CategoryType.gasto,
      iconSlug: 'transporte',
      color: 0xFFB45309,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultRestaurants,
      type: CategoryType.gasto,
      iconSlug: 'restaurante',
      color: 0xFFEA580C,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultLeisure,
      type: CategoryType.gasto,
      iconSlug: 'ocio',
      color: 0xFFDB2777,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultHealth,
      type: CategoryType.gasto,
      iconSlug: 'salud',
      color: 0xFFDC2626,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultHomeCleaning,
      type: CategoryType.gasto,
      iconSlug: 'hogar_aseo',
      color: 0xFF0F766E,
    ),
    // Ahorros
    Category(
      id: '',
      name: l10n.categoriesDefaultEmergencyFund,
      type: CategoryType.ahorro,
      iconSlug: 'emergencia',
      color: 0xFF16A34A,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultTravel,
      type: CategoryType.ahorro,
      iconSlug: 'viaje',
      color: 0xFF7C3AED,
    ),
  ];
}
