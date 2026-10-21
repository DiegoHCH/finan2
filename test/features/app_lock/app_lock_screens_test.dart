import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/app_lock/data/app_lock_repository.dart';
import 'package:finan2/features/app_lock/presentation/app_lock_gate.dart';
import 'package:finan2/features/app_lock/presentation/screens/app_lock_settings_screen.dart';
import 'package:finan2/features/app_lock/presentation/viewmodels/app_lock_providers.dart';
import 'package:finan2/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_biometric_unlock.dart';
import '../../helpers/pump_screen.dart';
import '../../helpers/test_app_container.dart';
import '../../helpers/test_household_crypto.dart';

/// The app as main.dart builds it - the gate above the Navigator - with a
/// signed-in user and [home] behind it.
Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required AppLockRepository repository,
  FakeBiometricUnlock? biometrics,
  Widget home = const Scaffold(body: Text('Casa')),
}) async {
  final container = ProviderContainer(
    overrides: [
      authStateChangesProvider.overrideWith((ref) => Stream<User?>.value(FakeUser(testUid))),
      appLockRepositoryProvider.overrideWithValue(repository),
      biometricUnlockProvider.overrideWithValue(biometrics ?? FakeBiometricUnlock()),
    ],
  );
  addTearDown(container.dispose);
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
        home: home,
        builder: (context, child) => AppLockGate(child: child!),
      ),
    ),
  );
  await settle(tester);
  return container;
}

Future<void> _typePin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }
  await settle(tester);
}

void main() {
  testWidgets('with the lock off, the app opens straight in', (tester) async {
    await _pumpApp(tester, repository: AppLockRepository(store: InMemoryKeyStore()));
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Escribe tu PIN'), findsNothing);
  });

  testWidgets('with the lock on, a wrong PIN says so and the right one opens', (tester) async {
    final repository = AppLockRepository(store: InMemoryKeyStore());
    await tester.runAsync(() => repository.setPin('2580'));
    await _pumpApp(tester, repository: repository);

    expect(find.text('Escribe tu PIN'), findsOneWidget);
    expect(find.text('Casa'), findsNothing, reason: 'nothing of the app shows behind');

    await _typePin(tester, '1111');
    expect(find.text('PIN incorrecto. Te quedan 4 intentos.'), findsOneWidget);

    await _typePin(tester, '2580');
    expect(find.text('Escribe tu PIN'), findsNothing);
    expect(find.text('Casa'), findsOneWidget);
  });

  testWidgets('fingerprint or face opens it without the PIN', (tester) async {
    final repository = AppLockRepository(store: InMemoryKeyStore());
    await tester.runAsync(() async {
      await repository.setPin('2580');
      await repository.setBiometrics(true);
    });
    final biometrics = FakeBiometricUnlock(enrolled: true, matches: true);
    await _pumpApp(tester, repository: repository, biometrics: biometrics);

    expect(biometrics.prompts, greaterThan(0));
    expect(find.text('Casa'), findsOneWidget);
  });

  testWidgets('«forgot your PIN?» offers to sign out, in a sheet', (tester) async {
    final repository = AppLockRepository(store: InMemoryKeyStore());
    await tester.runAsync(() => repository.setPin('2580'));
    await _pumpApp(tester, repository: repository);

    await tester.tap(find.text('¿Olvidaste tu PIN?'));
    await settle(tester);
    expect(find.text('Quitar el PIN cerrando sesión'), findsOneWidget);
  });

  testWidgets('Ajustes: the PIN stays on; changing it asks for the current one', (tester) async {
    final repository = AppLockRepository(store: InMemoryKeyStore());
    await tester.runAsync(() => repository.setPin('2580'));
    final container = await _pumpApp(
      tester,
      repository: repository,
      home: const AppLockSettingsScreen(),
    );
    // Cold start with the lock on: unlock first.
    await _typePin(tester, '2580');

    expect(find.text('Cambiar PIN'), findsOneWidget);
    expect(find.text('Pedir PIN al abrir'), findsNothing);
    // No fingerprint here: the switch is there, off, and says why.
    expect(find.textContaining('no tiene huella ni rostro'), findsOneWidget);

    await tester.tap(find.text('Cambiar PIN'));
    await settle(tester);
    expect(find.text('Escribe tu PIN actual'), findsOneWidget);
    await _typePin(tester, '2580');
    expect(find.text('Elige un PIN'), findsOneWidget);
    await _typePin(tester, '1397');
    await _typePin(tester, '1397');
    await settle(tester);

    expect(container.read(appLockSettingsProvider).value?.enabled, isTrue);
    expect(find.text('Escribe tu PIN'), findsNothing);
    expect((await tester.runAsync(() => repository.verify('1397')))!.ok, isTrue);
  });

  testWidgets('Ajustes: fingerprint goes on only after it recognizes you', (tester) async {
    final repository = AppLockRepository(store: InMemoryKeyStore());
    await tester.runAsync(() => repository.setPin('2580'));
    final biometrics = FakeBiometricUnlock(enrolled: true);
    final container = await _pumpApp(
      tester,
      repository: repository,
      biometrics: biometrics,
      home: const AppLockSettingsScreen(),
    );
    await _typePin(tester, '2580');

    await tester.tap(find.byKey(const Key('appLockBiometricsSwitch')));
    await settle(tester);
    expect(container.read(appLockSettingsProvider).value?.biometrics, isFalse);

    biometrics.matches = true;
    await tester.tap(find.byKey(const Key('appLockBiometricsSwitch')));
    await settle(tester);
    expect(container.read(appLockSettingsProvider).value?.biometrics, isTrue);
  });
}
