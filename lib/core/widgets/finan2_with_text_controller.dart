import 'package:flutter/widgets.dart';

/// Gives a sheet its own [TextEditingController], disposed with the sheet.
/// Disposing it when `showModalBottomSheet` returns is too early: the
/// future completes on pop, while the sheet still rebuilds sliding out, and
/// a disposed controller there throws.
class Finan2WithTextController extends StatefulWidget {
  const Finan2WithTextController({required this.builder, this.initialText = '', super.key});

  final String initialText;
  final Widget Function(BuildContext context, TextEditingController controller) builder;

  @override
  State<Finan2WithTextController> createState() => _Finan2WithTextControllerState();
}

class _Finan2WithTextControllerState extends State<Finan2WithTextController> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
