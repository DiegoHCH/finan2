import 'package:finan2/core/widgets/finan2_stat_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('uppercases the label and renders the value as-is', (tester) async {
    await pumpFinan2(
      tester,
      const Finan2StatBox(label: 'Ingresos', value: '\$3.400.000'),
    );
    expect(find.text('INGRESOS'), findsOneWidget);
    expect(find.text('\$3.400.000'), findsOneWidget);
  });

  testWidgets('shows a color dot only when dotColor is given', (tester) async {
    await pumpFinan2(
      tester,
      const Finan2StatBox(label: 'Gastos', value: '\$1.000', dotColor: Colors.red),
    );
    expect(find.byType(Container), findsWidgets);

    await pumpFinan2(
      tester,
      const Finan2StatBox(label: 'Pago mín.', value: '\$180.000', dense: true),
    );
    // No dot variant (dense trio stat) should still render fine without one.
    expect(find.text('PAGO MÍN.'), findsOneWidget);
  });
}
