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
    return _budgets(householdId).doc(_docId(year, month)).snapshots().asyncMap((doc) async {
      final data = doc.data();
      if (data == null) return const {};
      final entries = await Future.wait(
        data.entries.map((entry) async {
          final amount = await _crypto.decryptAmount(householdId, entry.value as String);
          return MapEntry(entry.key, amount);
        }),
      );
      return Map.fromEntries(entries);
    });
  }

  /// Every month's budget for [year]: month (1-12) -> categoryId ->
  /// planned amount. Months never budgeted are absent.
  Stream<Map<int, Map<String, int>>> watchBudgetsForYear(String householdId, {required int year}) {
    return _budgets(householdId).snapshots().asyncMap((snap) async {
      final result = <int, Map<String, int>>{};
      for (final doc in snap.docs) {
        final parts = doc.id.split('_');
        if (parts.length != 2 || parts[0] != '$year') continue;
        final month = int.tryParse(parts[1]);
        if (month == null) continue;
        result[month] = {
          for (final entry in doc.data().entries)
            entry.key: await _crypto.decryptAmount(householdId, entry.value as String),
        };
      }
      return result;
    });
  }

  /// Copies every category's planned amount from one month into another
  /// that has no budget yet. Returns how many categories were copied - 0 if
  /// the source is empty or the target already has a budget.
  Future<int> copyBudget(
    String householdId, {
    required ({int year, int month}) from,
    required ({int year, int month}) to,
  }) {
    final source = _budgets(householdId).doc(_docId(from.year, from.month));
    final target = _budgets(householdId).doc(_docId(to.year, to.month));
    return _db.runTransaction((tx) async {
      final sourceData = (await tx.get(source)).data() ?? const {};
      final targetData = (await tx.get(target)).data() ?? const {};
      if (sourceData.isEmpty || targetData.isNotEmpty) return 0;
      // Same household, same key: the encrypted amounts copy as they are.
      tx.set(target, sourceData);
      return sourceData.length;
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
