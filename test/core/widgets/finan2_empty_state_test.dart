import 'package:finan2/core/widgets/finan2_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('renders title, description, and action label', (tester) async {
    await pumpFinan2(
      tester,
      Finan2EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aún no hay movimientos',
        description: 'Registra tu primer ingreso o gasto del mes.',
        actionLabel: '+ Agregar el primero',
        onAction: () {},
      ),
    );
    expect(find.text('Aún no hay movimientos'), findsOneWidget);
    expect(find.text('Registra tu primer ingreso o gasto del mes.'), findsOneWidget);
    expect(find.text('+ Agregar el primero'), findsOneWidget);
  });

  testWidgets('calls onAction when the button is tapped', (tester) async {
    var tapped = false;
    await pumpFinan2(
      tester,
      Finan2EmptyState(
        icon: Icons.savings_outlined,
        title: 'Aún no tienes metas',
        description: 'Crea tu primera meta.',
        actionLabel: '+ Nueva meta',
        onAction: () => tapped = true,
      ),
    );
    await tester.tap(find.text('+ Nueva meta'));
    expect(tapped, isTrue);
  });

  testWidgets('renders fine in the celebratory gold variant too', (tester) async {
    await pumpFinan2(
      tester,
      Finan2EmptyState(
        icon: Icons.celebration_outlined,
        title: '¡Libres de deudas!',
        description: 'No tienes deudas registradas.',
        actionLabel: '+ Agregar una deuda',
        gold: true,
        onAction: () {},
      ),
    );
    expect(find.text('¡Libres de deudas!'), findsOneWidget);
  });
}
