import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The redesign's `.sheet`: the one container, set apart by tone instead of
/// a shadow or a border, with a 1px rule between its rows. A
/// [Finan2SheetHeading] starts a group and isn't ruled off.
class Finan2Sheet extends StatelessWidget {
  const Finan2Sheet({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0 && children[i] is! Finan2SheetHeading)
              Divider(height: 1, thickness: 1, color: colors.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// The `.day` heading inside a sheet: a label in faint capitals and a
/// figure on the right - a day and its net, in Movimientos.
class Finan2SheetHeading extends StatelessWidget {
  const Finan2SheetHeading({required this.label, this.trailing, super.key});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.66,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label.toUpperCase(), style: style)),
          if (trailing case final trailing?) Text(trailing, style: style),
        ],
      ),
    );
  }
}
