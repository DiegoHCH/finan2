import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

/// Matches the Firestore schema's `type` field for debts. Tarjeta (card) is
/// a revolving line of credit; the other three are fixed-installment loans
/// that share the same form fields.
enum DebtType { tarjeta, credito, hipoteca, vehiculo }

extension DebtTypeLabel on DebtType {
  String get label => switch (this) {
        DebtType.tarjeta => 'Tarjeta',
        DebtType.credito => 'Crédito',
        DebtType.hipoteca => 'Hipoteca',
        DebtType.vehiculo => 'Vehículo',
      };

  bool get isCard => this == DebtType.tarjeta;

  static DebtType fromName(String name) => DebtType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => DebtType.credito,
      );
}

/// A debt shared by the household - a credit card or a fixed-installment
/// loan (crédito/hipoteca/vehículo). Fields that don't apply to [type] are
/// stored as 0 rather than made nullable, so downstream math never has to
/// null-check them.
class Debt {
  const Debt({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.rate,
    required this.paymentDay,
    this.creditLimit = 0,
    this.minPayment = 0,
    this.extraPayment = 0,
    this.cutoffDay = 0,
    this.originalAmount = 0,
    this.monthlyPayment = 0,
    this.termMonths = 0,
    this.paidInstallments = 0,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final DebtType type;
  final int balance;
  final double rate; // tasa E.A. en %, ej. 28.0
  final int paymentDay;

  // Solo tarjeta
  final int creditLimit;
  final int minPayment;
  final int extraPayment;
  final int cutoffDay;

  // Solo crédito/hipoteca/vehículo
  final int originalAmount;
  final int monthlyPayment;
  final int termMonths;
  final int paidInstallments;
  final String createdBy;

  /// El monto contra el que se mide el % pagado: cupo total para tarjetas,
  /// monto original para los demás.
  int get referenceAmount => type.isCard ? creditLimit : originalAmount;

  int get paidAmount => referenceAmount - balance;

  double get paidFraction {
    if (referenceAmount <= 0) return 0;
    return (paidAmount / referenceAmount).clamp(0.0, 1.0);
  }

  /// El pago mensual "base" usado por la calculadora Avalancha: para
  /// tarjetas es el mínimo más el abono extra; para créditos es la cuota
  /// fija.
  int get monthlyBasePayment =>
      type.isCard ? minPayment + extraPayment : monthlyPayment;

  static Future<Debt> fromFirestore(
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
      balance: await amount('balance'),
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

  Future<Map<String, dynamic>> toFirestore(
    HouseholdCrypto crypto,
    String householdId,
  ) async {
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
      'originalAmount':
          await crypto.encryptAmount(householdId, originalAmount),
      'monthlyPayment':
          await crypto.encryptAmount(householdId, monthlyPayment),
      'termMonths': termMonths,
      'paidInstallments': paidInstallments,
      'createdBy': createdBy,
    };
  }
}
