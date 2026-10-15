import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/accounts/data/account_repository.dart';
import 'package:finan2/features/budget/data/budget_repository.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/categories/data/category_repository.dart';
import 'package:finan2/features/debts/data/debt_repository.dart';
import 'package:finan2/features/export/data/csv_report_writer.dart';
import 'package:finan2/features/export/data/report_builder.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_repository.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/data/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

const _hid = 'h1';

void main() {
  late ReportBuilder builder;

  setUp(() async {
    final firestore = FakeFirebaseFirestore();
    final crypto = await testHouseholdCrypto(_hid);
    final household = firestore.collection('households').doc(_hid);
    await household.collection('categories').doc('luz').set(
          const Category(
            id: 'luz',
            name: 'Servicios',
            type: CategoryType.factura,
            iconSlug: 'servicios',
            color: 0xFFC8892F,
          ).toFirestore(),
        );
    await household.collection('accounts').doc('a1').set(
          await const Account(
            id: 'a1',
            name: 'Bancolombia',
            type: AccountType.banco,
            balance: 0,
            includeInAvailable: true,
          ).toFirestore(crypto, _hid),
        );
    final now = DateTime.now();
    await household.collection('transactions').doc('t1').set(
          await Movement(
            id: 't1',
            amount: 1250000,
            type: CategoryType.factura,
            categoryId: 'luz',
            accountId: 'a1',
            description: 'Luz, octubre',
            date: DateTime(now.year, now.month, 1),
            createdBy: 'u1',
            paidBy: 'u2',
            tags: const ['casa', 'epm'],
          ).toFirestore(crypto, _hid),
        );
    builder = ReportBuilder(
      transactionRepository: TransactionRepository(firestore: firestore, crypto: crypto),
      accountRepository: AccountRepository(firestore: firestore, crypto: crypto),
      categoryRepository: CategoryRepository(firestore: firestore),
      budgetRepository: BudgetRepository(firestore: firestore, crypto: crypto),
      debtRepository: DebtRepository(firestore: firestore, crypto: crypto),
      savingsGoalRepository: SavingsGoalRepository(firestore: firestore, crypto: crypto),
    );
  });

  Future<Report> build({required bool plain}) => builder.build(
        householdId: _hid,
        householdName: 'Casa',
        period: ExportPeriod.thisMonth,
        includeTransactions: true,
        includeBudget: false,
        includeDebtsAndSavings: false,
        formatMoney: (v) => '\$ $v',
        memberNames: const {'u1': 'Ana', 'u2': 'Ben'},
        plainValues: plain,
      );

  test('CSV movements carry the real type, a bare amount, payer and tags', () async {
    final report = await build(plain: true);
    final movements = report.sections.single;
    expect(movements.headers.last, 'Etiquetas');
    final row = movements.rows.single;
    final now = DateTime.now();
    expect(row, [
      '${now.year}-${now.month.toString().padLeft(2, '0')}-01',
      'Factura',
      'Servicios',
      'Bancolombia',
      'Luz, octubre',
      '1250000',
      'Ben',
      'casa epm',
    ]);
  });

  test('the PDF keeps formatted amounts and no CSV-only columns', () async {
    final row = (await build(plain: false)).sections.single.rows.single;
    expect(row[5], '\$ 1250000');
    expect(row, hasLength(6));
  });

  test('the CSV writer makes one table per section, with a BOM', () async {
    final files = const CsvReportWriter().write(await build(plain: true), stamp: '2026-10-15');
    expect(files.keys, ['finan2_movimientos_2026-10-15.csv']);
    final bytes = files.values.single;
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    final text = utf8.decode(bytes.skip(3).toList());
    expect(text.split(RegExp(r'\r?\n')).first, 'Fecha,Tipo,Categoría,Cuenta,Descripción,Monto,Pagó,Etiquetas');
    expect(text, contains('"Luz, octubre"'));
  });
}
