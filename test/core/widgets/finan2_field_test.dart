import 'package:finan2/core/widgets/finan2_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the label in uppercase', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(tester, Finan2Field(label: 'Correo', controller: controller));
    expect(find.text('CORREO'), findsOneWidget);
  });

  testWidgets('obscures text by default when obscureText is true', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(
      tester,
      Finan2Field(label: 'Contraseña', controller: controller, obscureText: true),
    );
    // While hidden, the toggle shows the "crossed-eye" icon (tap to reveal).
    var field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('does not show the visibility toggle for a normal field', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(tester, Finan2Field(label: 'Nombre', controller: controller));
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
  });

  testWidgets('runs the validator and surfaces its error message', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    await pumpFinan2(
      tester,
      Form(
        key: formKey,
        child: Finan2Field(
          label: 'Correo',
          controller: controller,
          validator: (value) =>
              (value == null || !value.contains('@')) ? 'Ingresa un correo válido' : null,
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('Ingresa un correo válido'), findsOneWidget);

    controller.text = 'a@b.com';
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('Ingresa un correo válido'), findsNothing);
  });

  testWidgets('passes maxLines through to the underlying field', (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(
      tester,
      Finan2Field(label: 'Notas', controller: controller, maxLines: 12),
    );
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.maxLines, 12);
  });

  testWidgets('forces maxLines to 1 for a password field even if requested otherwise',
      (tester) async {
    final controller = TextEditingController();
    await pumpFinan2(
      tester,
      Finan2Field(
        label: 'Contraseña',
        controller: controller,
        obscureText: true,
        maxLines: 5,
      ),
    );
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.maxLines, 1);
  });
}
