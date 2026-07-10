import 'package:flutter/material.dart';

/// A column that's vertically centered when it fits the available height,
/// but becomes scrollable instead of overflowing once it doesn't (e.g. when
/// the keyboard opens on a form screen).
class Finan2CenteredForm extends StatelessWidget {
  const Finan2CenteredForm({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.key,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: crossAxisAlignment,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
