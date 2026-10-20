import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum Finan2NoticeKind {
  /// Something happening now: the accent tint.
  now,

  /// Something went over: the over tint, the only time red shows.
  over,

  /// Worth knowing, nothing to do: the sunken tone.
  calm,
}

/// The redesign's `.now`: a filled notice with an icon, a bold line over a
/// short explanation, and an optional action word on the right.
class Finan2Notice extends StatelessWidget {
  const Finan2Notice({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onTap,
    this.kind = Finan2NoticeKind.now,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onTap;
  final Finan2NoticeKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final (background, foreground) = switch (kind) {
      Finan2NoticeKind.now => (colors.brandTint, accent),
      Finan2NoticeKind.over => (colors.expenseTint, colors.expense),
      Finan2NoticeKind.calm => (colors.surfaceAlt, colors.inkSoft),
    };

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: colors.ink,
                      ),
                    ),
                    if (message case final message?)
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, height: 1.4, color: colors.ink),
                      ),
                  ],
                ),
              ),
              if (actionLabel case final actionLabel?) ...[
                const SizedBox(width: 11),
                Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: kind == Finan2NoticeKind.calm ? colors.inkSoft : foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
