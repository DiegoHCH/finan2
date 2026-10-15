import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  late TestApp app;
  late String accountId;

  setUp(() async {
    app = await TestApp.start();
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
    accountId = (await app.first(accountsProvider)).single.id;
  });

  Movement spend(int amount, {String id = ''}) => Movement(
    id: id,
    amount: amount,
    type: CategoryType.gasto,
    categoryId: 'mercado',
    accountId: accountId,
    description: 'Mercado',
    date: DateTime(2026, 10, 15),
    createdBy: testUid,
  );

  Future<int> balance() async => (await app.first(accountsProvider)).single.balance;

  test('spending takes it out of the account, editing adjusts the difference', () async {
    final controller = app.container.read(transactionControllerProvider.notifier);

    await controller.save(spend(120000));
    expect(await balance(), 380000);

    final id = (await app.ids('transactions')).single;
    await controller.save(spend(100000, id: id));
    expect(await balance(), 400000);
  });

  test('deleting a movement gives the money back', () async {
    final controller = app.container.read(transactionControllerProvider.notifier);
    await controller.save(spend(120000));
    final id = (await app.ids('transactions')).single;

    await controller.delete(id);

    expect(await balance(), 500000);
    expect(await app.docs('transactions'), isEmpty);
  });
}
