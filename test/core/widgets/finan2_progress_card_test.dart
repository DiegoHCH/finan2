import 'package:finan2/core/widgets/finan2_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget buildCard({VoidCallback? onTap}) {
    return Finan2ProgressCard(
      icon: Icons.flight_outlined,
      iconBackground: Colors.blue,
      iconColor: Colors.white,
      title: 'Viaje a Europa',
      subtitle: 'Meta \$12.000.000 · dic 2026',
      percentText: '58%',
      percentColor: Colors.green,
      progressFraction: 0.58,
      progressColor: Colors.green,
      footLeft: '\$500.000/mes',
      footRight: 'Ahorrado \$7.000.000',
      onTap: onTap,
    );
  }

  testWidgets('renders title, subtitle, percent, and both foot values', (tester) async {
    await pumpFinan2(tester, buildCard());
    expect(find.text('Viaje a Europa'), findsOneWidget);
    expect(find.text('Meta \$12.000.000 · dic 2026'), findsOneWidget);
    expect(find.text('58%'), findsOneWidget);
    expect(find.text('\$500.000/mes'), findsOneWidget);
    expect(find.text('Ahorrado \$7.000.000'), findsOneWidget);
  });

  testWidgets('reflects progressFraction on the underlying progress indicator', (tester) async {
    await pumpFinan2(tester, buildCard());
    final indicator =
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(indicator.value, 0.58);
  });

  testWidgets('calls onTap when tapped, and is not tappable when onTap is null',
      (tester) async {
    var tapped = false;
    await pumpFinan2(tester, buildCard(onTap: () => tapped = true));
    await tester.tap(find.text('Viaje a Europa'));
    expect(tapped, isTrue);

    await pumpFinan2(tester, buildCard());
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('does not overflow when foot values are long, big peso amounts',
      (tester) async {
    await pumpFinan2(
      tester,
      SizedBox(
        width: 340,
        child: Finan2ProgressCard(
          icon: Icons.credit_card_outlined,
          iconBackground: Colors.red,
          iconColor: Colors.white,
          title: 'Tarjeta Bancolombia',
          subtitle: 'Tasa 28.5% · mín. \$1.250.000/mes',
          percentText: '100%',
          percentColor: Colors.red,
          progressFraction: 1,
          progressColor: Colors.red,
          footLeft: 'Pagado \$45.780.000',
          footRight: 'Saldo \$123.456.789',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
