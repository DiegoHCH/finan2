import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/finan2_logo_tile.dart';

/// Blurs the app the moment it stops being active - opening the app
/// switcher, a call, Control Center - so the switcher's thumbnail shows the
/// logo over a blur instead of balances. Back to active, it lifts.
///
/// On Android 13+ MainActivity also tells the system not to take that
/// thumbnail at all; this covers iOS and older Androids.
class PrivacyShield extends StatefulWidget {
  const PrivacyShield({required this.child, super.key});

  final Widget child;

  @override
  State<PrivacyShield> createState() => _PrivacyShieldState();
}

class _PrivacyShieldState extends State<PrivacyShield> {
  late final AppLifecycleListener _lifecycle;
  var _shielded = false;

  @override
  void initState() {
    super.initState();
    void shield(bool on) {
      if (mounted && _shielded != on) setState(() => _shielded = on);
    }

    _lifecycle = AppLifecycleListener(
      onInactive: () => shield(true),
      onHide: () => shield(true),
      onResume: () => shield(false),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final surface = Theme.of(context).colorScheme.surface;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_shielded)
          Positioned.fill(
            key: const Key('privacyShield'),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: ColoredBox(
                  // Tinted too: blur alone still lets big amounts show through.
                  color: surface.withValues(alpha: 0.55),
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: colors.brandDeep.withValues(alpha: 0.25),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Finan2LogoTile(tileSize: 72, iconSize: 38, alignLeft: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
