import 'package:finan2/core/widgets/finan2_transaction_row.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/account_style.dart';
import 'package:finan2/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:finan2/features/accounts/presentation/screens/edit_account_screen.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:finan2/features/debts/presentation/screens/edit_debt_screen.dart';
import 'package:finan2/features/debts/presentation/viewmodels/debt_providers.dart';
import 'package:finan2/features/investments/data/investment_model.dart';
import 'package:finan2/features/investments/presentation/screens/investments_screen.dart';
import 'package:finan2/features/investments/presentation/viewmodels/investment_providers.dart';
import 'package:finan2/features/transfers/data/transfer_model.dart';
import 'package:finan2/features/transfers/presentation/screens/transfer_history_screen.dart';
import 'package:finan2/features/transfers/presentation/viewmodels/transfer_providers.dart';
import 'package:finan2/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

Future<void> _account(TestApp app, String name, int balance, {bool included = true}) => app
    .container
    .read(accountControllerProvider.notifier)
    .save(
      Account(
        id: '',
        name: name,
        type: AccountType.banco,
        balance: balance,
        includeInAvailable: included,
      ),
    );

void main() {
  testWidgets('Cuentas adds up the accounts; the cards subtract apart', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      await _account(app, 'Bancolombia', 4120000);
      await _account(app, 'Efectivo', 230000);
      await _account(app, 'Ahorros', 1000000, included: false);
      await app.container
          .read(debtControllerProvider.notifier)
          .save(
            const Debt(
              id: '',
              name: 'Visa',
              type: DebtType.tarjeta,
              balance: 1140000,
              rate: 28,
              paymentDay: 18,
              cutoffDay: 3,
              creditLimit: 3000000,
            ),
          );
    });

    await pumpScreen(tester, app, const AccountsScreen());

    expect(find.text('Disponible entre las cuentas'), findsOneWidget);
    expect(find.text('\$4.350.000'), findsOneWidget);
    expect(find.text('Banco · no suma en «Disponible»'), findsOneWidget);
    expect(find.text('Tarjetas'), findsOneWidget);
    expect(find.text('Corte día 3 · paga día 18'), findsOneWidget);
    expect(find.text('−\$1.140.000'), findsOneWidget);
  });

  testWidgets('an account keeps its color in Cuentas, whatever its place', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      await _account(app, 'Davivienda', 100000);
      await _account(app, 'Nequi', 100000);
    });
    final accounts = (await tester.runAsync(() => app.first(accountsProvider)))!;

    await pumpScreen(tester, app, const AccountsScreen());

    for (final account in accounts) {
      final row = tester.widget<Finan2TransactionRow>(
        find.ancestor(of: find.text(account.name), matching: find.byType(Finan2TransactionRow)),
      );
      expect(row.iconColor, accountColorOf(app, account.id));
    }
  });

  testWidgets('a new account can stay out of «Disponible»', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const EditAccountScreen());
    expect(
      find.text('Apágalo para cuentas que no se tocan, como un ahorro aparte.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).at(0), 'Ahorros');
    await tester.enterText(find.byType(TextField).at(1), '1000000');
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Crear'));
    await settle(tester);

    final account = (await tester.runAsync(() => app.first(accountsProvider)))!.single;
    expect(account.name, 'Ahorros');
    expect(account.balance, 1000000);
    expect(account.includeInAvailable, isFalse);
  });

  testWidgets('the card being set up is drawn as it is typed', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const EditDebtScreen());
    expect(find.text('Tarjeta de crédito'), findsOneWidget);
    expect(find.text('Tu tarjeta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'visa bancolombia');
    await tester.enterText(find.byType(TextField).at(1), '3000000');
    await tester.enterText(find.byType(TextField).at(3), '3');
    await tester.enterText(find.byType(TextField).at(4), '18');
    await tester.pump();

    expect(find.text('Visa Bancolombia'), findsOneWidget);
    expect(find.text('\$3.000.000'), findsOneWidget);
    expect(find.text('Corte día 3 · paga día 18'), findsOneWidget);
  });

  testWidgets('a loan says when it ends and how much sooner paying more', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const EditDebtScreen());
    await tester.tap(find.text('Vehículo'));
    await settle(tester);
    expect(find.text('Crédito de vehículo'), findsOneWidget);
    expect(find.textContaining('Terminan en'), findsNothing);

    // Name, what they owe today, rate, installment.
    await tester.enterText(find.byType(TextField).at(1), '5710000');
    await tester.enterText(find.byType(TextField).at(2), '16');
    await tester.enterText(find.byType(TextField).at(3), '420000');
    await tester.pump();

    expect(find.textContaining('Terminan en'), findsOneWidget);
    expect(find.textContaining('Si abonan \$100.000 más al mes:'), findsOneWidget);
  });

  testWidgets('Inversiones says the gain and the loss in pesos, no arrows', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      final controller = app.container.read(investmentControllerProvider.notifier);
      await controller.save(
        const Investment(
          id: '',
          name: 'Fondo de acciones',
          kind: InvestmentKind.rentaVariable,
          rate: 0,
          investedAmount: 3940000,
          currentValue: 4260000,
        ),
      );
      await controller.save(
        const Investment(
          id: '',
          name: 'Cripto',
          kind: InvestmentKind.cripto,
          rate: 0,
          investedAmount: 2090000,
          currentValue: 2000000,
        ),
      );
    });

    await pumpScreen(tester, app, const InvestmentsScreen());

    expect(find.text('Valen hoy'), findsOneWidget);
    expect(find.textContaining('pusieron \$6.030.000 · ganan \$230.000'), findsOneWidget);
    expect(find.textContaining('+\$320.000'), findsOneWidget);
    expect(find.textContaining('−\$90.000'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Se actualizan a mano: la app no se conecta a ningún banco.'), findsOneWidget);
  });

  testWidgets('the transfer history goes by month, in the destination color', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    late List<Account> accounts;
    await tester.runAsync(() async {
      await _account(app, 'Bancolombia', 4120000);
      await _account(app, 'Ahorros', 1000000);
      accounts = await app.first(accountsProvider);
      final banco = accounts.firstWhere((a) => a.name == 'Bancolombia').id;
      final ahorros = accounts.firstWhere((a) => a.name == 'Ahorros').id;
      final controller = app.container.read(transferControllerProvider.notifier);
      for (final (date, from, to) in [
        (DateTime(2026, 10, 14), banco, ahorros),
        (DateTime(2026, 9, 9), ahorros, banco),
      ]) {
        await controller.createTransfer(
          Transfer(
            id: '',
            amount: 500000,
            fromAccountId: from,
            toAccountId: to,
            date: date,
            createdBy: testUid,
          ),
        );
      }
    });

    await pumpScreen(tester, app, const TransferHistoryScreen());

    expect(find.text('Plata movida entre cuentas'), findsOneWidget);
    expect(find.textContaining('OCTUBRE'), findsOneWidget);
    expect(find.textContaining('SEPTIEMBRE'), findsOneWidget);
    final toSavings = tester.widget<Finan2TransactionRow>(
      find.ancestor(of: find.text('A Ahorros'), matching: find.byType(Finan2TransactionRow)),
    );
    expect(toSavings.subLabel, 'de Bancolombia · 14 oct');
    expect(
      toSavings.iconColor,
      accountColorOf(app, accounts.firstWhere((a) => a.name == 'Ahorros').id),
    );
  });
}

/// [accountColor] as the screens see it, through the app's container.
Color accountColorOf(TestApp app, String accountId) {
  final slot = app.container.read(accountSwatchesProvider)[accountId]!;
  return Finan2Palette.accountSwatches[slot];
}
