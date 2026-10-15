import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_builder.dart';

class PdfReportWriter {
  const PdfReportWriter();

  Future<Uint8List> write(Report report) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(report.title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            report.subtitle,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          for (final section in report.sections) ...[
            pw.Text(
              section.title,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            if (section.rows.isEmpty)
              pw.Text(
                'Sin datos para este período.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: section.headers,
                data: section.rows,
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            pw.SizedBox(height: 18),
          ],
        ],
      ),
    );
    return doc.save();
  }
}
