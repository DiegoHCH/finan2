import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One of the four places in [Finan2NavBar].
class Finan2NavItem {
  const Finan2NavItem({required this.icon, required this.label});

  final Widget icon;
  final String label;
}

/// The redesign's `.nav`: four places with «Anotar» in the middle, since
/// recording a movement is what the app is opened for. The active place is
/// in ink with its icon on a violet pill; the rest stay faint.
class Finan2NavBar extends StatelessWidget {
  const Finan2NavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.addLabel,
    required this.onAdd,
    super.key,
  }) : assert(items.length == 4);

  final List<Finan2NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String addLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;

    Widget place(int i) {
      final item = items[i];
      final on = i == selectedIndex;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          label: item.label,
          excludeSemantics: true,
          child: InkResponse(
            onTap: () => onSelected(i),
            radius: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  decoration: BoxDecoration(
                    color: on ? colors.brandTint : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(size: 22, color: on ? brand : colors.inkFaint),
                    child: item.icon,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                    color: on ? colors.ink : colors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              place(0),
              place(1),
              SizedBox(
                width: 64,
                // heightFactor 1: a plain Center would stretch the bar to
                // the whole screen.
                child: Center(
                  heightFactor: 1,
                  child: Tooltip(
                    message: addLabel,
                    child: Semantics(
                      button: true,
                      label: addLabel,
                      excludeSemantics: true,
                      child: Material(
                        color: brand,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: onAdd,
                          child: SizedBox.square(
                            dimension: 52,
                            child: Icon(Icons.add_rounded, size: 26, color: colors.onAccent),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              place(2),
              place(3),
            ],
          ),
        ),
      ),
    );
  }
}
