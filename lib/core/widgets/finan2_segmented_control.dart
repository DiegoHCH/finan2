import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';

/// The redesign's `.seg`: one sunken track, the active option lifted onto
/// the surface tone (no shadow, no outline). [dots] optionally puts a color
/// dot before an option's label - Gasto/Ingreso, or who paid - and [tones]
/// paints an option, once chosen, in its own tint and color (a member's).
class Finan2SegmentedControl<T> extends StatelessWidget {
  const Finan2SegmentedControl({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.dots = const {},
    this.tones = const {},
    super.key,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final Map<T, Color> dots;
  final Map<T, Finan2Tone> tones;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: colors.surfaceAlt, borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: entry.key == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: entry.key == selected ? (tones[entry.key]?.tint ?? surface) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (dots[entry.key] case final dot?) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: entry.key == selected
                                  ? (tones[entry.key]?.color ?? colors.ink)
                                  : colors.inkSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
