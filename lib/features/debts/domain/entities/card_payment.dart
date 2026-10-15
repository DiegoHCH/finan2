/// A payment made toward a credit-card Debt from one of the household's own
/// accounts. Deliberately NOT a Movement (like Transfer) - it never counts
/// as income/expense, it just moves money from an account into paying down
/// what's owed on the card.
class CardPayment {
  const CardPayment({
    required this.id,
    required this.amount,
    required this.fromAccountId,
    required this.cardDebtId,
    required this.date,
    required this.createdBy,
  });

  final String id;
  final int amount;
  final String fromAccountId;
  final String cardDebtId;
  final DateTime date;
  final String createdBy;
}
