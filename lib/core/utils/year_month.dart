import 'package:intl/intl.dart';

/// A calendar month. Records compare by value, so this works as a provider
/// family key.
typedef YearMonth = ({int year, int month});

YearMonth yearMonthOf(DateTime date) => (year: date.year, month: date.month);

YearMonth currentYearMonth() => yearMonthOf(DateTime.now());

extension YearMonthX on YearMonth {
  YearMonth plusMonths(int months) => yearMonthOf(DateTime(year, month + months));

  bool get isCurrent => this == currentYearMonth();

  /// "Julio 2026".
  String get label {
    final text = DateFormat('MMMM y').format(DateTime(year, month));
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// "Julio".
  String get monthLabel {
    final text = DateFormat.MMMM().format(DateTime(year, month));
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
