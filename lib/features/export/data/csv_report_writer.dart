import 'dart:convert';

import 'package:csv/csv.dart';

import 'report_builder.dart';

class CsvReportWriter {
  const CsvReportWriter();

  /// One file per section, each a single table with a header row - what a
  /// spreadsheet or an importer can read as is. Keyed by file name.
  Map<String, List<int>> write(Report report, {required String stamp}) {
    final csv = Csv();
    return {
      for (final section in report.sections)
        'finan2_${_slug(section.title)}_$stamp.csv': [
          // BOM: without it Excel reads the accents as Latin-1.
          0xEF, 0xBB, 0xBF,
          ...utf8.encode(csv.encode([section.headers, ...section.rows])),
        ],
    };
  }
}

String _slug(String title) {
  const plain = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n'};
  return title
      .toLowerCase()
      .split('')
      .map((c) => plain[c] ?? c)
      .join()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
