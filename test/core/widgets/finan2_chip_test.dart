import 'package:finan2/core/widgets/finan2_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('renders its label and icon when both are given', (tester) async {
    await pumpFinan2(
      tester,
      Finan2Chip(label: 'Efectivo', icon: Icons.attach_money, selected: false, onTap: () {}),
    );
    expect(find.text('Efectivo'), findsOneWidget);
    expect(find.byIcon(Icons.attach_money), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFinan2(
      tester,
      Finan2Chip(label: 'Banco', selected: false, onTap: () => tapped = true),
    );
    await tester.tap(find.text('Banco'));
    expect(tapped, isTrue);
  });

  testWidgets('still renders with only an icon and no label', (tester) async {
    await pumpFinan2(tester, Finan2Chip(icon: Icons.credit_card, selected: false, onTap: () {}));
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
