import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_month_nav.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/monthly_notes_providers.dart';
import 'edit_monthly_note_screen.dart';

/// Notas del mes: text, nothing more - what doesn't fit in numbers, read as
/// it was written. Browses month by month like Movimientos.
class MonthlyNotesScreen extends ConsumerStatefulWidget {
  const MonthlyNotesScreen({this.initialMonth, super.key});

  /// The month to open on - Movimientos passes the one it's showing.
  final YearMonth? initialMonth;

  @override
  ConsumerState<MonthlyNotesScreen> createState() => _MonthlyNotesScreenState();
}

class _MonthlyNotesScreenState extends ConsumerState<MonthlyNotesScreen> {
  late YearMonth _month = widget.initialMonth ?? currentYearMonth();

  void _edit({required String title, required String text, required bool next}) {
    final controller = ref.read(monthlyNotesControllerProvider.notifier);
    final month = _month;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditMonthlyNoteScreen(
          title: title,
          initialText: text,
          onSave: (text) async {
            if (next) {
              await controller.saveNextMonth(text, month: month);
            } else {
              await controller.saveThisMonth(text, month: month);
            }
            final result = ref.read(monthlyNotesControllerProvider);
            if (result.hasError) throw result.error!;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(monthNotesProvider(_month));
    final notes = notesAsync.value;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              title: l10n.monthlyNotesTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
              over: Finan2MonthNav(
                label: _month.label,
                previousTooltip: l10n.transactionsPreviousMonth,
                nextTooltip: l10n.transactionsNextMonth,
                onPrevious: () => setState(() => _month = _month.plusMonths(-1)),
                onNext: () => setState(() => _month = _month.plusMonths(1)),
                onReset: _month.isCurrent
                    ? null
                    : () => setState(() => _month = currentYearMonth()),
              ),
              action: notes == null
                  ? null
                  : Finan2HeadAction(
                      icon: Finan2Icons.editar,
                      tooltip: l10n.monthlyNotesWrite,
                      onTap: () => _edit(
                        title: l10n.monthlyNotesThisMonth,
                        text: notes.thisMonth,
                        next: false,
                      ),
                    ),
            ),
            Expanded(
              child: notesAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(rows: 2),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (notes) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Finan2Space.lg,
                    Finan2Space.xs,
                    Finan2Space.lg,
                    Finan2Space.xxl,
                  ),
                  children: [
                    _NoteSheet(
                      key: const Key('monthNoteThisMonth'),
                      text: notes.thisMonth,
                      onTap: () => _edit(
                        title: l10n.monthlyNotesThisMonth,
                        text: notes.thisMonth,
                        next: false,
                      ),
                    ),
                    const SizedBox(height: Finan2Space.lg),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: Finan2Space.sm),
                      child: Text(
                        l10n.monthlyNotesNextMonth,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    _NoteSheet(
                      key: const Key('monthNoteNextMonth'),
                      text: notes.nextMonth,
                      onTap: () => _edit(
                        title: l10n.monthlyNotesNextMonth,
                        text: notes.nextMonth,
                        next: true,
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

/// The note as written, paragraph by paragraph, on a plain sheet.
class _NoteSheet extends StatelessWidget {
  const _NoteSheet({required this.text, required this.onTap, super.key});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final paragraphs = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: SizedBox(
            width: double.infinity,
            child: paragraphs.isEmpty
                ? Text(
                    context.l10n.monthlyNotesEmpty,
                    style: TextStyle(fontSize: 14, height: 1.6, color: colors.inkFaint),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, paragraph) in paragraphs.indexed)
                        Padding(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                          child: Text(
                            paragraph,
                            style: TextStyle(fontSize: 14, height: 1.6, color: colors.ink),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
