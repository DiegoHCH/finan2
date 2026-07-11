import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A settings/list row matching the mockup's `.set-row`: small icon tile,
/// label, optional trailing value, and a chevron when tappable.
class Finan2ListRow extends StatelessWidget {
  const Finan2ListRow({
    required this.icon,
    required this.label,
    this.iconBackground,
    this.iconColor,
    this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? iconBackground;
  final Color? iconColor;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBackground ?? colors.surfaceAlt,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: iconColor ?? colors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.inkFaint,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: colors.inkFaint),
            ],
          ],
        ),
      ),
    );
  }
}

/// The bordered, rounded card that groups [Finan2ListRow]s with dividers
/// between them, matching `.set-list`.
class Finan2ListCard extends StatelessWidget {
  const Finan2ListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Finan2Radius.card),
        border: Border.all(color: colors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.line),
            children[i],
          ],
        ],
      ),
    );
  }
}
