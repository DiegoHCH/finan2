import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  test('the household takes the account name as it is now, not the sign-in snapshot', () async {
    final app = await TestApp.start(withHousehold: false);
    // The snapshot the sign-in left says «Diego»; the account was named
    // after it (sign-up names it a moment later) - as when it read «Yo».
    app.auth.currentUser = FakeUser(testUid, displayName: 'Diego Hoyos');

    await app.container
        .read(householdControllerProvider.notifier)
        .createHousehold(householdName: 'Casa nueva');

    final household = app.container.read(householdControllerProvider).requireValue!;
    expect(household.memberInfo[testUid]?.name, 'Diego Hoyos');
  });
}
