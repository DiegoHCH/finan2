import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// The redesign's `.amount`: the one thing always typed, centered in the
/// largest type with its currency sign at half size and faint. No border.
class Finan2AmountInput extends StatelessWidget {
  const Finan2AmountInput({
    required this.controller,
    this.autofocus = false,
    this.currencySymbol = '\$',
    this.style,
    super.key,
  });

  final TextEditingController controller;
  final bool autofocus;
  final String currencySymbol;

  /// Defaults to displayLarge (54).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final figure = style ?? Theme.of(context).textTheme.displayLarge!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(currencySymbol, style: Finan2Type.currencyOf(figure, colors.inkFaint)),
        const SizedBox(width: 2),
        Flexible(
          child: IntrinsicWidth(
            child: TextFormField(
              controller: controller,
              autofocus: autofocus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: figure,
              cursorColor: Theme.of(context).colorScheme.primary,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '0',
                hintStyle: figure.copyWith(color: colors.line),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
