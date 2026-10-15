import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/csv_report_writer.dart';
import '../../data/pdf_report_writer.dart';
import '../../data/report_builder.dart';
import '../viewmodels/export_providers.dart';

enum _ExportFormat { pdf, csv }

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  var _format = _ExportFormat.pdf;
  var _period = ExportPeriod.thisMonth;
  var _includeTransactions = true;
  var _includeBudget = true;
  var _includeDebtsAndSavings = true;
  var _generating = false;

  Future<void> _generate() async {
    final household = ref.read(currentHouseholdProvider).value;
    if (household == null) return;
    final pdfFileName = context.l10n.exportPdfFileName;
    setState(() => _generating = true);
    try {
      final report = await ref
          .read(reportBuilderProvider)
          .build(
            householdId: household.id,
            householdName: household.name,
            period: _period,
            includeTransactions: _includeTransactions,
            includeBudget: _includeBudget,
            includeDebtsAndSavings: _includeDebtsAndSavings,
            formatMoney: ref.read(moneyFormatterProvider),
            memberNames: {
              for (final entry in household.memberInfo.entries) entry.key: entry.value.name,
            },
            plainValues: _format == _ExportFormat.csv,
          );
      if (_format == _ExportFormat.pdf) {
        final bytes = await const PdfReportWriter().write(report);
        await Printing.sharePdf(bytes: bytes, filename: pdfFileName);
      } else {
        final files = const CsvReportWriter().write(
          report,
          stamp: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
        await SharePlus.instance.share(
          ShareParams(
            files: [
              for (final MapEntry(key: name, value: bytes) in files.entries)
                XFile.fromData(Uint8List.fromList(bytes), mimeType: 'text/csv', name: name),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: context.l10n.exportTitle,
              title: context.l10n.exportSubtitle,
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Finan2SegmentedControl<_ExportFormat>(
                      options: const {_ExportFormat.pdf: '📄 PDF', _ExportFormat.csv: '📊 CSV'},
                      selected: _format,
                      onChanged: (v) => setState(() => _format = v),
                    ),
                    if (_format == _ExportFormat.csv) ...[
                      const SizedBox(height: Finan2Space.sm),
                      Text(
                        context.l10n.exportCsvHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).extension<Finan2Colors>()!.inkSoft,
                        ),
                      ),
                    ],
                    const SizedBox(height: Finan2Space.lg),
                    Text(context.l10n.exportPeriod, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: Finan2Space.sm),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final period in ExportPeriod.values)
                          Finan2Chip(
                            label: period.label,
                            selected: _period == period,
                            onTap: () => setState(() => _period = period),
                          ),
                      ],
                    ),
                    const SizedBox(height: Finan2Space.lg),
                    Text(
                      context.l10n.exportInclude,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: Finan2Space.sm),
                    Finan2ListCard(
                      children: [
                        _ToggleRow(
                          icon: Icons.receipt_long_outlined,
                          label: context.l10n.exportTransactions,
                          value: _includeTransactions,
                          onChanged: (v) => setState(() => _includeTransactions = v),
                        ),
                        _ToggleRow(
                          icon: Icons.donut_large_outlined,
                          label: context.l10n.exportBudget,
                          value: _includeBudget,
                          onChanged: (v) => setState(() => _includeBudget = v),
                        ),
                        _ToggleRow(
                          icon: Icons.credit_card_outlined,
                          label: context.l10n.exportDebtsAndSavings,
                          value: _includeDebtsAndSavings,
                          onChanged: (v) => setState(() => _includeDebtsAndSavings = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: Finan2Space.lg),
                    FilledButton(
                      onPressed: _generating ? null : _generate,
                      child: _generating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _format == _ExportFormat.pdf
                                  ? context.l10n.exportGeneratePdf
                                  : context.l10n.exportGenerateCsv,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: colors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
