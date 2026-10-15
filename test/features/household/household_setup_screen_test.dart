import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/features/household/data/household_model.dart';
import 'package:finan2/features/household/presentation/screens/household_setup_screen.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<ProviderContainer> pumpSetup(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        // No household yet: the currency step has nothing to write.
        currentHouseholdProvider.overrideWith((ref) => Stream<Household?>.value(null)),
      ],
    );
    addTearDown(container.dispose);
    container.read(householdSetupProvider.notifier).ready('ABC.key');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: Finan2Theme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
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
    expect(find.text('Moneda del hogar'), findsOneWidget);
    expect(find.text('Omitir'), findsNothing);

    await tester.tap(find.text('Dólar estadounidense'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Tu primera cuenta'), findsOneWidget);
    expect(find.textContaining('US\$', findRichText: true), findsWidgets);

    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();
    expect(find.text('Paso 3 de 3'), findsOneWidget);

    await tester.tap(find.text('Más tarde, desde Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Invita a tu pareja'), findsOneWidget);
    expect(find.text('ABC'), findsOneWidget);
    expect(container.read(householdSetupProvider).active, isTrue);

    await tester.tap(find.text('Omitir por ahora'));
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
    expect(find.text('Moneda del hogar'), findsOneWidget);
  });
}
