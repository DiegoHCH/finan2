import 'package:finan2/features/household/data/household_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  test('the household just created already opens its amounts on this phone', () async {
    final app = await TestApp.start(withHousehold: false);

    // Inicio asks for the key as soon as the household exists - which is
    // before its key is generated.
    final asked = <String>[];
    app.container.listen<AsyncValue<Household?>>(currentHouseholdProvider, (_, next) {
      final id = next.value?.id;
      if (id == null || asked.contains(id)) return;
      asked.add(id);
      app.container.read(householdHasKeyProvider(id));
    }, fireImmediately: true);

    await app.container
        .read(householdControllerProvider.notifier)
        .createHousehold(householdName: 'Casa nueva');

    final household = app.container.read(householdControllerProvider).requireValue!;
    expect(asked, contains(household.id));
    expect(await app.container.read(householdHasKeyProvider(household.id).future), isTrue);
  });
}
