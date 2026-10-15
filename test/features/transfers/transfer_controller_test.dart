import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/transfers/data/transfer_model.dart';
import 'package:finan2/features/transfers/presentation/viewmodels/transfer_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  Future<Map<String, int>> balances() async => {
    for (final a in await app.first(accountsProvider)) a.name: a.balance,
  };

  Future<(String, String)> twoAccounts() async {
    final accounts = app.container.read(accountControllerProvider.notifier);
    for (final (name, balance) in [('Banco', 100000), ('Efectivo', 0)]) {
      await accounts.save(
        Account(
          id: '',
          name: name,
          type: AccountType.banco,
          balance: balance,
          includeInAvailable: true,
        ),
      );
    }
    final list = await app.first(accountsProvider);
    return (
      list.firstWhere((a) => a.name == 'Banco').id,
      list.firstWhere((a) => a.name == 'Efectivo').id,
    );
  }

  test('a transfer moves the amount between the two accounts', () async {
    final (bank, cash) = await twoAccounts();

    await app.container
        .read(transferControllerProvider.notifier)
        .createTransfer(
          Transfer(
            id: '',
            amount: 30000,
            fromAccountId: bank,
            toAccountId: cash,
            date: DateTime(2026, 10, 15),
            createdBy: testUid,
          ),
        );

    expect(app.container.read(transferControllerProvider).error, isNull);
    expect(await balances(), {'Banco': 70000, 'Efectivo': 30000});
  });

  test('deleting a transfer puts the amount back', () async {
    final (bank, cash) = await twoAccounts();
    final controller = app.container.read(transferControllerProvider.notifier);
    await controller.createTransfer(
      Transfer(
        id: '',
        amount: 30000,
        fromAccountId: bank,
        toAccountId: cash,
        date: DateTime(2026, 10, 15),
        createdBy: testUid,
      ),
    );

    await controller.deleteTransfer((await app.first(transfersProvider)).single);

    expect(await balances(), {'Banco': 100000, 'Efectivo': 0});
    expect(await app.docs('transfers'), isEmpty);
  });
}
