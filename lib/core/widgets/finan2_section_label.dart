import 'package:flutter/material.dart';

/// The redesign's `.lbl`: a small uppercase faint label over a group of
/// chips or a segmented control in a form or a sheet.
class Finan2SectionLabel extends StatelessWidget {
  const Finan2SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
