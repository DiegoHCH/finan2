/// A recurring bill's occurrence the Worker left for a phone to register.
/// Its ID is the movement's - see RecurringBillScanner.movementIdFor.
class PendingBill {
  const PendingBill({required this.id, required this.billId, required this.date});

  final String id;
  final String billId;

  /// Local calendar day, no time.
  final DateTime date;
}
