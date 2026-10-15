import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Renders "Finan2" with the "2" always in the gold accent color, per the
/// mockup's brand rule (`<span style="color:var(--gold)">2</span>`).
class Finan2Wordmark extends StatelessWidget {
  const Finan2Wordmark({this.prefix = 'Finan', this.style, super.key});

  final String prefix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: '2',
            style: TextStyle(color: colors.saving),
          ),
        ],
      ),
    );
  }
}
