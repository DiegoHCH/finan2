import 'package:finan2/core/widgets/auth_gate.dart';
import 'package:finan2/core/widgets/finan2_nav_bar.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

/// Create a household, go through its setup, record a movement and plan
/// its category from Plan. Shared by the widget test and the integration test on a
/// device, so it only uses what a person sees and taps.
Future<void> householdFlow(WidgetTester tester, TestApp app) async {
  await pumpScreen(tester, app, const AuthGate());
  await tester.pump(const Duration(milliseconds: 800));
  await settle(tester);

  // Create the household, keeping the suggested name.
  await tap(tester, find.text('Crear un hogar nuevo'));
  await tap(tester, find.text('Crear hogar'));

  // Setup: currency as it is, a first account with today's balance, the
  // recovery phrase later, then out of the invitation.
  await tap(tester, find.text('Siguiente'));
  await tester.enterText(find.byType(TextField).at(0), 'Banco');
  await tester.enterText(find.byType(TextField).at(1), '1000000');
  await tap(tester, find.text('Crear cuenta'));
  await tap(tester, find.text('Más tarde, desde Ajustes'));
  await tap(tester, find.text('Omitir por ahora'));

  // A movement from the Movimientos tab.
  await tap(tester, navTab('Movimientos'));
  await tap(tester, find.text('+ Agregar el primero'));
  await tester.enterText(find.byType(TextField).first, '120000');
  await tap(tester, find.text('Mercado'));
  await tap(tester, find.text('Guardar'));
  expect(find.text('Mercado'), findsWidgets);

  final balance = (await tester.runAsync(() => app.first(accountsProvider)))!.single.balance;
  expect(balance, 1000000 - 120000);

  // Plan Mercado for the month from Plan, which opens on Presupuesto.
  await tap(tester, navTab('Plan'));
  // Mercado already has a row: it has spending this month. .last because
  // the Movimientos tab, still in the tree, also shows "Mercado".
  await tap(tester, find.text('Mercado').last);
  await tester.enterText(find.byType(TextField).last, '500000');
  await tap(tester, find.text('Guardar'));
  expect(find.textContaining('500.000'), findsWidgets);
  expect(find.textContaining('120.000'), findsWidgets);
}

/// A place in the bottom bar - the hidden tabs repeat some of these names
/// in their headers.
Finder navTab(String label) =>
    find.descendant(of: find.byType(Finan2NavBar), matching: find.text(label));

Future<void> tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList();
    fail('Not on screen: $finder. Texts: $texts');
  }
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await settle(tester);
}
