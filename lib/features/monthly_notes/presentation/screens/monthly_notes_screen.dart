import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../viewmodels/monthly_notes_providers.dart';
import 'edit_monthly_note_screen.dart';

class MonthlyNotesScreen extends ConsumerWidget {
  const MonthlyNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(currentMonthNotesProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM().format(now);
    final monthLabelCap = '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Notas',
              title: monthLabelCap,
              household: household,
              showBackButton: true,
            ),
            Expanded(
              child: notesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (notes) => ListView(
                  padding: const EdgeInsets.all(Finan2Space.xl),
                  children: [
                    _NoteCard(
                      title: 'Notas de este mes',
                      text: notes.thisMonth,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EditMonthlyNoteScreen(
                            title: 'Notas de este mes',
                            initialText: notes.thisMonth,
                            onSave: (text) => ref
                                .read(monthlyNotesControllerProvider.notifier)
                                .saveThisMonth(text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Finan2Space.lg),
                    _NoteCard(
                      title: 'Para el siguiente mes',
                      text: notes.nextMonth,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EditMonthlyNoteScreen(
                            title: 'Para el siguiente mes',
                            initialText: notes.nextMonth,
                            onSave: (text) => ref
                                .read(monthlyNotesControllerProvider.notifier)
                                .saveNextMonth(text),
                          ),
                        ),
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

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.text, required this.onTap});

  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Finan2Radius.card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Finan2Space.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: colors.line),
          borderRadius: BorderRadius.circular(Finan2Radius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (lines.isEmpty)
              Text(
                'Toca para agregar notas.',
                style: TextStyle(fontSize: 12.5, color: colors.inkFaint),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              line,
                              style: TextStyle(fontSize: 12.5, height: 1.4, color: colors.inkSoft),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
