import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The redesign's `.cardvis`: the credit card being set up, drawn as a card
/// - the only one in the app, because here it is an object. Its name, its
/// limit and its two days, filled in as they're typed.
class CardPreview extends StatelessWidget {
  const CardPreview({
    required this.name,
    required this.limitLabel,
    required this.limitText,
    required this.daysText,
    super.key,
  });

  final String name;
  final String limitLabel;
  final String limitText;
  final String daysText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = colors.onHero;
    final faint = ink.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? Finan2Palette.cardFaceDark : Finan2Palette.cardFaceLight,
          stops: dark ? const [0, 0.6, 1] : const [0, 0.48, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ink.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),
          Text(limitLabel, style: TextStyle(fontSize: 11, color: faint)),
          Text(
            limitText,
            maxLines: 1,
            style: Finan2Type.money.copyWith(fontSize: 24, letterSpacing: -0.5, color: ink),
          ),
          const SizedBox(height: 18),
          Text(daysText, style: TextStyle(fontSize: 11, color: faint)),
        ],
      ),
    );
  }
}
