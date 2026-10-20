import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';
import 'finan2_tile.dart';

/// The redesign's `.state`: a screen with nothing to show says what will
/// show up here and offers the way to start - a glyph on its tone, a title,
/// one line and the action, with an optional second way out under it.
///
/// [celebrates] is the same page in another tone, for an empty that's
/// good news (no debts): the glyph goes green and the action becomes a
/// quiet button, because there's no hurry.
///
/// Fills the height it's given and centers in it; in an unbounded parent
/// (a sheet, a list) it just takes its own height.
class Finan2EmptyState extends StatelessWidget {
  const Finan2EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.tone,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryAsButton = false,
    this.celebrates = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  /// The glyph's color and tint; the violet of the action when null, green
  /// when it [celebrates].
  final Finan2Tone? tone;

  final String? actionLabel;
  final VoidCallback? onAction;

  /// The second way out: a quiet link by default (the mockup's `.link`),
  /// or a quiet button when it's as real a path as the first
  /// ([secondaryAsButton]).
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool secondaryAsButton;

  final bool celebrates;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final scheme = Theme.of(context).colorScheme;
    final glyphTone =
        tone ??
        (celebrates
            ? Finan2Tone(colors.income, colors.incomeTint)
            : Finan2Tone(scheme.primary, colors.brandTint));
    final actionLabel = this.actionLabel;
    final secondaryLabel = this.secondaryLabel;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Finan2Tile(icon: icon, tone: glyphTone, size: 64),
        ),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(description, style: TextStyle(fontSize: 14, height: 1.5, color: colors.inkSoft)),
        if (actionLabel != null) ...[
          const SizedBox(height: 18),
          if (celebrates)
            OutlinedButton(onPressed: onAction, child: Text(actionLabel))
          else
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
        if (secondaryLabel != null) ...[
          SizedBox(height: secondaryAsButton ? Finan2Space.sm : Finan2Space.xxs),
          if (secondaryAsButton)
            OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel))
          else
            TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(
                foregroundColor: colors.inkSoft,
                textStyle: const TextStyle(
                  fontFamily: Finan2Type.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(secondaryLabel),
            ),
        ],
      ],
    );

    // The mockup's `padding-bottom: 30px`: a touch above the middle.
    const padding = EdgeInsets.fromLTRB(Finan2Space.lg, Finan2Space.lg, Finan2Space.lg, 48);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Padding(padding: padding, child: content);
        }
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - padding.vertical).clamp(0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content],
            ),
          ),
        );
      },
    );
  }
}
