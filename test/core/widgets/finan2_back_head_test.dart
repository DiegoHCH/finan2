import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/core/widgets/finan2_back_head.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the title', (tester) async {
    await pumpFinan2(tester, const Finan2BackHead(title: 'Viaje a Europa'));
    expect(find.text('Viaje a Europa'), findsOneWidget);
  });

  testWidgets('renders the trailing widget when given', (tester) async {
    await pumpFinan2(
      tester,
      Finan2BackHead(
        title: 'Tarjeta Visa',
        trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
      ),
    );
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('tapping the back chevron pops the current route', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: Finan2Theme.light,
        home: const Scaffold(body: Text('Inicio')),
      ),
    );

    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Finan2BackHead(title: 'Detalle')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsNothing);
    expect(find.text('Inicio'), findsOneWidget);
  });
}
