import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The redesign's `.hd`: a small faint line over the screen's title in the
/// large type, and at most one square action on the right. No decorative
/// avatars. [over] replaces the faint line with a widget - Movimientos puts
/// its ‹ month › there.
class Finan2Head extends StatelessWidget {
  const Finan2Head({
    required this.title,
    this.overLabel,
    this.over,
    this.action,
    this.onBack,
    super.key,
  });

  final String title;
  final String? overLabel;
  final Widget? over;
  final Finan2HeadAction? action;

  /// Shows a back chevron before the title, for pushed screens.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final overWidget =
        over ??
        (overLabel == null
            ? null
            : Text(
                overLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.inkFaint),
              ));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.xl,
        Finan2Space.md,
        Finan2Space.xl,
        Finan2Space.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 1),
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: onBack,
                icon: Icon(Icons.chevron_left, size: 28, color: colors.inkSoft),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ?overWidget,
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          if (action case final action?) ...[const SizedBox(width: Finan2Space.sm), action],
        ],
      ),
    );
  }
}

/// The `.hd .act` square: a 38px sunken tile with one icon, and an optional
/// count badge.
class Finan2HeadAction extends StatelessWidget {
  const Finan2HeadAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
    this.highlighted = false,
    this.filled = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  /// Draws the icon in the accent - something behind it is on.
  final bool highlighted;

  /// The accent tile with the icon on it - the screen's one action, like
  /// the «+» of Cuentas.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final (background, foreground) = filled
        ? (accent, colors.onAccent)
        : highlighted
        ? (colors.brandTint, accent)
        : (colors.surfaceAlt, colors.inkSoft);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Badge(
                isLabelVisible: badge > 0,
                label: Text('$badge'),
                backgroundColor: accent,
                textColor: colors.onAccent,
                child: Icon(icon, size: 20, color: foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
