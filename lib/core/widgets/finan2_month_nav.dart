import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// «‹ Octubre 2026 ›» as a head's over-line; the period comes back to today
/// with a tap while browsing another.
class Finan2MonthNav extends StatelessWidget {
  const Finan2MonthNav({
    required this.label,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
    super.key,
  });

  final String label;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    Widget arrow(IconData icon, String tooltip, VoidCallback onTap) => Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 16,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(icon, size: 18, color: colors.inkFaint),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(Icons.chevron_left, previousTooltip, onPrevious),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onReset,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: label),
                if (onReset != null)
                  TextSpan(
                    text: ' · ${context.l10n.corePeriodBackToToday}',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
              ],
            ),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.inkFaint),
          ),
        ),
        arrow(Icons.chevron_right, nextTooltip, onNext),
      ],
    );
  }
}
