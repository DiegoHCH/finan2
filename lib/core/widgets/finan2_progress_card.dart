import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bordered progress card matching the mockup's `.goal`: icon badge,
/// title/subtitle, a big percentage, a progress bar, and a foot row with
/// two values. Used by Deudas today; Metas (Fase 5) shares the same CSS
/// class in the mockup, so this is built to be reused there too.
class Finan2ProgressCard extends StatelessWidget {
  const Finan2ProgressCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.percentText,
    required this.percentColor,
    required this.progressFraction,
    required this.progressColor,
    required this.footLeft,
    required this.footRight,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String percentText;
  final Color percentColor;
  final double progressFraction;
  final Color progressColor;
  final String footLeft;
  final String footRight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;

    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(Finan2Radius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: colors.inkFaint),
                    ),
                  ],
                ),
              ),
              Text(
                percentText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: percentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressFraction.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: colors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    footLeft,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: colors.inkFaint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    footRight,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: colors.inkFaint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Finan2Radius.card),
      child: card,
    );
  }
}
