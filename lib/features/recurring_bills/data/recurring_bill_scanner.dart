import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';
import 'recurring_bill_model.dart';
import 'recurring_bill_repository.dart';

/// Turns recurring bills into Movements as they come due, using a
/// deterministic transaction ID so nothing is generated twice. Two paths:
/// [scan] covers the current month whenever the app is open; the Worker's
/// cron covers days no one opened it, leaving `pendingBills` markers that
/// [confirmPending] registers - the Worker can't encrypt amounts itself.
class RecurringBillScanner {
  const RecurringBillScanner(this._transactionRepository, this._billRepository);

  final TransactionRepository _transactionRepository;
  final RecurringBillRepository _billRepository;

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
        await _generate(householdId, currentUid, bill, date);
      }
    }
  }

  Future<void> confirmPending({
    required String householdId,
    required String currentUid,
    required List<RecurringBill> bills,
    required List<PendingBill> pending,
  }) async {
    final billById = {for (final b in bills) b.id: b};
    for (final marker in pending) {
      final bill = billById[marker.billId];
      // Deleted or paused since, or a date the bill no longer has.
      final stillDue =
          bill != null &&
          !bill.paused &&
          bill.occurrencesBetween(marker.date, marker.date).isNotEmpty &&
          movementIdFor(bill, marker.date) == marker.id;
      if (!stillDue) {
        await _billRepository.deletePending(householdId, marker.id);
        continue;
      }
      await _generate(householdId, currentUid, bill, marker.date);
    }
  }

  Future<void> _generate(String householdId, String currentUid, RecurringBill bill, DateTime date) {
    final id = movementIdFor(bill, date);
    return _transactionRepository.createIfAbsent(
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
      recurring: true,
    );
  }

  /// Monthly bills keep the per-month ID they always had, so movements
  /// generated before frequencies existed aren't created a second time.
  /// Mirrored by movementIdFor in cloudflare/finan2-notifications/worker.js.
  static String movementIdFor(RecurringBill bill, DateTime date) =>
      bill.frequency == RecurringFrequency.monthly
      ? 'recurring_${bill.id}_${date.year}_${date.month}'
      : 'recurring_${bill.id}_${date.year}_${date.month}_${date.day}';
}
