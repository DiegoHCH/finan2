import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/balance/balance_ledger.dart';
import '../../../core/crypto/household_crypto.dart';
import '../../../l10n/l10n.dart';
import '../domain/entities/debt.dart';

extension DebtTypeLabel on DebtType {
  /// Display name in the app's current language - not the stored value,
  /// which is [name].
  String get label => switch (this) {
    DebtType.tarjeta => currentL10n.debtsTypeCard,
    DebtType.credito => currentL10n.debtsTypeLoan,
    DebtType.hipoteca => currentL10n.debtsTypeMortgage,
    DebtType.vehiculo => currentL10n.debtsTypeVehicle,
  };

  static DebtType fromName(String name) =>
      DebtType.values.firstWhere((t) => t.name == name, orElse: () => DebtType.credito);
}

Future<Debt> debtFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
  HouseholdCrypto crypto,
  String householdId,
) async {
  final data = doc.data()!;
  Future<int> amount(String field) async {
    final packed = data[field] as String?;
    return packed == null ? 0 : crypto.decryptAmount(householdId, packed);
  }

  return Debt(
    id: doc.id,
    name: data['name'] as String? ?? '',
    type: DebtTypeLabel.fromName(data['type'] as String? ?? 'credito'),
    balance: await storedBalance(data, crypto, householdId),
    rate: (data['rate'] as num?)?.toDouble() ?? 0,
    paymentDay: (data['paymentDay'] as num?)?.toInt() ?? 1,
    creditLimit: await amount('creditLimit'),
    minPayment: await amount('minPayment'),
    extraPayment: await amount('extraPayment'),
    cutoffDay: (data['cutoffDay'] as num?)?.toInt() ?? 0,
    originalAmount: await amount('originalAmount'),
    monthlyPayment: await amount('monthlyPayment'),
    termMonths: (data['termMonths'] as num?)?.toInt() ?? 0,
    paidInstallments: (data['paidInstallments'] as num?)?.toInt() ?? 0,
    createdBy: data['createdBy'] as String? ?? '',
  );
}

extension DebtFirestore on Debt {
  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'name': name,
      'type': type.name,
      'balance': await crypto.encryptAmount(householdId, balance),
      // Plaintext mirror of "is there anything left to pay" - lets the
      // reminder Cron Trigger in cloudflare/finan2-notifications/worker.js
      // skip a paid-off debt's reminder without needing the household's
      // encryption key, which the server deliberately never has.
      'hasBalance': balance > 0,
      'rate': rate,
      'paymentDay': paymentDay,
      'creditLimit': await crypto.encryptAmount(householdId, creditLimit),
      'minPayment': await crypto.encryptAmount(householdId, minPayment),
      'extraPayment': await crypto.encryptAmount(householdId, extraPayment),
      'cutoffDay': cutoffDay,
      'originalAmount': await crypto.encryptAmount(householdId, originalAmount),
      'monthlyPayment': await crypto.encryptAmount(householdId, monthlyPayment),
      'termMonths': termMonths,
      'paidInstallments': paidInstallments,
      'createdBy': createdBy,
    };
  }
}
