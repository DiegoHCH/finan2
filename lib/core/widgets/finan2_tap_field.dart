import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Same look as [Finan2Field] (label above, value below, bordered box) but
/// for a read-only or tap-to-pick value instead of free text - e.g. account
/// picker, date picker, "registrado por".
class Finan2TapField extends StatelessWidget {
  const Finan2TapField({
    required this.label,
    required this.value,
    this.leading,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Finan2Radius.field),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 9)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Finan2Radius.field),
      child: content,
    );
  }
}
