import 'package:intl/intl.dart';

/// Supported currencies: symbol + locale (for thousands/decimal separator
/// conventions). Amounts are always stored as whole units (no cents) - see
/// [[finlab-fase2-transactions]] memory / README for why.
class CurrencyConfig {
  const CurrencyConfig({required this.symbol, required this.locale});

  final String symbol;
  final String locale;
}

const defaultCurrency = 'COP';

const currencyConfigs = <String, CurrencyConfig>{
  'COP': CurrencyConfig(symbol: '\$', locale: 'es_CO'),
  'USD': CurrencyConfig(symbol: 'US\$', locale: 'en_US'),
};

CurrencyConfig _configFor(String currencyCode) =>
    currencyConfigs[currencyCode] ?? currencyConfigs[defaultCurrency]!;

/// The currency symbol only (e.g. "$", "US$"), for prefixing an amount
/// input field.
String currencySymbolFor(String currencyCode) => _configFor(currencyCode).symbol;

/// Formats a whole-unit amount with the given currency's symbol and
/// thousands-separator convention, e.g. formatMoney(150000, 'COP') ->
/// "$150.000", formatMoney(1500, 'USD') -> "US$1,500".
String formatMoney(num amount, [String currencyCode = defaultCurrency]) {
  final config = _configFor(currencyCode);
  final formatted = NumberFormat.decimalPattern(config.locale).format(amount);
  return '${config.symbol}$formatted';
}
