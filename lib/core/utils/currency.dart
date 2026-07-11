import 'package:intl/intl.dart';

final NumberFormat _copFormat = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
);

/// Formats whole pesos as "$1.234.567", matching the mockup's COP style.
String formatCop(num amount) => _copFormat.format(amount);
