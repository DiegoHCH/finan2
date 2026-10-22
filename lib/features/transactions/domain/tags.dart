import 'entities/movement.dart';

/// Mirrored by maxTags() in firestore.rules.
const maxTagsPerMovement = 10;
const maxTagLength = 30;

/// "  #Viaje Cartagena " -> "viaje-cartagena". Empty when nothing's left.
String normalizeTag(String input) {
  var tag = input.trim().toLowerCase();
  while (tag.startsWith('#')) {
    tag = tag.substring(1);
  }
  tag = tag.trim().replaceAll(RegExp(r'\s+'), '-');
  return tag.length > maxTagLength ? tag.substring(0, maxTagLength) : tag;
}

/// Every tag in [movements], most used first, for suggestions.
List<String> tagsByUse(Iterable<Movement> movements) {
  final counts = <String, int>{};
  for (final tx in movements) {
    for (final tag in tx.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }
  return counts.keys.toList()..sort((a, b) {
    final byCount = counts[b]!.compareTo(counts[a]!);
    return byCount != 0 ? byCount : a.compareTo(b);
  });
}

/// What was spent under each tag in [movements], biggest first - Angela's
/// «el 1 gasté 15.000 en gasolina, el 15 otros 20.000: ¿cuánto en total?».
/// Income doesn't count; a movement with two tags counts for both.
List<(String tag, int spent)> spendingByTag(Iterable<Movement> movements) {
  final totals = <String, int>{};
  for (final tx in movements) {
    if (tx.isIncome) continue;
    for (final tag in tx.tags) {
      totals[tag] = (totals[tag] ?? 0) + tx.amount;
    }
  }
  final entries = totals.entries.toList()
    ..sort((a, b) {
      final bySpent = b.value.compareTo(a.value);
      return bySpent != 0 ? bySpent : a.key.compareTo(b.key);
    });
  return [for (final e in entries) (e.key, e.value)];
}
