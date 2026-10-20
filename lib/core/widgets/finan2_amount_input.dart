import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// The redesign's `.amount`: the one thing always typed, centered in the
/// largest type with its currency sign at half size and faint. No border.
///
/// Digits are grouped as they're typed (`1.250.000` in Spanish), so read the
/// value with [Finan2AmountInput.parse], not `int.tryParse`.
class Finan2AmountInput extends StatefulWidget {
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

  /// The whole amount in [text], ignoring group separators; null if empty.
  static int? parse(String text) => int.tryParse(text.replaceAll(RegExp(r'\D'), ''));

  @override
  State<Finan2AmountInput> createState() => _Finan2AmountInputState();
}

class _Finan2AmountInputState extends State<Finan2AmountInput> {
  late final _formatter = Finan2GroupedDigitsFormatter(
    NumberFormat.decimalPattern(Intl.getCurrentLocale()),
  );

  @override
  void initState() {
    super.initState();
    // A prefilled amount (editing) comes in as plain digits.
    final value = widget.controller.value;
    final grouped = _formatter.formatEditUpdate(value, value);
    if (grouped.text != value.text) widget.controller.value = grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final figure = widget.style ?? Theme.of(context).textTheme.displayLarge!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(widget.currencySymbol, style: Finan2Type.currencyOf(figure, colors.inkFaint)),
        const SizedBox(width: 2),
        Flexible(
          child: IntrinsicWidth(
            child: TextFormField(
              controller: widget.controller,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              inputFormatters: [_formatter],
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

/// Keeps only digits and groups them with [format]'s separator, leaving the
/// cursor after the same number of digits it was after. Shared with
/// [Finan2Field]'s money fields.
class Finan2GroupedDigitsFormatter extends TextInputFormatter {
  Finan2GroupedDigitsFormatter(this.format);

  final NumberFormat format;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final value = int.tryParse(digits);
    if (value == null) return oldValue; // past int range
    final text = format.format(value);

    final cursor = newValue.selection.isValid ? newValue.selection.end : newValue.text.length;
    final digitsBeforeCursor = newValue.text
        .substring(0, cursor.clamp(0, newValue.text.length))
        .replaceAll(RegExp(r'\D'), '')
        .length;
    var offset = 0;
    for (var seen = 0; offset < text.length && seen < digitsBeforeCursor; offset++) {
      if (RegExp(r'\d').hasMatch(text[offset])) seen++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
