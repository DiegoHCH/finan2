import 'dart:async';

import 'package:finan2/core/widgets/finan2_form_top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('a fast double tap on Guardar only calls onSave once', (tester) async {
    var callCount = 0;
    final completers = <Completer<void>>[];

    await pumpFinan2(
      tester,
      Finan2FormTop(
        title: 'Nueva categoría',
        onSave: () {
          callCount++;
          final completer = Completer<void>();
          completers.add(completer);
          return completer.future;
        },
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const Key('finan2FormTopSave'));
    await tester.tap(saveButton);
    await tester.pump();
    // Second tap arrives while the first save is still in flight.
    await tester.tap(saveButton);
    await tester.pump();

    expect(callCount, 1);

    completers.first.complete();
    await tester.pumpAndSettle();

    // Once the save resolves, tapping again is allowed (e.g. a retry).
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(callCount, 2);
    completers.last.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows a spinner instead of Guardar while saving', (tester) async {
    final completer = Completer<void>();
    await pumpFinan2(
      tester,
      Finan2FormTop(title: 'Nueva categoría', onSave: () => completer.future),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guardar'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Guardar'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('Guardar'), findsOneWidget);
  });
}
