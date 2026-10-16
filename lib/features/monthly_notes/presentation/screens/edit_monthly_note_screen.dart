import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../l10n/l10n.dart';

/// One sheet to write on: plain text, no formatting, no lists - read like a
/// note on the fridge. Shared by both of a month's notes.
class EditMonthlyNoteScreen extends StatefulWidget {
  const EditMonthlyNoteScreen({
    required this.title,
    required this.initialText,
    required this.onSave,
    super.key,
  });

  final String title;
  final String initialText;
  final Future<void> Function(String text) onSave;

  @override
  State<EditMonthlyNoteScreen> createState() => _EditMonthlyNoteScreenState();
}

class _EditMonthlyNoteScreenState extends State<EditMonthlyNoteScreen> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await widget.onSave(_controller.text.trim());
    } catch (error) {
      if (mounted) await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Scaffold(
      appBar: Finan2FormTop(title: widget.title, onSave: _save, closeIcon: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          Finan2Space.lg,
          Finan2Space.sm,
          Finan2Space.lg,
          Finan2Space.lg,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _controller,
            autofocus: widget.initialText.isEmpty,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            style: TextStyle(fontSize: 14, height: 1.6, color: colors.ink),
            decoration: InputDecoration(
              hintText: context.l10n.monthlyNotesHint,
              hintStyle: TextStyle(color: colors.inkFaint),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isCollapsed: true,
            ),
          ),
        ),
      ),
    );
  }
}
