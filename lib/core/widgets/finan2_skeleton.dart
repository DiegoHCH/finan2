import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';
import 'finan2_sheet.dart';

/// «La forma antes que el dato»: while a screen's figures load it's drawn
/// with their shape - the mockup's `.skel` bars - instead of a spinner.
/// The bars under it breathe gently together (the words around them stay
/// put), and hold still when the system asks for less motion.
class Finan2Skeleton extends StatefulWidget {
  const Finan2Skeleton({required this.child, this.semanticsLabel, super.key});

  final Widget child;

  /// What a screen reader says instead of the bars - «Cargando».
  final String? semanticsLabel;

  @override
  State<Finan2Skeleton> createState() => _Finan2SkeletonState();
}

class _Finan2SkeletonState extends State<Finan2Skeleton> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _opacity = Tween<double>(
    begin: 1,
    end: 0.55,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      container: true,
      child: _SkeletonPulse(opacity: _opacity, child: widget.child),
    );
  }
}

class _SkeletonPulse extends InheritedWidget {
  const _SkeletonPulse({required this.opacity, required super.child});

  final Animation<double> opacity;

  static Widget wrap(BuildContext context, Widget bar) {
    final pulse = context.dependOnInheritedWidgetOfExactType<_SkeletonPulse>();
    return pulse == null ? bar : FadeTransition(opacity: pulse.opacity, child: bar);
  }

  @override
  bool updateShouldNotify(_SkeletonPulse oldWidget) => oldWidget.opacity != opacity;
}

/// One `.skel` bar: a figure or a line of text that hasn't arrived yet.
class Finan2SkeletonBar extends StatelessWidget {
  const Finan2SkeletonBar({this.width, this.widthFactor, this.height = 12, this.radius, super.key});

  final double? width;

  /// A share of the available width, for a line of text.
  final double? widthFactor;
  final double height;

  /// Half the [height] when null.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius ?? height / 2),
      ),
    );
    final widthFactor = this.widthFactor;
    final pulsing = _SkeletonPulse.wrap(context, bar);
    if (widthFactor == null) return pulsing;
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: pulsing,
    );
  }
}

/// A row that hasn't arrived: the tile's square, a name and a line under
/// it, and the amount on the right - the shape of every list row.
class Finan2SkeletonRow extends StatelessWidget {
  const Finan2SkeletonRow({this.seed = 0, super.key});

  /// Varies the widths so a column of them doesn't read as a grid.
  final int seed;

  static const _name = [0.6, 0.48, 0.55, 0.42];
  static const _sub = [0.35, 0.3, 0.4, 0.26];
  static const _amount = [60.0, 52.0, 70.0, 58.0];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final i = seed % _name.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          _SkeletonPulse.wrap(
            context,
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Finan2SkeletonBar(widthFactor: _name[i]),
                const SizedBox(height: 6),
                Finan2SkeletonBar(widthFactor: _sub[i], height: 9),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Finan2SkeletonBar(width: _amount[i]),
        ],
      ),
    );
  }
}

/// A `.figure` whose amount hasn't arrived: its [label] is already there,
/// the number is a bar, and [note] says why it's waiting.
class Finan2SkeletonFigure extends StatelessWidget {
  const Finan2SkeletonFigure({this.label, this.note, super.key});

  final String? label;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final label = this.label;
    final note = this.note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.inkSoft),
          ),
          const SizedBox(height: 6),
        ],
        const Finan2SkeletonBar(widthFactor: 0.7, height: 44, radius: 12),
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(note, style: TextStyle(fontSize: 12.5, color: colors.inkSoft)),
        ],
      ],
    );
  }
}

/// A list screen while it loads: an optional [top] (a figure), then a sheet
/// of [rows] skeleton rows - what replaces the spinner in a `loading:`.
class Finan2SkeletonList extends StatelessWidget {
  const Finan2SkeletonList({this.top, this.rows = 4, this.heading = false, super.key});

  final Widget? top;
  final int rows;

  /// A day's or a group's heading bar on top of the rows.
  final bool heading;

  @override
  Widget build(BuildContext context) {
    final top = this.top;
    return Finan2Skeleton(
      semanticsLabel: context.l10n.coreLoading,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          Finan2Space.lg,
          Finan2Space.xs,
          Finan2Space.lg,
          Finan2Space.xl,
        ),
        children: [
          if (top != null) ...[top, const SizedBox(height: Finan2Space.lg)],
          Finan2Sheet(
            children: [
              for (var i = 0; i < rows; i++)
                if (i == 0 && heading)
                  // Not a row of its own: the sheet would rule it off.
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 4),
                        child: Finan2SkeletonBar(width: 110, height: 9),
                      ),
                      Finan2SkeletonRow(),
                    ],
                  )
                else
                  Finan2SkeletonRow(seed: i),
            ],
          ),
        ],
      ),
    );
  }
}
