import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';

/// Generic full-screen text editor shared by both note sections ("Notas de
/// este mes" / "Para el siguiente mes") - just a title, a multiline field,
/// and a save callback.
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
    await widget.onSave(_controller.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Finan2FormTop(title: widget.title, onSave: _save),
      body: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Finan2Field(
          label: 'Notas',
          controller: _controller,
          maxLines: 12,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }
}
