import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:finan2/features/household/data/household_model.dart';
import 'package:finan2/features/household/presentation/screens/household_setup_screen.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  Future<ProviderContainer> pumpSetup(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        // No household yet: the currency step has nothing to write.
        currentHouseholdProvider.overrideWith((ref) => Stream<Household?>.value(null)),
        // The invitation puts the member's initial in their circle.
        authStateChangesProvider.overrideWith((ref) => Stream<User?>.value(FakeUser(testUid))),
      ],
    );
    addTearDown(container.dispose);
    container.read(householdSetupProvider.notifier).ready('ABC.key');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: Finan2Theme.light,
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HouseholdSetupScreen(shareCode: 'ABC.key'),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('walks currency, account and recovery, then invites', (tester) async {
    final container = await pumpSetup(tester);
    expect(find.text('Paso 1 de 3'), findsOneWidget);
    expect(find.text('¿En qué moneda llevan las cuentas?'), findsOneWidget);
    expect(find.text('Ahora no'), findsNothing);

    await tester.tap(find.text('Dólar estadounidense'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('¿Dónde está la plata hoy?'), findsOneWidget);
    expect(find.textContaining('US\$', findRichText: true), findsWidgets);

    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    expect(find.text('Paso 3 de 3'), findsOneWidget);

    expect(find.text('¿Y si pierden la llave?'), findsOneWidget);
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    expect(find.text('¿Alguien más va a anotar?'), findsOneWidget);
    expect(find.text('ABC'), findsOneWidget);
    // Diego's circle, and the partner's still empty.
    expect(find.text('D'), findsOneWidget);
    expect(find.bySemanticsLabel('Invita a alguien'), findsOneWidget);
    expect(container.read(householdSetupProvider).active, isTrue);

    await tester.tap(find.text('Por ahora, solo yo'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(container.read(householdSetupProvider).active, isFalse);
  });

  testWidgets('an account without a name asks for one', (tester) async {
    await pumpSetup(tester);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Ponle un nombre'), findsOneWidget);
  });

  testWidgets('a back gesture does not leave the setup', (tester) async {
    await pumpSetup(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(find.text('¿En qué moneda llevan las cuentas?'), findsOneWidget);
  });
}
