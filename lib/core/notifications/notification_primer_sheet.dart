import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown once, right before the OS notification permission prompt fires
/// automatically on first launch (see Finan2HomeShell) - explains what
/// notifications are for so the user isn't cold-hit with a bare system
/// dialog. Returns whether the user wants to continue to the real prompt.
Future<bool> showNotificationPrimerSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
      final brand = Theme.of(sheetContext).colorScheme.primary;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          Finan2Space.xl,
          Finan2Space.lg,
          Finan2Space.xl,
          MediaQuery.of(sheetContext).viewInsets.bottom + Finan2Space.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.brandTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Finan2Icons.notificacion, color: brand, size: Finan2Sizes.iconLg),
            ),
            const SizedBox(height: Finan2Space.md),
            Text(
              'Activa las notificaciones',
              textAlign: TextAlign.center,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: Finan2Space.xs),
            Text(
              'Te avisamos cuando tu pareja registre algo, se acerque una fecha '
              'de pago, o se pasen del presupuesto. Puedes ajustar esto después '
              'en Ajustes.',
              textAlign: TextAlign.center,
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: Finan2Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: const Text('Activar notificaciones'),
              ),
            ),
            const SizedBox(height: Finan2Space.xs),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(false),
              child: const Text('Ahora no'),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
