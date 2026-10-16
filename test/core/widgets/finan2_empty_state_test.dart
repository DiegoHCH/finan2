import 'package:finan2/core/widgets/finan2_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('says what goes here and offers the action', (tester) async {
    var tapped = false;
    await pumpFinan2(
      tester,
      Finan2EmptyState(
        icon: Icons.edit_outlined,
        title: 'Octubre está en blanco.',
        description: 'Lo primero que anoten aparece aquí.',
        actionLabel: 'Anotar el primero',
        onAction: () => tapped = true,
      ),
    );
    expect(find.text('Octubre está en blanco.'), findsOneWidget);
    expect(find.text('Lo primero que anoten aparece aquí.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Anotar el primero'));
    expect(tapped, isTrue);
  });

  testWidgets('the second way out is a quiet link', (tester) async {
    var tapped = false;
    await pumpFinan2(
      tester,
      Finan2EmptyState(
        icon: Icons.edit_outlined,
        title: 'Octubre está en blanco.',
        description: '…',
        actionLabel: 'Anotar el primero',
        onAction: () {},
        secondaryLabel: 'Ver septiembre',
        onSecondary: () => tapped = true,
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Ver septiembre'));
    expect(tapped, isTrue);
  });

  testWidgets('an empty that celebrates has no hurry: a quiet button', (tester) async {
    await pumpFinan2(
      tester,
      Finan2EmptyState(
        icon: Icons.check_rounded,
        title: 'No deben nada.',
        description: 'Si llega una tarjeta o un crédito, agréguenlo aquí.',
        actionLabel: 'Agregar una deuda',
        celebrates: true,
        onAction: () {},
      ),
    );
    expect(find.widgetWithText(OutlinedButton, 'Agregar una deuda'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('fits in a short space by scrolling', (tester) async {
    await pumpFinan2(
      tester,
      SizedBox(
        height: 160,
        child: Finan2EmptyState(
          icon: Icons.vpn_key_outlined,
          title: 'Este teléfono no tiene la llave de la casa.',
          description: 'Los montos se cifran con una llave que solo vive en sus teléfonos.',
          actionLabel: 'Usar la frase de 12 palabras',
          onAction: () {},
          secondaryLabel: 'Pedirle el código a Vale',
          secondaryAsButton: true,
          onSecondary: () {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(OutlinedButton, 'Pedirle el código a Vale'), findsOneWidget);
  });
}
