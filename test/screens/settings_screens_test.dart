import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:finan2/features/backup/presentation/screens/backup_screen.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/presentation/screens/categories_screen.dart';
import 'package:finan2/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/export/presentation/screens/export_screen.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/features/investments/presentation/screens/investments_screen.dart';
import 'package:finan2/features/monthly_notes/presentation/screens/monthly_notes_screen.dart';
import 'package:finan2/features/monthly_notes/presentation/viewmodels/monthly_notes_providers.dart';
import 'package:finan2/features/notification_prefs/presentation/screens/notification_preferences_screen.dart';
import 'package:finan2/features/notifications/domain/entities/household_notification.dart';
import 'package:finan2/features/notifications/domain/notification_subject.dart';
import 'package:finan2/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:finan2/features/notifications/presentation/viewmodels/notification_providers.dart';
import 'package:finan2/features/recurring_bills/domain/entities/recurring_bill.dart';
import 'package:finan2/features/recurring_bills/presentation/screens/edit_recurring_bill_screen.dart';
import 'package:finan2/features/recurring_bills/presentation/screens/recurring_bills_screen.dart';
import 'package:finan2/features/recurring_bills/presentation/viewmodels/recurring_bill_providers.dart';
import 'package:finan2/features/settings/presentation/screens/account_settings_screen.dart';
import 'package:finan2/features/settings/presentation/screens/financial_settings_screen.dart';
import 'package:finan2/features/settings/presentation/screens/settings_screen.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

Future<String> _category(TestApp app, String name, CategoryType type, {bool rollover = false}) =>
    app.container
        .read(categoryRepositoryProvider)
        .createCategory(
          testHouseholdId,
          Category(
            id: '',
            name: name,
            type: type,
            iconSlug: 'mercado',
            color: 0xFF65A30D,
            rollover: rollover,
          ),
        );

Future<void> _movement(TestApp app, String categoryId, DateTime date) => app.container
    .read(transactionControllerProvider.notifier)
    .save(
      Movement(
        id: '',
        amount: 10000,
        type: CategoryType.gasto,
        categoryId: categoryId,
        accountId: 'a',
        description: 'Mercado',
        date: date,
        createdBy: testUid,
      ),
    );

