import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app_container.dart';
import 'household_flow.dart';

void main() {
  testWidgets('create a household, record a movement, see the balance', (tester) async {
    SharedPreferences.setMockInitialValues({'notif_primer_shown': true});
    final app = (await tester.runAsync(() => TestApp.start(withHousehold: false)))!;

    await householdFlow(tester, app);
  });
}
