import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Placeholder tab body for features not built yet (Deudas, Metas).
class Finan2ComingSoon extends StatelessWidget {
  const Finan2ComingSoon({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.brandTint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: Finan2Space.md),
            Text('Próximamente', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Finan2Space.xs),
            Text(
              'Esta sección todavía no está lista.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
