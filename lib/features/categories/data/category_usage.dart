import '../../../l10n/l10n.dart';

/// What still points at a category - see CategoryRepository.usage.
class CategoryUsage {
  const CategoryUsage({required this.movements, required this.recurringBills});

  final int movements;
  final int recurringBills;

  bool get isEmpty => movements == 0 && recurringBills == 0;

  /// "12 movimientos y 1 factura recurrente", in the app's language.
  String describe() {
    final l10n = currentL10n;
    final movementsText = l10n.categoriesUsageMovements(movements);
    final billsText = l10n.categoriesUsageRecurringBills(recurringBills);
    if (movements > 0 && recurringBills > 0) {
      return l10n.categoriesUsageBoth(movementsText, billsText);
    }
    if (movements > 0) return movementsText;
    if (recurringBills > 0) return billsText;
    return '';
  }
}
