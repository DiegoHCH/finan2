import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

/// The classic "spare change" savings challenge grid: tap a cell once
/// you've set that amount aside. The target is simply the sum of every
/// cell - never entered by hand, so it can't drift from what's achievable.
class SavingsChallenge {
  const SavingsChallenge({
    required this.id,
    required this.name,
    required this.cellAmounts,
    required this.done,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final List<int> cellAmounts;
  final List<bool> done;
  final String createdBy;

  int get target => cellAmounts.fold(0, (total, a) => total + a);

  int get saved {
    var total = 0;
    for (var i = 0; i < cellAmounts.length; i++) {
      if (i < done.length && done[i]) total += cellAmounts[i];
    }
    return total;
  }

  double get fraction => target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0);

  static Future<SavingsChallenge> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    final rawAmounts = (data['cellAmounts'] as List?) ?? const [];
    final rawDone = (data['done'] as List?) ?? const [];
    return SavingsChallenge(
      id: doc.id,
      name: data['name'] as String? ?? 'Reto de ahorro',
      cellAmounts: await Future.wait(
        rawAmounts.map((a) => crypto.decryptAmount(householdId, a as String)),
      ),
      done: rawDone.map((d) => d as bool).toList(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    return {
      'name': name,
      'cellAmounts': await Future.wait(
        cellAmounts.map((a) => crypto.encryptAmount(householdId, a)),
      ),
      'done': done,
      'createdBy': createdBy,
    };
  }
}
