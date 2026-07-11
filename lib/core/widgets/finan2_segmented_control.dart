import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A pill-shaped segmented control matching the mockup's `.seg`: one
/// continuous rounded track, the active segment gets a raised surface
/// background instead of a separate outlined chip per option.
class Finan2SegmentedControl<T> extends StatelessWidget {
  const Finan2SegmentedControl({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: entry.key == selected
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: entry.key == selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: entry.key == selected ? brand : colors.inkSoft,
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
