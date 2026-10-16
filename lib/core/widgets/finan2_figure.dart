import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The redesign's `.figure`: the screen's one number as type, not a card -
/// a soft label, the amount big with its currency sign at half size and
/// faint, and an optional line underneath.
class Finan2Figure extends StatelessWidget {
  const Finan2Figure({
    this.label,
    required this.amountText,
    this.subtitle,
    this.amountColor,
    this.fontSize,
    this.centered = false,
    this.money = true,
    super.key,
  });

  final String? label;

  /// Already formatted, e.g. `$4.742.000` or `−$38.000`: everything before
  /// the first digit is drawn as the small sign.
  final String amountText;
  final Widget? subtitle;
  final Color? amountColor;

  /// Overrides displayMedium's 46 - the Plan screens use a smaller figure.
  final double? fontSize;

  /// Centers everything, as on a detail screen.
  final bool centered;

  /// When false, [amountText] is words («marzo 2027»): no small sign.
  final bool money;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final figure = Theme.of(
      context,
    ).textTheme.displayMedium!.copyWith(color: amountColor, fontSize: fontSize);
    final split = money ? amountText.indexOf(RegExp(r'\d')) : -1;
    final sign = split > 0 ? amountText.substring(0, split) : '';
    final digits = split > 0 ? amountText.substring(split) : amountText;

    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (label case final label?) ...[
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.inkSoft),
          ),
          const SizedBox(height: 2),
        ],
        Text.rich(
          TextSpan(
            children: [
              if (sign.isNotEmpty)
                TextSpan(text: sign, style: Finan2Type.currencyOf(figure, colors.inkFaint)),
              TextSpan(text: digits, style: figure),
            ],
          ),
          maxLines: 1,
          textAlign: centered ? TextAlign.center : null,
        ),
        if (subtitle case final subtitle?) ...[
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12.5, color: colors.inkSoft),
            textAlign: centered ? TextAlign.center : null,
            child: subtitle,
          ),
        ],
      ],
    );
  }
}
