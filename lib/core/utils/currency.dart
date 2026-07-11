import 'package:intl/intl.dart';

final NumberFormat _copFormat = NumberFormat.decimalPattern('es_CO');

/// Formats whole pesos as "$1.234.567", matching the mockup's COP style.
///
/// Uses a plain decimal pattern with the "$" prepended manually instead of
/// NumberFormat.currency, since the es_CO currency pattern places the
/// symbol *after* the number ("150.000 $") instead of before it.
String formatCop(num amount) => '\$${_copFormat.format(amount)}';
