import 'package:finan2/core/notifications/notification_opt_in.dart';
import 'package:finan2/core/widgets/auth_gate.dart';
import 'package:finan2/features/app_lock/presentation/viewmodels/app_lock_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_screen.dart';
import '../../helpers/test_app_container.dart';

Future<void> _tap(WidgetTester tester, String text) async {
  expect(find.text(text), findsWidgets, reason: text);
  await tester.tap(find.text(text).last);
  await settle(tester);
}

Future<void> _typePin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }
  await settle(tester);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('first time on a phone: notifications, PIN, then fingerprint', (tester) async {
    final app = (await tester.runAsync(() => TestApp.start(withPin: false)))!;
    app.biometrics
      ..enrolled = true
      ..matches = true;
    await pumpScreen(tester, app, const AuthGate());
    await tester.pump(const Duration(milliseconds: 800));
    await settle(tester);

    expect(find.text('Paso 1 de 3'), findsOneWidget);
    expect(find.text('Que no se te pase nada'), findsOneWidget);
    await _tap(tester, 'Activar notificaciones');
    expect(app.push.requests, 1);
    expect(await tester.runAsync(NotificationOptIn.optedIn), isTrue);

    expect(find.text('Paso 2 de 3'), findsOneWidget);
    expect(find.text('Crea tu PIN'), findsOneWidget);
    // Required: no way around it.
    expect(find.text('Ahora no'), findsNothing);
    await _typePin(tester, '2580');
    expect(find.text('Escríbelo otra vez'), findsOneWidget);
    await _typePin(tester, '2581');
    expect(find.text('No coinciden. Elige el PIN otra vez.'), findsOneWidget);
    await _typePin(tester, '2580');
    await _typePin(tester, '2580');

    expect(find.text('Paso 3 de 3'), findsOneWidget);
    await _tap(tester, 'Usar huella o rostro');

    final lock = app.container.read(appLockSettingsProvider).value!;
    expect(lock.enabled, isTrue);
    expect(lock.biometrics, isTrue);
    final right = await tester.runAsync(
      () => app.container.read(appLockRepositoryProvider).verify('2580'),
    );
    expect(right!.ok, isTrue);
    expect(find.text('Crea tu PIN'), findsNothing, reason: 'on to the app');
  });

  testWidgets('steps that don\'t apply are left out, and «Ahora no» sticks', (tester) async {
    final app = (await tester.runAsync(() => TestApp.start(withPin: false)))!;
    await pumpScreen(tester, app, const AuthGate());
    await tester.pump(const Duration(milliseconds: 800));
    await settle(tester);

    // No fingerprint on this phone: 2 steps.
    expect(find.text('Paso 1 de 2'), findsOneWidget);
    await _tap(tester, 'Ahora no');
    expect(app.push.requests, 0);
    expect(await tester.runAsync(NotificationOptIn.optedIn), isFalse);

    expect(find.text('Paso 2 de 2'), findsOneWidget);
    await _typePin(tester, '1397');
    await _typePin(tester, '1397');
    final lock = app.container.read(appLockSettingsProvider).value!;
    expect(lock.enabled, isTrue);
    expect(lock.biometrics, isFalse);
  });

  testWidgets('notifications already allowed: only the PIN, without «1 of 1»', (tester) async {
    final app = (await tester.runAsync(() => TestApp.start(withPin: false)))!;
    app.push.allowed = true;
    await pumpScreen(tester, app, const AuthGate());
    await tester.pump(const Duration(milliseconds: 800));
    await settle(tester);

    expect(find.text('Crea tu PIN'), findsOneWidget);
    expect(find.textContaining('Paso'), findsNothing);
  });

  testWidgets('a phone already set up goes straight in', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await pumpScreen(tester, app, const AuthGate());
    await tester.pump(const Duration(milliseconds: 800));
    await settle(tester);

    expect(find.text('Crea tu PIN'), findsNothing);
    expect(find.text('Que no se te pase nada'), findsNothing);
  });
}
