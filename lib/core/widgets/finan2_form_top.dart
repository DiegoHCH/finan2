import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The form header matching the mockup's `.form-top`: "Cancelar" / title /
/// "Guardar", instead of a default AppBar.
class Finan2FormTop extends StatelessWidget implements PreferredSizeWidget {
  const Finan2FormTop({
    required this.title,
    required this.onSave,
    this.onCancel,
    super.key,
  });

  final String title;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onCancel ?? () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.inkFaint,
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onSave,
                child: Text(
                  'Guardar',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: brand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
