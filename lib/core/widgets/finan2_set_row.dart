import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';
import 'finan2_tile.dart';

/// The redesign's `.set`: a line of a sheet that's a setting - an optional
/// icon (on its [tone]'s tile, or bare without one), the label with an
/// optional line under it, a faint value and a chevron when it leads
/// somewhere, or a [trailing] control such as a switch.
class Finan2SetRow extends StatelessWidget {
  const Finan2SetRow({
    required this.label,
    this.icon,
    this.tone,
    this.detail,
    this.value,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData? icon;

  /// Draws [icon] on its tile, in a color of its own to find the row
  /// without reading.
  final Finan2Tone? tone;

  /// The `.sub2` under the label: what the setting means, or when.
  final String? detail;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final icon = this.icon;
    final tone = this.tone;
    final detail = this.detail;
    final value = this.value;
    final trailing = this.trailing;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                if (tone != null)
                  Finan2Tile(icon: icon, tone: tone, size: 32)
                else
                  Icon(icon, size: 18, color: colors.inkSoft),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: colors.inkFaint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.inkFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing,
              ] else if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Finan2Icons.chevron, size: 18, color: colors.inkFaint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
