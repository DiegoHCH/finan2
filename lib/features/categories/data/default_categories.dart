import 'category_model.dart';

/// What a new household starts with, so the first expense can be logged
/// right away. Icons are slugs from Finan2Icons.categoria and colors come
/// from the swatches in EditCategoryScreen.
const defaultCategories = [
  // Ingresos
  Category(
    id: '',
    name: 'Salario',
    type: CategoryType.ingreso,
    iconSlug: 'salario',
    color: 0xFF0F9D74,
  ),
  Category(
    id: '',
    name: 'Freelance',
    type: CategoryType.ingreso,
    iconSlug: 'freelance',
    color: 0xFF0F9D74,
  ),
  // Facturas
  Category(
    id: '',
    name: 'Arriendo',
    type: CategoryType.factura,
    iconSlug: 'arriendo',
    color: 0xFF2F7FC8,
  ),
  Category(
    id: '',
    name: 'Servicios',
    type: CategoryType.factura,
    iconSlug: 'servicios',
    color: 0xFFC8892F,
  ),
  Category(
    id: '',
    name: 'Celular e internet',
    type: CategoryType.factura,
    iconSlug: 'celular',
    color: 0xFF7C5CE0,
  ),
  Category(
    id: '',
    name: 'Streaming',
    type: CategoryType.factura,
    iconSlug: 'streaming',
    color: 0xFFD466A6,
  ),
  // Gastos
  Category(
    id: '',
    name: 'Mercado',
    type: CategoryType.gasto,
    iconSlug: 'mercado',
    color: 0xFFD4453F,
  ),
  Category(
    id: '',
    name: 'Transporte',
    type: CategoryType.gasto,
    iconSlug: 'transporte',
    color: 0xFFC8892F,
  ),
  Category(
    id: '',
    name: 'Restaurantes',
    type: CategoryType.gasto,
    iconSlug: 'restaurante',
    color: 0xFFD466A6,
  ),
  Category(id: '', name: 'Ocio', type: CategoryType.gasto, iconSlug: 'ocio', color: 0xFF7C5CE0),
  Category(id: '', name: 'Salud', type: CategoryType.gasto, iconSlug: 'salud', color: 0xFF2F7FC8),
  Category(
    id: '',
    name: 'Hogar y aseo',
    type: CategoryType.gasto,
    iconSlug: 'hogar_aseo',
    color: 0xFF0F9D74,
  ),
  // Ahorros
  Category(
    id: '',
    name: 'Fondo de emergencia',
    type: CategoryType.ahorro,
    iconSlug: 'emergencia',
    color: 0xFFC8892F,
  ),
  Category(id: '', name: 'Viaje', type: CategoryType.ahorro, iconSlug: 'viaje', color: 0xFF2F7FC8),
];
