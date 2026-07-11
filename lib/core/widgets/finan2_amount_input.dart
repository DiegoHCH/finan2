import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// The big centered amount field matching the mockup's `.amount-in`: a small
/// "$" prefix next to a large bold number, no visible border.
class Finan2AmountInput extends StatelessWidget {
  const Finan2AmountInput({
    required this.controller,
    this.autofocus = false,
    this.currencySymbol = '\$',
    super.key,
  });

  final TextEditingController controller;
  final bool autofocus;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '$currencySymbol ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.inkFaint,
            ),
          ),
        ),
        IntrinsicWidth(
          child: TextFormField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
