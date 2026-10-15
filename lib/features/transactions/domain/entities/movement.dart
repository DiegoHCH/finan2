import '../../../categories/domain/category_type.dart';

class Movement {
  const Movement({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.description,
    required this.date,
    required this.createdBy,
    this.cardDebtId = '',
    this.paidBy = '',
    this.tags = const [],
  });

  final String id;
  final int amount;
  final CategoryType type;
  final String categoryId;

  /// The Account this movement is paid from/into. Empty when [cardDebtId] is
  /// set instead - a movement targets exactly one of the two.
  final String accountId;

  /// A credit-card Debt this movement was charged to, instead of an Account.
  /// A gasto/factura/ahorro here increases what's owed on the card rather
  /// than debiting cash on hand; see TransactionRepository's signed delta.
  final String cardDebtId;
  final String description;
  final DateTime date;
  final String createdBy;

  /// Which member paid (or received) it - not necessarily who logged it.
  /// Empty means the same as [createdBy]; read [payer] instead.
  final String paidBy;

  String get payer => paidBy.isEmpty ? createdBy : paidBy;

  /// Free labels that cut across categories ("viaje-cartagena",
  /// "cumple-ana"), already normalized - see normalizeTag.
  final List<String> tags;

  bool get isIncome => type == CategoryType.ingreso;

  bool get isCardPurchase => cardDebtId.isNotEmpty;
}
