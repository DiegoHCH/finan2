import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { efectivo, banco, billetera, debito }

extension AccountTypeLabel on AccountType {
  String get label => switch (this) {
        AccountType.efectivo => 'Efectivo',
        AccountType.banco => 'Banco',
        AccountType.billetera => 'Billetera',
        AccountType.debito => 'Débito',
      };

  static AccountType fromName(String name) => AccountType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => AccountType.banco,
      );
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.includeInAvailable,
  });

  final String id;
  final String name;
  final AccountType type;
  final int balance;
  final bool includeInAvailable;

  factory Account.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Account(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: AccountTypeLabel.fromName(data['type'] as String? ?? 'banco'),
      balance: (data['balance'] as num?)?.toInt() ?? 0,
      includeInAvailable: data['includeInAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'balance': balance,
      'includeInAvailable': includeInAvailable,
    };
  }
}
