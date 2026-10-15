import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';
import 'recurring_bill_model.dart';

/// Auto-generates each recurring bill's Movements for the current month as
/// they come due - runs client-side whenever the app is open (no backend
/// to schedule this), using a deterministic transaction ID so re-scanning
/// never creates duplicates. Mirrors notification_scanner.dart's approach.
class RecurringBillScanner {
  const RecurringBillScanner(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<void> scan({
    required String householdId,
    required String currentUid,
    required List<RecurringBill> bills,
    DateTime? now,
  }) async {
    now ??= DateTime.now();
    final monthStart = DateTime(now.year, now.month);

    for (final bill in bills) {
      if (bill.paused) continue;
      for (final date in bill.occurrencesBetween(monthStart, now)) {
        final id = movementIdFor(bill, date);
        await _transactionRepository.createIfAbsent(
          householdId,
          id,
          Movement(
            id: id,
            amount: bill.amount,
            type: bill.type,
            categoryId: bill.categoryId,
            accountId: bill.accountId,
            description: bill.name,
            date: date,
            createdBy: currentUid,
          ),
        );
      }
    }
  }

  /// Monthly bills keep the per-month ID they always had, so movements
  /// generated before frequencies existed aren't created a second time.
  static String movementIdFor(RecurringBill bill, DateTime date) =>
      bill.frequency == RecurringFrequency.monthly
      ? 'recurring_${bill.id}_${date.year}_${date.month}'
      : 'recurring_${bill.id}_${date.year}_${date.month}_${date.day}';
}
