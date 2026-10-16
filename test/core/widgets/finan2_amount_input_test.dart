import 'package:finan2/core/widgets/finan2_amount_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the given currency symbol as a prefix', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(tester, Finan2AmountInput(controller: controller, currencySymbol: 'US\$'));
    expect(find.text('US\$'), findsOneWidget);
  });

  testWidgets('defaults to \$ when no currency symbol is given', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(tester, Finan2AmountInput(controller: controller));
    expect(find.text('\$'), findsOneWidget);
  });

  testWidgets('keeps only digits and groups them', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(tester, Finan2AmountInput(controller: controller));

    await tester.enterText(find.byType(TextFormField), '1a2b3.,-000');
    expect(controller.text, '123.000');
    expect(Finan2AmountInput.parse(controller.text), 123000);
  });

  testWidgets('autofocus requests focus on the field when true', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(tester, Finan2AmountInput(controller: controller, autofocus: true));
    await tester.pump();
    // Autofocus opens a keyboard connection as soon as the field is built.
    expect(tester.testTextInput.isVisible, isTrue);
  });
}
