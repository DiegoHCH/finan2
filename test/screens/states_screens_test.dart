import 'dart:async';

import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/core/utils/year_month.dart';
import 'package:finan2/core/widgets/finan2_skeleton.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/connection/presentation/viewmodels/connection_providers.dart';
import 'package:finan2/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finan2/features/household/data/household_model.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/features/household/presentation/viewmodels/member_providers.dart';
import 'package:finan2/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:finan2/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

const _household = Household(
  id: testHouseholdId,
  name: 'Casa Hoyos',
  members: [testUid, 'u2'],
  memberInfo: {
    testUid: HouseholdMemberInfo(name: 'Diego Hoyos'),
    'u2': HouseholdMemberInfo(name: 'Vale'),
  },
  currency: 'COP',
  startYear: 2026,
  weekStartsOn: 'monday',
);

/// [app]'s household seen through [overrides] - a state the fake Firestore
/// can't produce on its own (offline, no key, never answering).
Future<ProviderContainer> _scope(TestApp app, List<Override> overrides) async {
  final container = ProviderContainer(
    parent: app.container,
    overrides: [
      currentHouseholdProvider.overrideWith((ref) => Stream.value(_household)),
      // Read from this scope's household, not the parent's.
      memberLabelProvider.overrideWith((ref) {
        final household = ref.watch(currentHouseholdProvider).value;
        return (uid) => MemberLabel(
          name: household?.memberInfo[uid]?.name ?? '?',
          index: (household?.members.indexOf(uid) ?? 0).clamp(0, 1),
        );
      }),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  container.listen(currentHouseholdProvider, (_, _) {});
  await container.read(currentHouseholdProvider.future);
  return container;
}

/// Unmounts before the scope goes, so its providers' disposal isn't left
/// as a pending timer.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
}

Future<void> _pump(WidgetTester tester, ProviderContainer container, Widget screen) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: Finan2Theme.light,
        locale: const Locale('es'),
        supportedLocales: supportedAppLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  );
  await settle(tester);
}

String _monthTitle(YearMonth month) =>
    month.year == DateTime.now().year ? month.monthLabel : month.label;

void main() {
  testWidgets('an empty Movimientos is a blank page, with the month before one tap away', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await pumpScreen(tester, app, const TransactionsScreen());

    final month = currentYearMonth();
    expect(find.text('${_monthTitle(month)} está en blanco.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Anotar el primero'), findsOneWidget);

    final previous = month.plusMonths(-1);
    final previousName = DateFormat.MMMM('es').format(DateTime(previous.year, previous.month));
    await tester.tap(find.text('Ver $previousName'));
    await settle(tester);
    expect(find.text('${_monthTitle(previous)} está en blanco.'), findsOneWidget);
  });

  testWidgets('while amounts load, Movimientos and Inicio show their shape, not a spinner', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final never = StreamController<List<Movement>>.broadcast();
    addTearDown(never.close);
    final container = (await tester.runAsync(
      () => _scope(app, [
        transactionsOfMonthProvider.overrideWith((ref, month) => never.stream),
        transactionsForMonthProvider.overrideWith((ref) => never.stream),
      ]),
    ))!;

    await _pump(tester, container, const TransactionsScreen());
    expect(find.byType(Finan2SkeletonRow), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await _pump(tester, container, const DashboardScreen(household: _household));
    expect(find.byType(Finan2SkeletonRow), findsWidgets);
    expect(find.text('Descifrando los montos en este teléfono…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await _unmount(tester);
  });

  testWidgets('without the key, Inicio says what is missing and the two ways to get it', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final container = (await tester.runAsync(
      () => _scope(app, [householdHasKeyProvider.overrideWith((ref, id) async => false)]),
    ))!;

    await _pump(tester, container, const DashboardScreen(household: _household));

    expect(find.text('Este teléfono no tiene la llave de la casa.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Pedirle el código a Vale'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Usar la frase de 12 palabras'));
    await settle(tester);
    expect(find.text('Frase de recuperación'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('a list that cannot decrypt shows the missing key, not the error', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final container = (await tester.runAsync(
      () => _scope(app, [
        transactionsOfMonthProvider.overrideWith(
          (ref, month) => Stream.error(const Finan2CryptoException('sin llave')),
        ),
      ]),
    ))!;

    await _pump(tester, container, const TransactionsScreen());

    expect(find.text('Este teléfono no tiene la llave de la casa.'), findsOneWidget);
    expect(find.text('sin llave'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('offline, a calm line says so and an unconfirmed movement is «por enviar»', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final id = (await tester.runAsync(() async {
      await app.container
          .read(accountControllerProvider.notifier)
          .save(
            const Account(
              id: '',
              name: 'Banco',
              type: AccountType.banco,
              balance: 500000,
              includeInAvailable: true,
            ),
          );
      final accountId = (await app.first(accountsProvider)).single.id;
      final categoryId = await app.container
          .read(categoryRepositoryProvider)
          .createCategory(
            testHouseholdId,
            const Category(
              id: '',
              name: 'Ocio',
              type: CategoryType.gasto,
              iconSlug: 'ocio',
              color: 0xFFDB2777,
            ),
          );
      await app.container
          .read(transactionControllerProvider.notifier)
          .save(
            Movement(
              id: '',
              amount: 24000,
              type: CategoryType.gasto,
              categoryId: categoryId,
              accountId: accountId,
              description: 'Helados',
              date: DateTime.now(),
              createdBy: testUid,
            ),
          );
      return (await app.first(transactionsForMonthProvider)).single.id;
    }))!;
    final container = (await tester.runAsync(
      () => _scope(app, [
        offlineProvider.overrideWith((ref) => Stream.value(true)),
        unsyncedMovementIdsProvider.overrideWith((ref, month) => Stream.value({id})),
      ]),
    ))!;

    await _pump(tester, container, const TransactionsScreen());
    expect(find.textContaining('Sin conexión.'), findsOneWidget);
    expect(find.text('por enviar'), findsOneWidget);

    await _pump(tester, container, const EditTransactionScreen());
    expect(find.textContaining('Sin conexión.'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('online, there is no offline line', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final container = (await tester.runAsync(
      () => _scope(app, [offlineProvider.overrideWith((ref) => Stream.value(false))]),
    ))!;

    await _pump(tester, container, const TransactionsScreen());
    expect(find.textContaining('Sin conexión.'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('no notices is good news, with no hurry to set them', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await pumpScreen(tester, app, const NotificationsScreen());

    expect(find.text('Todo tranquilo.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Elegir qué avisar'), findsOneWidget);
  });
}
