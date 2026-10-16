import 'package:finan2/core/utils/year_month.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/budget/presentation/viewmodels/budget_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finan2/features/debts/presentation/widgets/debts_section.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/features/plan/presentation/screens/plan_screen.dart';
import 'package:finan2/features/savings_goals/presentation/widgets/goals_section.dart';
import 'package:finan2/features/settings/presentation/screens/settings_screen.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

Future<String> _category(TestApp app, String name) => app.container
    .read(categoryRepositoryProvider)
    .createCategory(
      testHouseholdId,
      Category(id: '', name: name, type: CategoryType.gasto, iconSlug: 'tag', color: 0xFF0F9D74),
    );

void main() {
  testWidgets('Movimientos lists the month and the search narrows it', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      await app.container
          .read(accountControllerProvider.notifier)
          .save(
            const Account(
              id: '',
              name: 'Banco',
              type: AccountType.banco,
              balance: 2000000,
              includeInAvailable: true,
            ),
          );
      final accountId = (await app.first(accountsProvider)).single.id;
      final categoryId = await _category(app, 'Casa');
      for (final (description, amount) in [('Arriendo', 1200000), ('Mercado', 180000)]) {
        await app.container
            .read(transactionControllerProvider.notifier)
            .save(
              Movement(
                id: '',
                amount: amount,
                type: CategoryType.gasto,
                categoryId: categoryId,
                accountId: accountId,
                description: description,
                date: DateTime.now(),
                createdBy: testUid,
              ),
            );
      }
    });

    await pumpScreen(tester, app, const TransactionsScreen());
    expect(find.text('Arriendo'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'arriendo');
    await settle(tester);
    expect(find.text('Arriendo'), findsOneWidget);
    expect(find.text('Mercado'), findsNothing);
  });

  testWidgets('Presupuesto offers to copy last month into an empty one', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final month = currentYearMonth();
    await tester.runAsync(() async {
      final categoryId = await _category(app, 'Mercado');
      await app.container
          .read(budgetControllerProvider.notifier)
          .setCategoryAmount(month.plusMonths(-1), categoryId, 900000);
    });

    await pumpScreen(tester, app, const PlanScreen());
    expect(find.text('Este mes aún no tiene presupuesto'), findsOneWidget);
  });

  testWidgets('Deudas and Metas show their empty states', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const Scaffold(body: DebtsSection()));
    expect(find.text('¡Libres de deudas!'), findsOneWidget);

    await pumpScreen(tester, app, const Scaffold(body: GoalsSection()));
    expect(find.text('Aún no tienes metas'), findsOneWidget);
  });

  testWidgets('a phone in English gets the English texts', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const Scaffold(body: DebtsSection()), locale: const Locale('en'));

    expect(find.text('Debt-free!'), findsOneWidget);
  });

  testWidgets('Inicio and Ajustes open on an empty household', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final household = app.container.read(currentHouseholdProvider).requireValue!;

    await pumpScreen(tester, app, DashboardScreen(household: household));
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, app, SettingsScreen(household: household));
    expect(tester.takeException(), isNull);
    expect(find.text('Casa'), findsWidgets);
  });
}
