import 'package:flutter/material.dart';

import '../../features/household/data/household_model.dart';
import '../theme/app_theme.dart';
import 'finan2_avatar.dart';

/// The custom header used across screens instead of a plain AppBar,
/// matching the mockup's `.app-top`: a small gray label, a bold title, and
/// the household's member avatars on the right.
class Finan2AppTop extends StatelessWidget {
  const Finan2AppTop({
    required this.label,
    required this.title,
    this.household,
    this.trailing,
    this.showBackButton = false,
    super.key,
  });

  final String label;
  final String title;
  final Household? household;

  /// Overrides the member-avatars stack on the right (e.g. Deudas shows a
  /// strategy badge there instead).
  final Widget? trailing;

  /// Set on every screen reached via Navigator.push (not one of the 5
  /// bottom-nav tabs) - not everyone knows or uses the back gesture, so
  /// pushed screens need a visible way back too.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household?.members ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.xl,
        Finan2Space.md,
        Finan2Space.xl,
        Finan2Space.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(right: 4, top: 2),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.chevron_left, size: 26, color: colors.inkSoft),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.inkFaint,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (members.isNotEmpty)
            SizedBox(
              width: 30.0 + (members.length - 1).clamp(0, 10) * 21,
              height: 30,
              child: Stack(
                children: [
                  for (var i = 0; i < members.length; i++)
                    Positioned(
                      left: i * 21.0,
                      child: Finan2Avatar(
                        label: _initial(household?.memberInfo[members[i]]?.name),
                        memberIndex: i,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _initial(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  return name.trim().substring(0, 1).toUpperCase();
}
