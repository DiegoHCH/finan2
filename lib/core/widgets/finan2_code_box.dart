import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Displays a household invite code matching the mockup's `.codebox`: bold,
/// letter-spaced, brand-tinted pill.
class Finan2CodeBox extends StatelessWidget {
  const Finan2CodeBox({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: colors.brandTint, borderRadius: BorderRadius.circular(13)),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 6.4,
          color: brand,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
