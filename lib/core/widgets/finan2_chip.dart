import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';

/// The redesign's `.chip`: unselected is an outline with soft text; selected
/// fills with [tone]'s tint and takes its color - a category's, a member's,
/// or the accent when there's none. [removable] adds a trailing ✕, for a
/// filter that's on and comes off with a tap.
class Finan2Chip extends StatelessWidget {
  const Finan2Chip({
    this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tone,
    this.removable = false,
    super.key,
  }) : assert(label != null || icon != null, 'Provide a label and/or icon');

  final String? label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Finan2Tone? tone;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final on = tone ?? Finan2Tone(Theme.of(context).colorScheme.primary, colors.brandTint);
    final foreground = selected ? on.color : colors.inkSoft;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? on.tint : null,
            border: Border.all(color: selected ? on.tint : colors.line),
            borderRadius: BorderRadius.circular(Finan2Radius.chip),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: foreground),
                if (label != null) const SizedBox(width: 6),
              ],
              if (label != null)
                Flexible(
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              if (removable) ...[
                const SizedBox(width: 5),
                Icon(Icons.close, size: 13, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
