/// What RecurringBillScanner needs from wherever `pendingBills` markers live.
abstract interface class PendingBillStore {
  Future<void> deletePending(String householdId, String id);
}
