import '../../../l10n/l10n.dart';
import 'category_model.dart';

/// What a new household starts with, so the first expense can be logged
/// right away. Icons are slugs from Finan2Icons.categoria and colors come
/// from the swatches in EditCategoryScreen.
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
      color: 0xFF0F9D74,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultFreelance,
      type: CategoryType.ingreso,
      iconSlug: 'freelance',
      color: 0xFF0F9D74,
    ),
    // Facturas
    Category(
      id: '',
      name: l10n.categoriesDefaultRent,
      type: CategoryType.factura,
      iconSlug: 'arriendo',
      color: 0xFF2F7FC8,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultUtilities,
      type: CategoryType.factura,
      iconSlug: 'servicios',
      color: 0xFFC8892F,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultPhoneInternet,
      type: CategoryType.factura,
      iconSlug: 'celular',
      color: 0xFF7C5CE0,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultStreaming,
      type: CategoryType.factura,
      iconSlug: 'streaming',
      color: 0xFFD466A6,
    ),
    // Gastos
    Category(
      id: '',
      name: l10n.categoriesDefaultGroceries,
      type: CategoryType.gasto,
      iconSlug: 'mercado',
      color: 0xFFD4453F,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultTransport,
      type: CategoryType.gasto,
      iconSlug: 'transporte',
      color: 0xFFC8892F,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultRestaurants,
      type: CategoryType.gasto,
      iconSlug: 'restaurante',
      color: 0xFFD466A6,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultLeisure,
      type: CategoryType.gasto,
      iconSlug: 'ocio',
      color: 0xFF7C5CE0,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultHealth,
      type: CategoryType.gasto,
      iconSlug: 'salud',
      color: 0xFF2F7FC8,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultHomeCleaning,
      type: CategoryType.gasto,
      iconSlug: 'hogar_aseo',
      color: 0xFF0F9D74,
    ),
    // Ahorros
    Category(
      id: '',
      name: l10n.categoriesDefaultEmergencyFund,
      type: CategoryType.ahorro,
      iconSlug: 'emergencia',
      color: 0xFFC8892F,
    ),
    Category(
      id: '',
      name: l10n.categoriesDefaultTravel,
      type: CategoryType.ahorro,
      iconSlug: 'viaje',
      color: 0xFF2F7FC8,
    ),
  ];
}
