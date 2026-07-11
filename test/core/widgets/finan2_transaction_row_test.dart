import 'package:finan2/core/widgets/finan2_transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget buildRow({
    String? avatarLabel,
    int? avatarIndex,
    VoidCallback? onTap,
  }) {
    return Finan2TransactionRow(
      icon: Icons.shopping_cart_outlined,
      iconColor: Colors.green,
      description: 'Mercado Éxito',
      subLabel: 'Gastos · 12 jul',
      avatarLabel: avatarLabel,
      avatarIndex: avatarIndex,
      amountText: '−\$318.000',
      amountColor: Colors.black,
      onTap: onTap,
    );
  }

  testWidgets('renders description, sublabel, and amount', (tester) async {
    await pumpFinan2(tester, buildRow());
    expect(find.text('Mercado Éxito'), findsOneWidget);
    expect(find.text('Gastos · 12 jul'), findsOneWidget);
    expect(find.text('−\$318.000'), findsOneWidget);
  });

  testWidgets('renders the mini avatar when both label and index are given', (tester) async {
    await pumpFinan2(tester, buildRow(avatarLabel: 'D', avatarIndex: 0));
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('renders no avatar at all when they are omitted (recurring bills case)',
      (tester) async {
    await pumpFinan2(tester, buildRow());
    // Only the description/sublabel/amount texts should exist - no stray
    // single-letter avatar text.
    expect(find.text('D'), findsNothing);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFinan2(tester, buildRow(onTap: () => tapped = true));
    await tester.tap(find.text('Mercado Éxito'));
    expect(tapped, isTrue);
  });
}
