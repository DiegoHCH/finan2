import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

enum AccountType { efectivo, banco, billetera, debito }

extension AccountTypeLabel on AccountType {
  String get label => switch (this) {
    AccountType.efectivo => 'Efectivo',
    AccountType.banco => 'Banco',
    AccountType.billetera => 'Billetera',
    AccountType.debito => 'Débito',
  };

  static AccountType fromName(String name) =>
      AccountType.values.firstWhere((t) => t.name == name, orElse: () => AccountType.banco);
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.includeInAvailable,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final AccountType type;
  final int balance;
  final bool includeInAvailable;
  final String createdBy;

  static Future<Account> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    final balance = await crypto.decryptAmount(householdId, data['balance'] as String);
    return Account(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: AccountTypeLabel.fromName(data['type'] as String? ?? 'banco'),
      balance: balance,
      includeInAvailable: data['includeInAvailable'] as bool? ?? true,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'name': name,
      'type': type.name,
      'balance': await crypto.encryptAmount(householdId, balance),
      'includeInAvailable': includeInAvailable,
      'createdBy': createdBy,
    };
  }
}
