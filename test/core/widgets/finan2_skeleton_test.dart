import 'package:finan2/core/widgets/finan2_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

double _barOpacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find
          .descendant(of: find.byType(Finan2SkeletonRow), matching: find.byType(FadeTransition))
          .first,
    )
    .opacity
    .value;

void main() {
  testWidgets('a loading list is drawn with the shape of its rows', (tester) async {
    await pumpFinan2(tester, const Finan2SkeletonList(rows: 3, heading: true));
    expect(find.byType(Finan2SkeletonRow), findsNWidgets(3));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
  });

  testWidgets('the bars breathe', (tester) async {
    await pumpFinan2(tester, const Finan2SkeletonList());
    final start = _barOpacity(tester);
    await tester.pump(const Duration(milliseconds: 450));
    expect(_barOpacity(tester), isNot(start));
  });

  testWidgets('and hold still when the system asks for less motion', (tester) async {
    await pumpFinan2(
      tester,
      const MediaQuery(data: MediaQueryData(disableAnimations: true), child: Finan2SkeletonList()),
    );
    final start = _barOpacity(tester);
    await tester.pump(const Duration(milliseconds: 450));
    expect(_barOpacity(tester), start);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a waiting figure keeps its words and says why', (tester) async {
    await pumpFinan2(
      tester,
      const Finan2Skeleton(
        child: Finan2SkeletonFigure(
          label: 'Les queda del plan de octubre',
          note: 'Descifrando los montos en este teléfono…',
        ),
      ),
    );
    expect(find.text('Les queda del plan de octubre'), findsOneWidget);
    expect(find.text('Descifrando los montos en este teléfono…'), findsOneWidget);
  });
}
