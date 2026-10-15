import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// The mockup's `.month-pick`: ‹ period › in a bordered pill. Tapping the
/// label jumps back to the current period when [onReset] is given (only
/// while browsing another one).
class Finan2PeriodPicker extends StatelessWidget {
  const Finan2PeriodPicker({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.onReset,
    this.previousTooltip,
    this.nextTooltip,
    super.key,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onReset;

  /// Default to a generic "previous"/"next" in the app's language.
  final String? previousTooltip;
  final String? nextTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: previousTooltip ?? context.l10n.corePeriodPrevious,
            visualDensity: VisualDensity.compact,
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left, color: colors.inkFaint),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onReset,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  if (onReset != null)
                    Text(
                      context.l10n.corePeriodBackToToday,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: nextTooltip ?? context.l10n.commonNext,
            visualDensity: VisualDensity.compact,
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: colors.inkFaint),
          ),
        ],
      ),
    );
  }
}