RecurringBill _bill(
  String name, {
  String categoryId = 'c',
  RecurringFrequency frequency = RecurringFrequency.monthly,
  int amount = 100000,
  DateTime? start,
  DateTime? end,
  bool paused = false,
}) => RecurringBill(
  id: '',
  name: name,
  type: CategoryType.factura,
  categoryId: categoryId,
  accountId: 'a',
  amount: amount,
  dayOfMonth: start?.day ?? 5,
  frequency: frequency,
  startDate: start,
  endDate: end,
  paused: paused,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('every destination of Ajustes opens from its row', (tester) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = (await tester.runAsync(TestApp.start))!;
    final household = app.container.read(currentHouseholdProvider).requireValue!;

    for (final (label, screen) in [
      ('Cuentas y tarjetas', AccountsScreen),
      ('Categorías', CategoriesScreen),
      ('Fijos', RecurringBillsScreen),
      ('Inversiones', InvestmentsScreen),
      ('Avisos', NotificationsScreen),
      ('Exportar', ExportScreen),
      ('Copia y llave', BackupScreen),
      ('Moneda y año', FinancialSettingsScreen),
      ('Tu cuenta', AccountSettingsScreen),
    ]) {
      // A fresh tree, so the last row's screen isn't still on top.
      await tester.pumpWidget(const SizedBox());
      await pumpScreen(tester, app, SettingsScreen(household: household));
      await tester.tap(find.text(label));
      await settle(tester);
      expect(find.byType(screen), findsOneWidget, reason: label);
    }

    await tester.pumpWidget(const SizedBox());
    await pumpScreen(tester, app, SettingsScreen(household: household));
    // Alone in the household: the second place and a row invite someone.
    expect(find.text('Invitar'), findsOneWidget);
    expect(find.text('Invitar a la casa'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    await tester.tap(find.text('Tema'));
    await settle(tester);
    expect(find.text('Siempre fondo oscuro.'), findsOneWidget);

    // What to notify is one step from Avisos and from Tu cuenta.
    await tester.pumpWidget(const SizedBox());
    await pumpScreen(tester, app, const NotificationsScreen());
    await tester.tap(find.byTooltip('Qué avisar'));
    await settle(tester);
    expect(find.byType(NotificationPreferencesScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await pumpScreen(tester, app, AccountSettingsScreen(household: household));
    await tester.tap(find.text('Qué avisar'));
    await settle(tester);
    expect(find.byType(NotificationPreferencesScreen), findsOneWidget);
  });

  testWidgets('Categorías says under each how much it is used', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      final mercado = await _category(app, 'Mercado', CategoryType.gasto, rollover: true);
      await _category(app, 'Salud', CategoryType.gasto);
      await _category(app, 'Salario', CategoryType.ingreso);
      final now = DateTime.now();
      await _movement(app, mercado, DateTime(now.year, now.month, 1));
      await _movement(app, mercado, DateTime(now.year, 1, 1));
      await _movement(app, mercado, DateTime(now.year - 1, 12, 1));
      await app.container
          .read(recurringBillRepositoryProvider)
          .createBill(testHouseholdId, _bill('Plaza', categoryId: mercado));
    });

    await pumpScreen(tester, app, const CategoriesScreen());

    expect(find.text('Acumula · 2 mov. este año · 1 fijo'), findsOneWidget);
    expect(find.text('Sin movimientos este año'), findsOneWidget);
    expect(find.text('Salario'), findsNothing);
    await tester.tap(find.text('Ingresos'));
    await tester.pump();
    expect(find.text('Salario'), findsOneWidget);
  });

  testWidgets('the category preview follows the name, color and icon', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const EditCategoryScreen());
    final preview = find.byKey(const Key('categoryPreview'));
    expect(find.descendant(of: preview, matching: find.text('Vista previa')), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Mascotas');
    await tester.pump();
    expect(find.descendant(of: preview, matching: find.text('Mascotas')), findsOneWidget);
    expect(
      find.text('Lo que sobra o se pasa cuenta para el mes siguiente; se reinicia en enero.'),
      findsOneWidget,
    );
  });

  testWidgets('Avisos marks the unread ones and paints what went over in red', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final now = DateTime.now();
    await tester.runAsync(() async {
      final repo = app.container.read(notificationRepositoryProvider);
      Future<void> notice(String id, NotificationType type, String title, {bool read = false}) =>
          repo.createIfAbsent(
            testHouseholdId,
            id,
            HouseholdNotification(
              id: id,
              type: type,
              title: title,
              body: '',
              createdAt: now.subtract(const Duration(hours: 2)),
              read: read,
            ),
          );
      await notice(
        NotificationIds.budgetExceeded('transporte', now),
        NotificationType.budgetExceeded,
        'Te pasaste',
      );
      await notice(NotificationIds.goalNear('g1'), NotificationType.goalNear, 'Casi', read: true);
    });

    await pumpScreen(tester, app, const NotificationsScreen());

    expect(find.byKey(const Key('notificationUnreadDot')), findsOneWidget);
    // Two hours back is yesterday right after midnight - CI runs in UTC.
    expect(find.text(now.hour >= 2 ? 'hace 2 h' : 'ayer'), findsNWidgets(2));
    final colors = Finan2Theme.light.extension<Finan2Colors>()!;
    final overIcon = tester.widget<Icon>(find.byIcon(Finan2Icons.alerta));
    expect(overIcon.color, colors.expense);

    await tester.tap(find.text('Marcar todo como leído'));
    await settle(tester);
    expect(find.byKey(const Key('notificationUnreadDot')), findsNothing);
    expect(find.text('Marcar todo como leído'), findsNothing);
  });

  testWidgets('Qué avisar says when each one arrives, and its on is green', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const NotificationPreferencesScreen());

    expect(find.text('3, 2 y 1 día antes, y el mismo día'), findsOneWidget);
    expect(find.text('Una vez por categoría y mes'), findsOneWidget);
    expect(find.text('Una vez, cuando una meta pasa el 90%'), findsOneWidget);
    final on = find.byType(Switch).first;
    final track = Theme.of(
      tester.element(on),
    ).switchTheme.trackColor!.resolve({WidgetState.selected});
    expect(track, Finan2Theme.light.extension<Finan2Colors>()!.income);
    // Only here: the app's switches stay violet.
    expect(Finan2Theme.light.switchTheme.trackColor!.resolve({WidgetState.selected}), isNot(track));
  });

  testWidgets('Fijos say their calendar in words; a paused one says so', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final year = DateTime.now().year;
    await tester.runAsync(() async {
      final repo = app.container.read(recurringBillRepositoryProvider);
      await repo.createBill(
        testHouseholdId,
        _bill('Arriendo', amount: 1300000, start: DateTime(2026, 1, 5)),
      );
      await repo.createBill(
        testHouseholdId,
        _bill(
          'Natación',
          amount: 60000,
          frequency: RecurringFrequency.weekly,
          start: DateTime(2026, 10, 5),
          end: DateTime(year + 1, 12, 15),
        ),
      );
      await repo.createBill(testHouseholdId, _bill('Parqueadero', paused: true));
    });

    await pumpScreen(tester, app, const RecurringBillsScreen());

    expect(find.text('Comprometido cada mes'), findsOneWidget);
    expect(find.text('\$1.560.000'), findsOneWidget);
    expect(find.text('2 fijos · los no mensuales, en promedio'), findsOneWidget);
    expect(find.text('Cada mes, día 5'), findsOneWidget);
    // A non-monthly one also says what it adds to the total, to check it by eye.
    expect(
      find.text('Cada lunes, hasta el 15 dic ${year + 1} · Unos \$260.000 al mes'),
      findsOneWidget,
    );
    expect(find.text('En pausa'), findsOneWidget);
  });

  testWidgets('editing a fijo reads its frequency aloud with its monthly cost', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = (await tester.runAsync(TestApp.start))!;
    final bill = _bill('Natación', amount: 60000, start: DateTime(2026, 10, 5)).copyWithId('b1');

    await pumpScreen(tester, app, EditRecurringBillScreen(bill: bill));
    final readAloud = find.byKey(const Key('recurringBillReadAloud'));
    expect(find.descendant(of: readAloud, matching: find.text('Cada mes, día 5')), findsOneWidget);
    expect(find.descendant(of: readAloud, matching: find.text('\$60.000 al mes')), findsOneWidget);

    await tester.tap(find.text('Semanal'));
    await tester.pump();
    expect(find.descendant(of: readAloud, matching: find.text('Cada lunes')), findsOneWidget);
    expect(
      find.descendant(
        of: readAloud,
        matching: find.text('Unos \$260.000 al mes. 52 pagos al año: algunos meses caen 5.'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('recurringBillFrequencyHint')), findsNothing);

    await tester.tap(find.text('Cada 2 semanas'));
    await tester.pump();
    expect(find.byKey(const Key('recurringBillFrequencyHint')), findsOneWidget);
  });

  testWidgets('Notas del mes shows the note as written and browses months', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(
      () => app.container
          .read(monthlyNotesControllerProvider.notifier)
          .saveThisMonth('Llega la prima.\nRevisar el plan de celular.'),
    );

    await pumpScreen(tester, app, const MonthlyNotesScreen());

    expect(find.text('Llega la prima.'), findsOneWidget);
    expect(find.text('Revisar el plan de celular.'), findsOneWidget);

    await tester.tap(find.byTooltip('Mes anterior'));
    await settle(tester);
    expect(find.text('Llega la prima.'), findsNothing);
    expect(find.text('Nada escrito todavía. Toca para escribir.'), findsNWidgets(2));
  });
}

extension on RecurringBill {
  RecurringBill copyWithId(String id) => RecurringBill(
    id: id,
    name: name,
    type: type,
    categoryId: categoryId,
    accountId: accountId,
    amount: amount,
    dayOfMonth: dayOfMonth,
    frequency: frequency,
    startDate: startDate,
    endDate: endDate,
    paused: paused,
  );
}
