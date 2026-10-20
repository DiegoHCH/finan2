import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A screen that asks one thing: an optional [top] line (a back arrow, the
/// setup's steps), the question in large type with a short explanation,
/// what answers it, and the [actions] at the bottom, within the thumb's
/// reach (the mockup's `margin-top:auto`). Scrolls when the keyboard
/// leaves it short.
class Finan2PromptPage extends StatelessWidget {
  const Finan2PromptPage({
    required this.title,
    this.top,
    this.over,
    this.message,
    this.children = const [],
    this.actions = const [],
    super.key,
  });

  final Widget? top;

  /// A faint line over the title - «Paso 2 de 3».
  final String? over;
  final String title;
  final String? message;
  final List<Widget> children;

  /// Stacked full width; the first is usually the screen's one violet button.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (top case final top?)
            Padding(
              padding: const EdgeInsets.fromLTRB(Finan2Space.lg, Finan2Space.md, Finan2Space.lg, 0),
              child: top,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Finan2Space.lg,
                Finan2Space.lg,
                Finan2Space.lg,
                Finan2Space.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (over case final over?) ...[
                    Text(
                      over,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.inkFaint,
                      ),
                    ),
                    const SizedBox(height: Finan2Space.xxs),
                  ],
                  Text(title, style: textTheme.headlineMedium),
                  if (message case final message?) ...[
                    const SizedBox(height: Finan2Space.sm),
                    Text(
                      message,
                      style: TextStyle(fontSize: 14, height: 1.5, color: colors.inkSoft),
                    ),
                  ],
                  if (children.isNotEmpty) const SizedBox(height: Finan2Space.lg),
                  ...children,
                ],
              ),
            ),
          ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(Finan2Space.lg, 0, Finan2Space.lg, Finan2Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(height: Finan2Space.sm),
                    actions[i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
