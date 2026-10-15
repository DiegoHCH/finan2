import 'package:finan2/core/widgets/finan2_app_top.dart';
import 'package:finan2/features/household/data/household_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

Household _household({List<String> members = const ['u1', 'u2']}) {
  return Household(
    id: 'H8-4KP2',
    name: 'Casa Hoyos',
    members: members,
    memberInfo: {
      for (final id in members) id: HouseholdMemberInfo(name: id == 'u1' ? 'Diego' : 'Vale'),
    },
    currency: 'COP',
    startYear: 2026,
    weekStartsOn: 'monday',
  );
}

void main() {
  testWidgets('renders the label and title', (tester) async {
    await pumpFinan2(tester, const Finan2AppTop(label: 'Cuentas', title: 'Dinero disponible'));
    expect(find.text('Cuentas'), findsOneWidget);
    expect(find.text('Dinero disponible'), findsOneWidget);
  });

  testWidgets('shows one avatar per household member when no trailing is given', (tester) async {
    await pumpFinan2(
      tester,
      Finan2AppTop(label: 'Hogar', title: 'Casa Hoyos', household: _household()),
    );
    expect(find.text('D'), findsOneWidget);
    expect(find.text('V'), findsOneWidget);
  });

  testWidgets('trailing replaces the avatars even when a household is given', (tester) async {
    await pumpFinan2(
      tester,
      Finan2AppTop(
        label: 'Deudas',
        title: '\$4.850.000',
        household: _household(),
        trailing: const Text('Estrategia Avalancha'),
      ),
    );
    expect(find.text('Estrategia Avalancha'), findsOneWidget);
    expect(find.text('D'), findsNothing);
    expect(find.text('V'), findsNothing);
  });

  testWidgets('renders with neither household nor trailing without error', (tester) async {
    await pumpFinan2(tester, const Finan2AppTop(label: 'Notas', title: 'Julio 2026'));
    expect(find.text('Notas'), findsOneWidget);
  });
}
