import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A household invite code, the redesign's `.code`: large, monospaced and
/// spaced out on the sheet, so it reads character by character and the O
/// never passes for a 0.
class Finan2CodeBox extends StatelessWidget {
  const Finan2CodeBox({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: Finan2Type.code.copyWith(fontSize: 26, letterSpacing: 3.1, color: colors.ink),
      ),
    );
  }
}
