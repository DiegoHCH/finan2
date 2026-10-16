import 'package:finan2/core/utils/year_month.dart';
import 'package:finan2/core/widgets/finan2_chip.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/budget/presentation/viewmodels/budget_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:finan2/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:finan2/features/transfers/presentation/viewmodels/transfer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

Future<String> _account(TestApp app, String name, int balance) async {
  await app.container
      .read(accountControllerProvider.notifier)
      .save(
        Account(
          id: '',
          name: name,
          type: AccountType.banco,
          balance: balance,
          includeInAvailable: true,
        ),
      );
  return (await app.first(accountsProvider)).firstWhere((a) => a.name == name).id;
}

Future<String> _category(TestApp app, String name) => app.container
    .read(categoryRepositoryProvider)
    .createCategory(
      testHouseholdId,
      Category(id: '', name: name, type: CategoryType.gasto, iconSlug: 'tag', color: 0xFF0F766E),
    );

Future<void> _movement(
  TestApp app, {
  required String description,
  required int amount,
  required String categoryId,
  required String accountId,
  DateTime? date,
}) => app.container
    .read(transactionControllerProvider.notifier)
    .save(
      Movement(
        id: '',
        amount: amount,
        type: CategoryType.gasto,
        categoryId: categoryId,
        accountId: accountId,
        description: description,
        date: date ?? DateTime.now(),
        createdBy: testUid,
      ),
    );

void main() {
  testWidgets('Movimientos groups the month by day, each with its net', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final now = DateTime.now();
    // Another day of this same month - tomorrow's if today is the 1st.
    final otherDay = DateTime(now.year, now.month, now.day == 1 ? 2 : 1);
    await tester.runAsync(() async {
      final account = await _account(app, 'Banco', 2000000);
      final casa = await _category(app, 'Casa');
      await _movement(
        app,
        description: 'Arriendo',
        amount: 1200000,
        categoryId: casa,
        accountId: account,
      );
      await _movement(app, description: 'Gas', amount: 30000, categoryId: casa, accountId: account);
      await _movement(
        app,
        description: 'Pintura',
        amount: 80000,
        categoryId: casa,
        accountId: account,
        date: otherDay,
      );
    });

    await pumpScreen(tester, app, const TransactionsScreen());

    expect(find.textContaining('HOY · '), findsOneWidget);
    expect(find.text(r'−$1.230.000'), findsOneWidget);
    expect(find.text(r'−$80.000'), findsWidgets);
    expect(find.text('Arriendo'), findsOneWidget);
    expect(find.text('Pintura'), findsOneWidget);
  });

  testWidgets('a filter shows as a colored chip that comes off with its ✕', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      final account = await _account(app, 'Banco', 2000000);
      final casa = await _category(app, 'Casa');
      final ocio = await _category(app, 'Ocio');
      await _movement(
        app,
        description: 'Arriendo',
        amount: 1200000,
        categoryId: casa,
        accountId: account,
      );
      await _movement(
        app,
        description: 'Cine',
        amount: 40000,
        categoryId: ocio,
        accountId: account,
      );
    });

    await pumpScreen(tester, app, const TransactionsScreen());
    await tester.tap(find.byTooltip('Filtros'));
    await settle(tester);
    await tester.tap(find.text('Ocio').last);
    await tester.pump();
    // «Ver N» says how many the chosen filters leave.
    await tester.tap(find.text('Ver 1'));
    await settle(tester);

    expect(find.text('Cine'), findsOneWidget);
    expect(find.text('Arriendo'), findsNothing);
    final chip = find.widgetWithIcon(Finan2Chip, Icons.close);
    expect(chip, findsOneWidget);
    expect(find.text(r'1 movimiento · −$40.000'), findsOneWidget);

    await tester.tap(chip);
    await settle(tester);
    expect(find.text('Arriendo'), findsOneWidget);
    expect(find.widgetWithIcon(Finan2Chip, Icons.close), findsNothing);

    // A search can widen to the whole year.
    await tester.enterText(find.byType(TextField).first, 'cine');
    await settle(tester);
    expect(find.text('Todo ${DateTime.now().year}'), findsOneWidget);
  });

  testWidgets('a movement opens its detail and deleting it offers «Deshacer»', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      final account = await _account(app, 'Banco', 2000000);
      final casa = await _category(app, 'Casa');
      await _movement(
        app,
        description: 'Arriendo',
        amount: 1200000,
        categoryId: casa,
        accountId: account,
      );
    });

    await pumpScreen(tester, app, const TransactionsScreen());
    await tester.tap(find.text('Arriendo'));
    await settle(tester);

    // Who paid and who logged it, both.
    expect(find.text('Pagó'), findsOneWidget);
    expect(find.text('Lo anotó'), findsOneWidget);
    expect(find.text('Diego'), findsNWidgets(2));

    await tester.tap(find.text('Borrar movimiento'));
    await settle(tester);
    expect(find.text('Arriendo'), findsNothing);
    await tester.tap(find.text('Deshacer'));
    await settle(tester);
    expect(find.text('Arriendo'), findsOneWidget);
    expect((await tester.runAsync(() => app.first(transactionsForMonthProvider)))!, hasLength(1));
  });

  testWidgets('«Pasar» inside Anotar moves money between two accounts', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      await _account(app, 'Banco', 1000000);
      await _account(app, 'Efectivo', 100000);
    });

    await pumpScreen(tester, app, const EditTransactionScreen());
    await tester.tap(find.text('Pasar'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '250000');
    await tester.pump();

    // What each balance will be left with, and that it isn't an expense.
    expect(find.text('queda \$750k'), findsOneWidget);
    expect(find.text('queda \$350k'), findsOneWidget);
    expect(find.text('No es un gasto: no toca el presupuesto.'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await settle(tester);

    final transfers = (await tester.runAsync(() => app.first(transfersProvider)))!;
    expect(transfers.single.amount, 250000);
    final balances = {
      for (final a in (await tester.runAsync(() => app.first(accountsProvider)))!)
        a.name: a.balance,
    };
    expect(balances['Banco']! + balances['Efectivo']!, 1100000);
    expect(balances.values, containsAll([350000, 750000]));
  });

  testWidgets('Anotar says what is missing in a sheet, not a snackbar', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const EditTransactionScreen());
    await tester.tap(find.text('Guardar'));
    await settle(tester);

    expect(find.text('Falta un dato'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Inicio answers how much of the plan is left', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      final account = await _account(app, 'Banco', 2000000);
      final casa = await _category(app, 'Casa');
      await app.container
          .read(budgetControllerProvider.notifier)
          .setCategoryAmount(currentYearMonth(), casa, 1000000);
      await _movement(
        app,
        description: 'Arriendo',
        amount: 300000,
        categoryId: casa,
        accountId: account,
      );
    });
    final household = app.container.read(currentHouseholdProvider).requireValue!;

    await pumpScreen(tester, app, DashboardScreen(household: household));

    expect(find.textContaining('Les queda del plan de'), findsOneWidget);
    expect(find.text('Hola, Diego'), findsOneWidget);
    expect(find.text('Arriendo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
