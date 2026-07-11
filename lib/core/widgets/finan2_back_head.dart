import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A "‹ Title" header for pushed detail screens, matching the mockup's
/// `.backhead`, with an optional trailing action (e.g. edit).
class Finan2BackHead extends StatelessWidget {
  const Finan2BackHead({required this.title, this.leading, this.trailing, super.key});

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.xl,
        Finan2Space.md,
        Finan2Space.xl,
        Finan2Space.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.chevron_left, size: 26, color: colors.inkSoft),
          ),
          const SizedBox(width: 4),
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
