import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import 'finan2_amount_input.dart';

/// A labeled text field matching the design mockup's `.field`: a bordered
/// box with a small uppercase label above the value, instead of Material's
/// floating label. Password fields (`obscureText: true`) get a show/hide
/// eye toggle.
class Finan2Field extends StatefulWidget {
  const Finan2Field({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.autofillHints,
    this.maxLines = 1,
    this.moneySymbol,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final int maxLines;

  /// Makes it a money field: digits grouped as they're typed, after this
  /// currency sign. Read it with [Finan2AmountInput.parse].
  final String? moneySymbol;

  @override
  State<Finan2Field> createState() => _Finan2FieldState();
}

class _Finan2FieldState extends State<Finan2Field> {
  late bool _obscured = widget.obscureText;
  late final _money = widget.moneySymbol == null
      ? null
      : Finan2GroupedDigitsFormatter(NumberFormat.decimalPattern(Intl.getCurrentLocale()));

  @override
  void initState() {
    super.initState();
    // A prefilled amount (editing) comes in as plain digits.
    if (_money case final money?) {
      final value = widget.controller.value;
      final grouped = money.formatEditUpdate(value, value);
      if (grouped.text != value.text) widget.controller.value = grouped;
    }
  }

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
            widget.label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.inkFaint,
            ),
          ),
          TextFormField(
            controller: widget.controller,
            obscureText: _obscured,
            keyboardType: _money != null ? TextInputType.number : widget.keyboardType,
            inputFormatters: [?_money],
            textCapitalization: widget.textCapitalization,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink),
            decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 3),
              prefixText: widget.moneySymbol,
              prefixStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colors.inkFaint,
              ),
              suffixIconConstraints: const BoxConstraints(),
              suffixIcon: widget.obscureText
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _obscured = !_obscured),
                        child: Icon(
                          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: colors.inkFaint,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
