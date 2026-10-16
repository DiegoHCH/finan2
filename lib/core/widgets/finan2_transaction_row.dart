import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';
import 'finan2_person_tag.dart';

/// The redesign's `.row`: the category tile on its own soft tone,
/// description over a faint sub-label (with who paid, in their color), and
/// the signed amount in tabular figures.
class Finan2TransactionRow extends StatelessWidget {
  const Finan2TransactionRow({
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.subLabel,
    this.avatarLabel,
    this.avatarIndex,
    required this.amountText,
    required this.amountColor,
    this.tags = const [],
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String description;
  final String subLabel;
  final String? avatarLabel;
  final int? avatarIndex;
  final String amountText;
  final Color amountColor;

  /// Shown after the sub-label as small `.tag` pills, without the «#».
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final avatarIndex = this.avatarIndex;
    final avatarLabel = this.avatarLabel;
    final tone = Finan2Tone.of(context, iconColor);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Icon(icon, size: 19, color: tone.color),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (avatarLabel != null && avatarIndex != null) ...[
                        Finan2PersonTag(label: avatarLabel, memberIndex: avatarIndex),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          subLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: colors.inkFaint),
                        ),
                      ),
                      for (final tag in tags.take(2)) ...[
                        const SizedBox(width: 6),
                        Flexible(child: _Tag('#$tag')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amountText,
              style: Finan2Type.money.copyWith(
                fontSize: 15,
                letterSpacing: -0.15,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The `.tag` pill: a free label on the sunken tone.
class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: colors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.inkSoft),
      ),
    );
  }
}
