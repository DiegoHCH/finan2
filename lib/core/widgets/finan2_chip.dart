import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A pill chip matching the mockup's `.catchip`/`.catchip.on`: unselected is
/// a filled surface pill with soft text, selected gets a brand-tinted
/// background, brand border and brand-colored text/icon.
class Finan2Chip extends StatelessWidget {
  const Finan2Chip({this.label, required this.selected, required this.onTap, this.icon, super.key})
    : assert(label != null || icon != null, 'Provide a label and/or icon');

  final String? label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colors.brandTint : Theme.of(context).colorScheme.surface,
          border: Border.all(color: selected ? brand : colors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? brand : colors.inkSoft),
              if (label != null) const SizedBox(width: 5),
            ],
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? brand : colors.inkSoft,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
