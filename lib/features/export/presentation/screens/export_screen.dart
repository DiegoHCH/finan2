import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_option_card.dart';
import '../../../../core/widgets/finan2_section_label.dart';
import '../../../../core/widgets/finan2_segmented_control.dart';
import '../../../../core/widgets/finan2_tap_field.dart';
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

  bool get _includesSomething => _includeTransactions || _includeBudget || _includeDebtsAndSavings;

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
    } catch (error) {
      if (mounted) await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.exportTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.xs,
                  Finan2Space.lg,
                  Finan2Space.lg,
                ),
                children: [
                  Finan2SegmentedControl<ExportPeriod>(
                    options: {for (final period in ExportPeriod.values) period: period.label},
                    selected: _period,
                    onChanged: (period) => setState(() => _period = period),
                  ),
                  const SizedBox(height: Finan2Space.md),
                  Finan2TapField(
                    label: l10n.exportPeriod,
                    value: _periodLabel(l10n, exportMonths(_period, DateTime.now())),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2SectionLabel(l10n.exportInclude),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      Finan2Chip(
                        label: l10n.exportTransactions,
                        selected: _includeTransactions,
                        onTap: () => setState(() => _includeTransactions = !_includeTransactions),
                      ),
                      Finan2Chip(
                        label: l10n.exportBudget,
                        selected: _includeBudget,
                        onTap: () => setState(() => _includeBudget = !_includeBudget),
                      ),
                      Finan2Chip(
                        label: l10n.exportDebtsAndSavings,
                        selected: _includeDebtsAndSavings,
                        onTap: () =>
                            setState(() => _includeDebtsAndSavings = !_includeDebtsAndSavings),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2OptionCard(
                    icon: Icons.description_outlined,
                    title: l10n.exportPdfTitle,
                    subtitle: l10n.exportPdfFor,
                    selected: _format == _ExportFormat.pdf,
                    onTap: () => setState(() => _format = _ExportFormat.pdf),
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  Finan2OptionCard(
                    icon: Icons.table_chart_outlined,
                    title: l10n.exportCsvTitle,
                    subtitle: l10n.exportCsvFor,
                    tone: Finan2Tone.of(context, Finan2Palette.casa),
                    selected: _format == _ExportFormat.csv,
                    onTap: () => setState(() => _format = _ExportFormat.csv),
                  ),
                  const SizedBox(height: Finan2Space.md),
                  Text(
                    l10n.exportOnDevice,
                    style: TextStyle(fontSize: 12, height: 1.5, color: colors.inkFaint),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Finan2Space.lg,
                Finan2Space.sm,
                Finan2Space.lg,
                Finan2Space.lg,
              ),
              child: FilledButton(
                onPressed: _generating || !_includesSomething ? null : _generate,
                child: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.exportAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Octubre 2026», «Agosto – octubre 2026» or «Noviembre 2025 – octubre
/// 2026».
String _periodLabel(AppLocalizations l10n, List<({int year, int month})> months) {
  final locale = l10n.localeName;
  final first = DateTime(months.first.year, months.first.month);
  final last = DateTime(months.last.year, months.last.month);
  final withYear = DateFormat('MMMM y', locale);
  if (first == last) return capitalizeFirst(withYear.format(last));
  final from = first.year == last.year
      ? DateFormat.MMMM(locale).format(first)
      : withYear.format(first);
  return capitalizeFirst(l10n.exportPeriodRange(from, withYear.format(last)));
}
