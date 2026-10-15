import 'dart:io';

import 'package:finan2/features/accounts/data/account_model.dart';
import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/debts/data/debt_model.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_model.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:finan2/features/transactions/data/tags.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_household_crypto.dart';

/// firestore.rules lists every field each model writes (`hasExactly`) and
/// the values of each enum. A field or enum value added to a model without
/// the rules rejects every save in production - this catches it here.
void main() {
  const householdId = 'h1';
  final rules = File('firestore.rules').readAsStringSync();

  /// The body of `function <name>(...) { ... }`, up to the next function.
  String ruleFunction(String name) {
    final start = rules.indexOf('function $name(');
    expect(start, isNot(-1), reason: '$name() not found in firestore.rules');
    final next = rules.indexOf('function ', start + 1);
    return rules.substring(start, next == -1 ? rules.length : next);
  }

  List<String> quotedList(String source, String prefix) {
    final match = RegExp('${RegExp.escape(prefix)}\\s*\\[([^\\]]*)\\]').firstMatch(source);
    expect(match, isNotNull, reason: '"$prefix [...]" not found');
    return RegExp("'([^']*)'").allMatches(match!.group(1)!).map((m) => m.group(1)!).toList();
  }

  Future<void> expectMatches(
    String function,
    Map<String, dynamic> written,
    List<Enum> enumValues,
  ) async {
    final body = ruleFunction(function);
    expect(quotedList(body, 'hasExactly(').toSet(), written.keys.toSet(), reason: function);
    expect(
      quotedList(body, 'd.type in').toSet(),
      enumValues.map((e) => e.name).toSet(),
      reason: '$function enum values',
    );
  }

  test('categories', () async {
    final written = const Category(
      id: 'c',
      name: 'Mercado',
      type: CategoryType.gasto,
      iconSlug: 'cart',
      color: 0xFF0F9D74,
    ).toFirestore();
    await expectMatches('validCategory', written, CategoryType.values);
  });

  test('accounts', () async {
    final crypto = await testHouseholdCrypto(householdId);
    final written = await const Account(
      id: 'a',
      name: 'Nequi',
      type: AccountType.billetera,
      balance: 1000,
      includeInAvailable: true,
    ).toFirestore(crypto, householdId);
    await expectMatches('validAccount', written, AccountType.values);
  });

  test('transactions', () async {
    final crypto = await testHouseholdCrypto(householdId);
    final written = await Movement(
      id: 't',
      amount: 1000,
      type: CategoryType.gasto,
      categoryId: 'c',
      accountId: 'a',
      description: '',
      date: DateTime(2026, 10, 15),
      createdBy: 'u1',
    ).toFirestore(crypto, householdId);
    await expectMatches('validTransaction', written, CategoryType.values);
  });

  test('the tag limit matches the app', () {
    expect(ruleFunction('maxTags'), contains('return $maxTagsPerMovement;'));
  });

  test('debts', () async {
    final crypto = await testHouseholdCrypto(householdId);
    final written = await const Debt(
      id: 'd',
      name: 'Visa',
      type: DebtType.tarjeta,
      balance: 1000,
      rate: 28,
      paymentDay: 5,
    ).toFirestore(crypto, householdId);
    await expectMatches('validDebt', written, DebtType.values);
  });

  test('savings goals', () async {
    final crypto = await testHouseholdCrypto(householdId);
    final written = await SavingsGoal(
      id: 'g',
      name: 'Viaje',
      iconSlug: 'viaje',
      targetAmount: 1000,
      targetDate: null,
      monthlyContribution: 100,
      interestRate: 0,
      contributions: const [],
    ).toFirestore(crypto, householdId);
    expect(
      quotedList(ruleFunction('validSavingsGoal'), 'hasExactly(').toSet(),
      written.keys.toSet(),
    );
  });

  test('encrypted amounts fit the size encryptedAmount() allows', () async {
    final crypto = await testHouseholdCrypto(householdId);
    final body = ruleFunction('encryptedAmount');
    final min = int.parse(RegExp(r'size\(\) >= (\d+)').firstMatch(body)!.group(1)!);
    final max = int.parse(RegExp(r'size\(\) <= (\d+)').firstMatch(body)!.group(1)!);
    for (final amount in [0, 7, -1, 999999999999, -9223372036854775808]) {
      final packed = await crypto.encryptAmount(householdId, amount);
      expect(packed.length, inInclusiveRange(min, max), reason: '$amount');
    }
  });
}
