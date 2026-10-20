import 'package:finan2/core/utils/year_month.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/budget/presentation/viewmodels/budget_providers.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/debts/domain/entities/debt.dart';
import 'package:finan2/features/debts/presentation/screens/debt_detail_screen.dart';
import 'package:finan2/features/debts/presentation/viewmodels/debt_providers.dart';
import 'package:finan2/features/plan/presentation/screens/plan_screen.dart';
import 'package:finan2/features/savings_challenge/presentation/screens/savings_challenge_screen.dart';
import 'package:finan2/features/savings_challenge/presentation/viewmodels/savings_challenge_providers.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_model.dart';
import 'package:finan2/features/savings_goals/presentation/screens/edit_savings_goal_screen.dart';
import 'package:finan2/features/savings_goals/presentation/screens/savings_goal_detail_screen.dart';
import 'package:finan2/features/savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import 'package:finan2/features/transactions/domain/entities/movement.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_screen.dart';
import '../helpers/test_app_container.dart';

const _visa = Debt(
  id: '',
  name: 'Tarjeta Visa',
  type: DebtType.tarjeta,
  balance: 1140000,
  rate: 28,
  paymentDay: 18,
  creditLimit: 3000000,
  minPayment: 180000,
);

const _car = Debt(
  id: '',
  name: 'Crédito carro',
  type: DebtType.vehiculo,
  balance: 3710000,
  rate: 16,
  paymentDay: 2,
  originalAmount: 5700000,
  monthlyPayment: 420000,
  termMonths: 24,
);

void main() {
  testWidgets('Presupuesto says what is left, and in red what went over', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      await app.container
          .read(accountControllerProvider.notifier)
          .save(
            const Account(
              id: '',
              name: 'Banco',
              type: AccountType.banco,
              balance: 2000000,
              includeInAvailable: true,
            ),
          );
      final accountId = (await app.first(accountsProvider)).single.id;
      final categories = app.container.read(categoryRepositoryProvider);
      Future<String> category(String name) => categories.createCategory(
        testHouseholdId,
        Category(id: '', name: name, type: CategoryType.gasto, iconSlug: 'tag', color: 0xFF0F766E),
      );
      final mercado = await category('Mercado');
      final transporte = await category('Transporte');
      for (final (id, amount) in [(mercado, 300000), (transporte, 540000)]) {
        await app.container
            .read(transactionControllerProvider.notifier)
            .save(
              Movement(
                id: '',
                amount: amount,
                type: CategoryType.gasto,
                categoryId: id,
                accountId: accountId,
                description: '',
                date: DateTime.now(),
                createdBy: testUid,
              ),
            );
      }
      final month = currentYearMonth();
      final budget = app.container.read(budgetControllerProvider.notifier);
      await budget.setCategoryAmount(month, mercado, 500000);
      await budget.setCategoryAmount(month, transporte, 500000);
    });

    await pumpScreen(tester, app, const PlanScreen());

    expect(find.text(r'quedan $200.000'), findsOneWidget);
    expect(find.text(r'$300.000 de $500.000'), findsOneWidget);
    expect(find.text(r'−$40.000'), findsOneWidget);
    expect(find.text(r'Transporte se pasó $40.000'), findsOneWidget);
  });

  testWidgets('Metas: a ring per goal, what both saved, and the debts in a line', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(() async {
      await app.container
          .read(savingsGoalControllerProvider.notifier)
          .save(
            SavingsGoal(
              id: '',
              name: 'Viaje a Europa',
              iconSlug: 'viaje',
              targetAmount: 12000000,
              targetDate: DateTime(DateTime.now().year + 2, 12),
              monthlyContribution: 0,
              interestRate: 0,
              contributions: [
                Contribution(date: DateTime(2026, 9, 15), amount: 3000000, createdBy: testUid),
              ],
            ),
          );
      final debts = app.container.read(debtControllerProvider.notifier);
      await debts.save(_car);
      await debts.save(_visa);
    });

    await pumpScreen(tester, app, const PlanScreen(initialSection: PlanSection.goals));

    expect(find.text('Viaje a Europa'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.textContaining('va atrasada'), findsOneWidget);
    expect(find.text('van a tiempo en 0 de 1 metas'), findsOneWidget);
    expect(find.text('Primero Tarjeta Visa, luego Crédito carro.'), findsOneWidget);

    // The debts line opens Deudas, with the Avalancha's first marked.
    await tester.tap(find.text('Primero Tarjeta Visa, luego Crédito carro.'));
    await settle(tester);
    expect(find.text('1.º'), findsOneWidget);
    expect(find.text(r'28% · mín. $180.000 · día 18'), findsOneWidget);
    expect(find.textContaining('Próximo pago:'), findsOneWidget);
  });

  testWidgets('a card\'s calendar: the next payment is the one that says when', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final debt = (await tester.runAsync(() async {
      await app.container.read(debtControllerProvider.notifier).save(_visa);
      return (await app.first(debtsProvider)).single;
    }))!;

    await pumpScreen(tester, app, DebtDetailScreen(debt: debt));

    expect(find.text('Saldo pendiente'), findsOneWidget);
    expect(find.text('Previsto'), findsWidgets);
    expect(find.textContaining(RegExp(r'^(hoy|mañana|en \d+ días)$')), findsOneWidget);
    expect(find.text('Registrar pago'), findsOneWidget);
  });

  testWidgets('a goal shows what each one put in', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    final goal = (await tester.runAsync(() async {
      await app.container
          .read(savingsGoalControllerProvider.notifier)
          .save(
            SavingsGoal(
              id: '',
              name: 'Sofá',
              iconSlug: 'casa',
              targetAmount: 2000000,
              targetDate: null,
              monthlyContribution: 100000,
              interestRate: 0,
              contributions: [
                Contribution(date: DateTime(2026, 8, 1), amount: 300000, createdBy: testUid),
                Contribution(date: DateTime(2026, 9, 1), amount: 200000, createdBy: testUid),
              ],
            ),
          );
      return (await app.first(savingsGoalsProvider)).single;
    }))!;

    await pumpScreen(tester, app, SavingsGoalDetailScreen(goal: goal));

    expect(find.text(r'$500.000'), findsWidgets);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text(r'+$300.000'), findsOneWidget);
    expect(find.text(r'+$200.000'), findsOneWidget);
  });

  testWidgets('a new goal says what it takes each month before creating it', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;

    await pumpScreen(tester, app, const EditSavingsGoalScreen());
    expect(find.text('Crear'), findsOneWidget);
    expect(find.textContaining('al mes'), findsNothing);

    await tester.enterText(find.byType(TextField).at(1), '1200000');
    await tester.pump();
    // No date yet: nothing to divide by.
    expect(find.textContaining('al mes'), findsNothing);
  });

  testWidgets('the savings challenge points at the next cell to mark', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(
      () => app.container.read(savingsChallengeControllerProvider.notifier).create('Reto', [
        2000,
        5000,
        10000,
      ]),
    );

    await pumpScreen(tester, app, const SavingsChallengeScreen());
    expect(find.text(r'Siguiente: $2.000'), findsOneWidget);

    await tester.tap(find.text('Marcar'));
    await settle(tester);
    expect(find.text(r'Siguiente: $5.000'), findsOneWidget);
    expect(find.text(r'1 de 3 casillas · meta $17.000'), findsOneWidget);
  });
}
