import 'stable_index.dart';

/// Gives each of [ids] a slot among [count] colors: its own slot from the ID,
/// or the next free one if another ID already took it. IDs are placed in
/// sorted order, so the result doesn't depend on how the list is ordered,
/// and no two share a color while there are at most [count] of them.
Map<String, int> assignSwatches(Iterable<String> ids, int count) {
  final taken = <int>{};
  final slots = <String, int>{};
  for (final id in [...ids.toSet()]..sort()) {
    var slot = stableIndex(id) % count;
    if (taken.length < count) {
      while (taken.contains(slot)) {
        slot = (slot + 1) % count;
      }
    }
    taken.add(slot);
    slots[id] = slot;
  }
  return slots;
}
