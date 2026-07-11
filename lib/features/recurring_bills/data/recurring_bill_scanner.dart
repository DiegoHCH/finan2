import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';
import 'recurring_bill_model.dart';

/// Auto-generates each recurring bill's Movement for the current month once
/// its day arrives - runs client-side whenever the app is open (no backend
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
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (final bill in bills) {
      final day = bill.dayOfMonth.clamp(1, daysInMonth);
      if (now.day < day) continue;

      final id = 'recurring_${bill.id}_${now.year}_${now.month}';
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
          date: DateTime(now.year, now.month, day),
          createdBy: currentUid,
        ),
      );
    }
  }
}
