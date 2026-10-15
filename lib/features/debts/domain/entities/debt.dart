/// Matches the Firestore schema's `type` field for debts. Tarjeta (card) is
/// a revolving line of credit; the other three are fixed-installment loans
/// that share the same form fields.
enum DebtType { tarjeta, credito, hipoteca, vehiculo }

/// How close a debt is to being paid off, from [Debt.paidFraction].
enum DebtStatus { critical, warning, good }

extension DebtTypeKind on DebtType {
  bool get isCard => this == DebtType.tarjeta;
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
  final int cutoffDay;

  // Solo crédito/hipoteca/vehículo
  final int originalAmount;
  final int monthlyPayment;
  final int termMonths;
  final int paidInstallments;

  // Abono extra sobre el pago base - aplica a cualquier tipo de deuda y
  // alimenta la bolsa compartida de la Avalancha (ver avalanche_calculator.dart).
  final int extraPayment;
  final String createdBy;

  /// El monto contra el que se mide el % pagado: cupo total para tarjetas,
  /// monto original para los demás.
  int get referenceAmount => type.isCard ? creditLimit : originalAmount;

  int get paidAmount => referenceAmount - balance;

  double get paidFraction {
    if (referenceAmount <= 0) return 0;
    return (paidAmount / referenceAmount).clamp(0.0, 1.0);
  }

  /// Rojo→ámbar→verde según [paidFraction]: crítico = recién tomada o la
  /// tarjeta está al límite del cupo, verde = casi lista o completamente
  /// pagada. 3 pasos fijos (no un degradado continuo) para que sigan siendo
  /// distinguibles con daltonismo rojo-verde - ver DebtStatusColor para el
  /// mapeo a Color.
  DebtStatus get status {
    if (paidFraction < 0.40) return DebtStatus.critical;
    if (paidFraction < 0.75) return DebtStatus.warning;
    return DebtStatus.good;
  }

  /// El pago mensual "base" más el abono extra: para tarjetas es el mínimo,
  /// para créditos es la cuota fija - en ambos casos más lo que se declare
  /// como abono extra.
  int get monthlyBasePayment => (type.isCard ? minPayment : monthlyPayment) + extraPayment;
}
