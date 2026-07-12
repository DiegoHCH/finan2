import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

class BudgetRepository {
  BudgetRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _budgets(String householdId) =>
      _db.collection('households').doc(householdId).collection('budgets');

  String _docId(int year, int month) => '${year}_$month';

  /// Maps categoryId -> planned amount for the given month. Missing/never
  /// budgeted months just stream an empty map. Each value is stored
  /// encrypted (the doc's field names are category IDs, not a fixed
  /// `amount` field, so every entry needs decrypting individually).
  Stream<Map<String, int>> watchBudget(
    String householdId, {
    required int year,
    required int month,
  }) {
    return _budgets(householdId)
        .doc(_docId(year, month))
        .snapshots()
        .asyncMap((doc) async {
      final data = doc.data();
      if (data == null) return const {};
      final entries = await Future.wait(
        data.entries.map((entry) async {
          final amount = await _crypto.decryptAmount(
            householdId,
            entry.value as String,
          );
          return MapEntry(entry.key, amount);
        }),
      );
      return Map.fromEntries(entries);
    });
  }

  Future<void> setCategoryAmount(
    String householdId, {
    required int year,
    required int month,
    required String categoryId,
    required int amount,
  }) async {
    await _budgets(householdId).doc(_docId(year, month)).set({
      categoryId: await _crypto.encryptAmount(householdId, amount),
    }, SetOptions(merge: true));
  }
}
