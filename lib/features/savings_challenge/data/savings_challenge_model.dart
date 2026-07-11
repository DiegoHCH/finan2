import 'package:cloud_firestore/cloud_firestore.dart';

/// The classic "spare change" savings challenge grid: tap a cell once
/// you've set that amount aside. The target is simply the sum of every
/// cell - never entered by hand, so it can't drift from what's achievable.
class SavingsChallenge {
  const SavingsChallenge({
    required this.id,
    required this.name,
    required this.cellAmounts,
    required this.done,
  });

  final String id;
  final String name;
  final List<int> cellAmounts;
  final List<bool> done;

  int get target => cellAmounts.fold(0, (total, a) => total + a);

  int get saved {
    var total = 0;
    for (var i = 0; i < cellAmounts.length; i++) {
      if (i < done.length && done[i]) total += cellAmounts[i];
    }
    return total;
  }

  double get fraction => target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0);

  factory SavingsChallenge.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final rawAmounts = (data['cellAmounts'] as List?) ?? const [];
    final rawDone = (data['done'] as List?) ?? const [];
    return SavingsChallenge(
      id: doc.id,
      name: data['name'] as String? ?? 'Reto de ahorro',
      cellAmounts: rawAmounts.map((a) => (a as num).toInt()).toList(),
      done: rawDone.map((d) => d as bool).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'cellAmounts': cellAmounts, 'done': done};
  }
}
