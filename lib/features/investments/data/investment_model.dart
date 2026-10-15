import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

/// Matches the Firestore schema's `kind` field.
enum InvestmentKind { rentaFija, rentaVariable, cripto }

extension InvestmentKindLabel on InvestmentKind {
  String get label => switch (this) {
    InvestmentKind.rentaFija => 'Renta fija',
    InvestmentKind.rentaVariable => 'Renta variable',
    InvestmentKind.cripto => 'Alto riesgo',
  };

  static InvestmentKind fromName(String name) => InvestmentKind.values.firstWhere(
    (k) => k.name == name,
    orElse: () => InvestmentKind.rentaVariable,
  );
}

/// A household investment (CDT, stock fund, crypto...). Like Account.balance
/// and Debt.balance, [currentValue] is a plain number the household updates
/// by hand whenever they check their statement - no automatic growth
/// calculation like SavingsGoal's compounded interest.
class Investment {
  const Investment({
    required this.id,
    required this.name,
    required this.kind,
    required this.rate,
    required this.investedAmount,
    required this.currentValue,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final InvestmentKind kind;

  /// % E.A., only meaningful/shown for [InvestmentKind.rentaFija] (e.g. a CDT).
  final double rate;
  final int investedAmount;
  final int currentValue;
  final String createdBy;

  int get returnAmount => currentValue - investedAmount;

  static Future<Investment> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    return Investment(
      id: doc.id,
      name: data['name'] as String? ?? '',
      kind: InvestmentKindLabel.fromName(data['kind'] as String? ?? 'rentaVariable'),
      rate: (data['rate'] as num?)?.toDouble() ?? 0,
      investedAmount: await crypto.decryptAmount(householdId, data['investedAmount'] as String),
      currentValue: await crypto.decryptAmount(householdId, data['currentValue'] as String),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'name': name,
      'kind': kind.name,
      'rate': rate,
      'investedAmount': await crypto.encryptAmount(householdId, investedAmount),
      'currentValue': await crypto.encryptAmount(householdId, currentValue),
      'createdBy': createdBy,
    };
  }
}
