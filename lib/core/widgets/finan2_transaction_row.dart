import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single transaction row matching the mockup's `.tx`: icon tile,
/// description + sub-label (with a mini avatar for who registered it), and
/// the signed amount.
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final avatarIndex = this.avatarIndex;
    final avatarLabel = this.avatarLabel;
    final avatarColor = avatarIndex == 0 ? colors.userA : colors.userB;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: colors.line),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: iconColor),
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
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (avatarLabel != null && avatarIndex != null) ...[
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            avatarLabel,
                            style: TextStyle(
                              color: colors.onAccent,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(subLabel, style: TextStyle(fontSize: 11, color: colors.inkFaint)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
