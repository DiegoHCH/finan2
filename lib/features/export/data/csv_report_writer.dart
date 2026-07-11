import 'dart:convert';

import 'package:csv/csv.dart';

import 'report_builder.dart';

class CsvReportWriter {
  const CsvReportWriter();

  List<int> write(Report report) {
    final buffer = StringBuffer()
      ..writeln(report.title)
      ..writeln(report.subtitle)
      ..writeln();
    final csv = Csv();
    for (final section in report.sections) {
      buffer
        ..writeln(section.title)
        ..write(csv.encode([section.headers, ...section.rows]))
        ..writeln()
        ..writeln();
    }
    return utf8.encode(buffer.toString());
  }
}
