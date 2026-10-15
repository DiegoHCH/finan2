import '../../categories/data/category_model.dart';
import 'transaction_model.dart';

/// What Movimientos is narrowed to. Amounts only exist decrypted on the
/// device, so filtering happens here rather than in a Firestore query.
class MovementFilter {
  const MovementFilter({
    this.query = '',
    this.types = const {},
    this.categoryId,
    this.sourceId,
    this.payer,
    this.tag,
  });

  /// Matched against the description, the category's name, the tags and -
  /// when it's all digits - the amount.
  final String query;

  /// Empty means every type.
  final Set<CategoryType> types;
  final String? categoryId;

  /// An account or a credit card - a movement targets exactly one.
  final String? sourceId;
  final String? payer;
  final String? tag;

  bool get hasQuery => query.trim().isNotEmpty;

  /// Filters other than the text query - the ones behind the filter button.
  int get activeFilterCount =>
      (types.isEmpty ? 0 : 1) +
      (categoryId == null ? 0 : 1) +
      (sourceId == null ? 0 : 1) +
      (payer == null ? 0 : 1) +
      (tag == null ? 0 : 1);

  bool get isEmpty => !hasQuery && activeFilterCount == 0;

  MovementFilter copyWith({
    String? query,
    Set<CategoryType>? types,
    String? Function()? categoryId,
    String? Function()? sourceId,
    String? Function()? payer,
    String? Function()? tag,
  }) =>
      MovementFilter(
        query: query ?? this.query,
        types: types ?? this.types,
        categoryId: categoryId != null ? categoryId() : this.categoryId,
        sourceId: sourceId != null ? sourceId() : this.sourceId,
        payer: payer != null ? payer() : this.payer,
        tag: tag != null ? tag() : this.tag,
      );

  /// Keeps only the text query - what "Limpiar filtros" leaves behind.
  MovementFilter withoutFilters() => MovementFilter(query: query);

  bool matches(Movement tx, {String categoryName = ''}) {
    if (types.isNotEmpty && !types.contains(tx.type)) return false;
    if (categoryId != null && tx.categoryId != categoryId) return false;
    if (sourceId != null && tx.accountId != sourceId && tx.cardDebtId != sourceId) {
      return false;
    }
    if (payer != null && tx.payer != payer) return false;
    if (tag != null && !tx.tags.contains(tag)) return false;
    if (!hasQuery) return true;

    final needle = foldForSearch(query.trim());
    if (foldForSearch(tx.description).contains(needle)) return true;
    if (foldForSearch(categoryName).contains(needle)) return true;
    final bareNeedle = needle.startsWith('#') ? needle.substring(1) : needle;
    if (bareNeedle.isNotEmpty && tx.tags.any((t) => foldForSearch(t).contains(bareNeedle))) {
      return true;
    }
    // "50.000" and "50000" both find a 50000 movement.
    final digits = needle.replaceAll(RegExp(r'[.,\s$]'), '');
    return RegExp(r'^\d+$').hasMatch(digits) && tx.amount.toString().contains(digits);
  }

  List<Movement> apply(List<Movement> movements, Map<String, String> categoryNames) => [
        for (final tx in movements)
          if (matches(tx, categoryName: categoryNames[tx.categoryId] ?? '')) tx,
      ];
}

const _accents = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
  'ñ': 'n',
};

/// Lowercase without accents, so "cafe" finds "Café".
String foldForSearch(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString();
}
