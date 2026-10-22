import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/auth/data/auth_repository.dart';
import 'package:finan2/features/auth/presentation/screens/login_screen.dart';
import 'package:finan2/features/auth/presentation/screens/signup_screen.dart';
import 'package:finan2/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:finan2/features/backup/presentation/screens/backup_screen.dart';
import 'package:finan2/features/household/presentation/screens/create_join_household_screen.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

/// Nobody has an account: every reset is for an unknown email.
class _NoAccounts extends Fake implements AuthRepository {
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw FirebaseAuthException(code: 'user-not-found');
  }
}

/// Signed out, with no Firebase behind.
Future<void> _pumpSignedOut(WidgetTester tester, Widget screen) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(_NoAccounts()),
      authStateChangesProvider.overrideWith((ref) => Stream<User?>.value(null)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: Finan2Theme.light,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Entrar says what the app is, not «Bienvenido»', (tester) async {
    await _pumpSignedOut(tester, const LoginScreen());

    expect(find.text('La libreta de la casa,\npara ti o para los dos.'), findsOneWidget);
    expect(find.textContaining('Bienvenido'), findsNothing);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Seguir con Google'), findsOneWidget);
  });

  testWidgets('a password reset never tells whether the email has an account', (tester) async {
    await _pumpSignedOut(tester, const LoginScreen());

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'nadie@x.co');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Correo enviado'), findsOneWidget);
    expect(
      find.text('Si nadie@x.co tiene una cuenta, te llegará un correo para recuperarla.'),
      findsOneWidget,
    );
  });

  testWidgets('Registro says the account is personal and the rule before a mistake', (
    tester,
  ) async {
    await _pumpSignedOut(tester, const SignupScreen());

    expect(find.textContaining('Es solo tuya'), findsOneWidget);
    // Written under the field before anything was typed.
    expect(find.text('Mínimo 8 caracteres, con una mayúscula y una minúscula'), findsOneWidget);
  });

  testWidgets('joining takes the code in monospace and the button follows the choice', (
    tester,
  ) async {
    final app = (await tester.runAsync(() => TestApp.start(withHousehold: false)))!;
    await pumpScreen(tester, app, const CreateJoinHouseholdScreen());
    expect(find.text('Armar la casa'), findsOneWidget);

    await tester.tap(find.text('Tengo un código'));
    await tester.pump();

    expect(find.text('Entrar a la casa'), findsOneWidget);
    final code = tester.widget<EditableText>(find.byType(EditableText));
    expect(code.style.fontFamily, 'monospace');
  });

  testWidgets('a code says whose household it opens before joining it', (tester) async {
    final app = (await tester.runAsync(() => TestApp.start(withHousehold: false)))!;
    await tester.runAsync(
      () => app.firestore.collection('invites').doc('ABCDEFGHJK').set({
        'householdId': 'h-vale',
        'createdBy': 'u-vale',
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'householdName': 'Casa de Vale',
        'inviterName': 'Vale',
      }),
    );
    await pumpScreen(tester, app, const CreateJoinHouseholdScreen());

    await tester.tap(find.text('Tengo un código'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'ABCDEFGHJK.llave');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar a la casa'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('¿Entrar a Casa de Vale?'), findsOneWidget);
    expect(find.textContaining('Te invitó Vale.'), findsOneWidget);
  });

  testWidgets('the backup says what restoring does before any button', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await pumpScreen(tester, app, const BackupScreen());

    expect(find.textContaining('lo creado después se borra', findRichText: true), findsOneWidget);
    expect(find.text('Crear copia ahora'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Restaurar una copia'), findsOneWidget);
  });
}
