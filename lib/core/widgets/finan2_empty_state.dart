import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A "no data yet" state matching the mockup's `.empty-ill`/`.ob`: a soft
/// circular icon badge, heading, description and a prominent action button.
class Finan2EmptyState extends StatelessWidget {
  const Finan2EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.gold = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = gold ? colors.saving : Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: gold ? colors.savingTint : colors.brandTint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 34, color: accent),
            ),
            const SizedBox(height: Finan2Space.md),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Finan2Space.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: Finan2Space.lg),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
