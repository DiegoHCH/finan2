/// What still points at a category - see CategoryRepository.usage.
class CategoryUsage {
  const CategoryUsage({required this.movements, required this.recurringBills});

  final int movements;
  final int recurringBills;

  bool get isEmpty => movements == 0 && recurringBills == 0;

  /// "12 movimientos y 1 factura recurrente".
  String describe() {
    final parts = [
      if (movements > 0) movements == 1 ? '1 movimiento' : '$movements movimientos',
      if (recurringBills > 0)
        recurringBills == 1 ? '1 factura recurrente' : '$recurringBills facturas recurrentes',
    ];
    return parts.join(' y ');
  }
}
