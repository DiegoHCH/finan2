import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';

/// One of a few big choices, the redesign's `.opt`: an icon tile, title and
/// a line under it. The chosen one takes the violet border on the accent
/// tint; the rest sit on the plain sheet.
class Finan2OptionCard extends StatelessWidget {
  const Finan2OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.tone,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// The icon's color and tile; the accent's by default.
  final Finan2Tone? tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final surface = Theme.of(context).colorScheme.surface;
    final accent = Theme.of(context).colorScheme.primary;
    final tone = this.tone ?? Finan2Tone(accent, colors.brandTint);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: selected ? accent : Colors.transparent, width: 1.5),
    );

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? colors.brandTint : surface,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // On the tint, the tile turns to the sheet so it still
                    // stands out.
                    color: selected ? surface : tone.tint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: tone.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, height: 1.35, color: colors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
