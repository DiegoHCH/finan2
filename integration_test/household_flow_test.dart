// On a device or emulator, against a fake Firestore - never production:
//   flutter test integration_test -d <device>
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/flows/household_flow.dart';
import '../test/helpers/test_app_container.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Intl.defaultLocale = 'es';
    await initializeDateFormatting();
  });

  testWidgets('create a household, record a movement, plan its category', (tester) async {
    SharedPreferences.setMockInitialValues({'notif_primer_shown': true});
    final app = (await tester.runAsync(() => TestApp.start(withHousehold: false, withPin: false)))!;

    await householdFlow(tester, app);
  });
}
