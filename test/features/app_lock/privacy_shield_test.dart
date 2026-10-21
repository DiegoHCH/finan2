import 'package:finan2/features/app_lock/presentation/privacy_shield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('blurs the app while it is not active, lifts on return', (tester) async {
    await pumpFinan2(tester, const PrivacyShield(child: Text(r'$4.500.000')));
    expect(find.byKey(const Key('privacyShield')), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.byKey(const Key('privacyShield')), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byKey(const Key('privacyShield')), findsNothing);
  });
}
