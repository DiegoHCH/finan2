import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bordered box with a small uppercase label and a big value below,
/// matching the mockup's `.stat`. Used for the Dashboard's Ingresos/Gastos
/// duo (with [dotColor]) and for 3-column `.trio` rows (Debt detail,
/// Resumen anual) via [dense].
class Finan2StatBox extends StatelessWidget {
  const Finan2StatBox({
    required this.label,
    required this.value,
    this.valueColor,
    this.dotColor,
    this.dense = false,
    super.key,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Color? dotColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 13,
        vertical: dense ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(dense ? 15 : 15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: colors.inkFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: dense ? 13.5 : 16.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: valueColor ?? colors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
