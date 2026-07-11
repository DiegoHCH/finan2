import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/accounts/data/account_model.dart';
import '../../features/accounts/presentation/viewmodels/account_providers.dart';
import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/categories/data/category_model.dart';
import '../../features/categories/presentation/viewmodels/category_providers.dart';
import '../../features/household/presentation/viewmodels/household_providers.dart';
import '../../features/transactions/data/transaction_model.dart';
import '../../features/transactions/presentation/viewmodels/transaction_providers.dart';

/// Dev-only helper: fills the current household with realistic sample
/// categories, accounts and movimientos (matching the design mockup's own
/// sample data) so every screen has something to show. Safe to run more
/// than once - it just adds more sample docs each time.
class MockDataSeeder {
  const MockDataSeeder(this.ref);

  final WidgetRef ref;

  Future<void> seed() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final household = ref.read(currentHouseholdProvider).value;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) {
      throw StateError('No hay un hogar o usuario activo.');
    }

    final categoryRepo = ref.read(categoryRepositoryProvider);
    final accountRepo = ref.read(accountRepositoryProvider);
    final transactionRepo = ref.read(transactionRepositoryProvider);

    final categoryIds = <String, String>{};
    for (final c in _mockCategories) {
      categoryIds[c.name] = await categoryRepo.createCategory(householdId, c);
    }

    final accountIds = <String, String>{};
    for (final a in _mockAccounts) {
      accountIds[a.name] = await accountRepo.createAccount(householdId, a);
    }

    final members = household?.members ?? const <String>[];
    final now = DateTime.now();
    String creatorFor(int i) =>
        members.isNotEmpty ? members[i % members.length] : uid;

    final movements = <Movement>[
      Movement(
        id: '',
        amount: 3400000,
        type: CategoryType.ingreso,
        categoryId: categoryIds['Salario']!,
        accountId: accountIds['Bancolombia']!,
        description: 'Salario',
        date: now.subtract(const Duration(days: 5)),
        createdBy: creatorFor(0),
      ),
      Movement(
        id: '',
        amount: 1300000,
        type: CategoryType.factura,
        categoryId: categoryIds['Arriendo']!,
        accountId: accountIds['Bancolombia']!,
        description: 'Arriendo',
        date: now.subtract(const Duration(days: 10)),
        createdBy: creatorFor(1),
      ),
      Movement(
        id: '',
        amount: 500000,
        type: CategoryType.ahorro,
        categoryId: categoryIds['Viaje']!,
        accountId: accountIds['Bancolombia']!,
        description: 'Aporte fondo viaje',
        date: now.subtract(const Duration(days: 6)),
        createdBy: creatorFor(0),
      ),
      Movement(
        id: '',
        amount: 318000,
        type: CategoryType.gasto,
        categoryId: categoryIds['Mercado']!,
        accountId: accountIds['Efectivo']!,
        description: 'Mercado Éxito',
        date: now.subtract(const Duration(days: 3)),
        createdBy: creatorFor(1),
      ),
      Movement(
        id: '',
        amount: 210000,
        type: CategoryType.gasto,
        categoryId: categoryIds['Transporte']!,
        accountId: accountIds['Efectivo']!,
        description: 'Gasolina',
        date: now.subtract(const Duration(days: 2)),
        createdBy: creatorFor(0),
      ),
      Movement(
        id: '',
        amount: 185000,
        type: CategoryType.gasto,
        categoryId: categoryIds['Ocio']!,
        accountId: accountIds['Nequi']!,
        description: 'Cine + cena',
        date: now.subtract(const Duration(days: 1)),
        createdBy: creatorFor(1),
      ),
    ];

    for (final m in movements) {
      await transactionRepo.createTransaction(householdId, m);
    }
  }
}

final _mockCategories = [
  const Category(
    id: '',
    name: 'Salario',
    type: CategoryType.ingreso,
    iconSlug: 'salario',
    color: 0xFF0F9D74,
  ),
  const Category(
    id: '',
    name: 'Arriendo',
    type: CategoryType.factura,
    iconSlug: 'arriendo',
    color: 0xFF2F7FC8,
  ),
  const Category(
    id: '',
    name: 'Mercado',
    type: CategoryType.gasto,
    iconSlug: 'mercado',
    color: 0xFFD4453F,
  ),
  const Category(
    id: '',
    name: 'Transporte',
    type: CategoryType.gasto,
    iconSlug: 'transporte',
    color: 0xFFC8892F,
  ),
  const Category(
    id: '',
    name: 'Ocio',
    type: CategoryType.gasto,
    iconSlug: 'ocio',
    color: 0xFF7C5CE0,
  ),
  const Category(
    id: '',
    name: 'Viaje',
    type: CategoryType.ahorro,
    iconSlug: 'viaje',
    color: 0xFFD466A6,
  ),
];

final _mockAccounts = [
  const Account(
    id: '',
    name: 'Bancolombia',
    type: AccountType.banco,
    balance: 4850000,
    includeInAvailable: true,
  ),
  const Account(
    id: '',
    name: 'Efectivo',
    type: AccountType.efectivo,
    balance: 320000,
    includeInAvailable: true,
  ),
  const Account(
    id: '',
    name: 'Nequi',
    type: AccountType.billetera,
    balance: 180000,
    includeInAvailable: true,
  ),
];
