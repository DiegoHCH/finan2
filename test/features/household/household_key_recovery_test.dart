import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  test('getting the key back opens the amounts already on screen', () async {
    final app = await TestApp.start();
    await app.container
        .read(accountControllerProvider.notifier)
        .save(
          const Account(
            id: '',
            name: 'Banco',
            type: AccountType.banco,
            balance: 500000,
            includeInAvailable: true,
          ),
        );
    final key = (await app.crypto.exportKey(testHouseholdId))!;

    // A phone without the key: the list is open and failed to decrypt.
    await app.crypto.deleteKey(testHouseholdId);
    app.container.invalidate(accountsProvider);
    final subscription = app.container.listen(accountsProvider, (_, _) {});
    addTearDown(subscription.close);
    await pumpEventQueue();
    expect(app.container.read(accountsProvider).error, isA<Finan2CryptoException>());

    final error = await app.container
        .read(householdControllerProvider.notifier)
        .importMissingKey(householdId: testHouseholdId, pastedCode: 'CASA.$key');
    expect(error, isNull);
    await pumpEventQueue();

    final accounts = app.container.read(accountsProvider);
    expect(accounts.error, isNull);
    expect(accounts.value?.single.balance, 500000);
  });
}
