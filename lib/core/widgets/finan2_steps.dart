import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The redesign's `.steps`: one thin bar per step, the ones already reached
/// in the accent - how far along a short setup is, at a glance.
class Finan2Steps extends StatelessWidget {
  const Finan2Steps({required this.reached, required this.total, super.key});

  /// How many bars are lit, counting the current step.
  final int reached;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < reached ? accent : colors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
