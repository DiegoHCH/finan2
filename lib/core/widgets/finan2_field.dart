import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A labeled text field matching the design mockup's `.field`: a bordered
/// box with a small uppercase label above the value, instead of Material's
/// floating label.
class Finan2Field extends StatelessWidget {
  const Finan2Field({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.autofillHints,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Finan2Radius.field),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.inkFaint,
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator,
            autofillHints: autofillHints,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.ink,
            ),
            decoration: const InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 3),
            ),
          ),
        ],
      ),
    );
  }
}
