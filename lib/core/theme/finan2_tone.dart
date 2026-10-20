import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A foreground color and its soft tint, the pair the redesign puts on every
/// category tile, person tag and notice (`--c` and `--t` in the mockup).
@immutable
class Finan2Tone {
  const Finan2Tone(this.color, this.tint);

  /// Icon, text or bar color.
  final Color color;

  /// Background behind [color]: the same hue, faint enough to read on.
  final Color tint;

  /// The tone for a color stored as data (a category's), which is a single
  /// value picked against the light theme. In dark mode it's lifted so it
  /// reads on the dark surface, like the mockup's dark category colors.
  factory Finan2Tone.of(BuildContext context, Color base) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final color = dark ? Color.lerp(base, Colors.white, 0.4)! : base;
    return Finan2Tone(color, Color.alphaBlend(base.withValues(alpha: dark ? 0.22 : 0.13), surface));
  }

  /// The [index]th of [swatches] (wrapping around), for things that store
  /// no color of their own - goals, debts.
  factory Finan2Tone.swatch(BuildContext context, List<Color> swatches, int index) =>
      Finan2Tone.of(context, swatches[index % swatches.length]);

  /// The tone of household member [memberIndex]: 0 is the first member,
  /// anything else the second (fixed colors, R5).
  factory Finan2Tone.member(BuildContext context, int memberIndex) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return memberIndex == 0
        ? Finan2Tone(colors.userA, colors.userATint)
        : Finan2Tone(colors.userB, colors.userBTint);
  }
}
