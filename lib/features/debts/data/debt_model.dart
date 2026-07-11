import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Debt.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Debt(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: DebtTypeLabel.fromName(data['type'] as String? ?? 'credito'),
      balance: (data['balance'] as num?)?.toInt() ?? 0,
      rate: (data['rate'] as num?)?.toDouble() ?? 0,
      paymentDay: (data['paymentDay'] as num?)?.toInt() ?? 1,
      creditLimit: (data['creditLimit'] as num?)?.toInt() ?? 0,
      minPayment: (data['minPayment'] as num?)?.toInt() ?? 0,
      extraPayment: (data['extraPayment'] as num?)?.toInt() ?? 0,
      cutoffDay: (data['cutoffDay'] as num?)?.toInt() ?? 0,
      originalAmount: (data['originalAmount'] as num?)?.toInt() ?? 0,
      monthlyPayment: (data['monthlyPayment'] as num?)?.toInt() ?? 0,
      termMonths: (data['termMonths'] as num?)?.toInt() ?? 0,
      paidInstallments: (data['paidInstallments'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'balance': balance,
      'rate': rate,
      'paymentDay': paymentDay,
      'creditLimit': creditLimit,
      'minPayment': minPayment,
      'extraPayment': extraPayment,
      'cutoffDay': cutoffDay,
      'originalAmount': originalAmount,
      'monthlyPayment': monthlyPayment,
      'termMonths': termMonths,
      'paidInstallments': paidInstallments,
    };
  }
}
