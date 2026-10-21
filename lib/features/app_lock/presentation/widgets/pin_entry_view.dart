import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_logo_tile.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/app_lock_policy.dart';

/// Everything a PIN screen shows: the logo, what's being asked, the four
/// dots, a line under them for what went wrong, and the keypad within the
/// thumb's reach. Holds the digits typed so far and hands over the four
/// once they're in; the screen decides what they mean.
class PinEntryView extends StatefulWidget {
  const PinEntryView({
    required this.title,
    required this.onCompleted,
    this.over,
    this.message,
    this.hint,
    this.hintIsError = false,
    this.enabled = true,
    this.leading,
    this.footer,
    this.top,
    super.key,
  });

  final String title;
  final String? over;
  final String? message;

  /// Under the dots: a wrong PIN, the wait, a mismatch.
  final String? hint;
  final bool hintIsError;

  /// False while the pad has to wait after too many wrong PINs.
  final bool enabled;

  /// Bottom-left of the keypad - the fingerprint/face button, when there's one.
  final Widget? leading;
  final Widget? footer;
  final Widget? top;

  /// Gets the 4 digits. Returning false shakes the dots and clears them.
  final Future<bool> Function(String pin) onCompleted;

  @override
  State<PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends State<PinEntryView> with SingleTickerProviderStateMixin {
  var _pin = '';
  var _busy = false;
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _type(String digit) async {
    if (_busy || !widget.enabled || _pin.length >= AppLockPolicy.pinLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += digit);
    if (_pin.length < AppLockPolicy.pinLength) return;
    _busy = true;
    final ok = await widget.onCompleted(_pin);
    if (!mounted) return;
    if (!ok) {
      HapticFeedback.heavyImpact();
      await _shake.forward(from: 0);
    }
    if (!mounted) return;
    setState(() {
      _pin = '';
      _busy = false;
    });
  }

  void _erase() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final textTheme = Theme.of(context).textTheme;
    final hint = widget.hint;
    final over = widget.over;
    final message = widget.message;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?widget.top,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Finan2Space.lg,
                Finan2Space.xl,
                Finan2Space.lg,
                Finan2Space.lg,
              ),
              child: Column(
                children: [
                  const Finan2LogoTile(alignLeft: false),
                  const SizedBox(height: Finan2Space.lg),
                  if (over != null) ...[
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
                  Text(widget.title, style: textTheme.headlineMedium, textAlign: TextAlign.center),
                  if (message != null) ...[
                    const SizedBox(height: Finan2Space.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.5, color: colors.inkSoft),
                    ),
                  ],
                  const SizedBox(height: Finan2Space.xl),
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value),
                        0,
                      ),
                      child: child,
                    ),
                    child: _PinDots(filled: _pin.length, error: widget.hintIsError),
                  ),
                  const SizedBox(height: Finan2Space.md),
                  SizedBox(
                    height: 40,
                    child: hint == null
                        ? null
                        : Text(
                            hint,
                            key: const Key('pinHint'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: widget.hintIsError ? colors.expense : colors.inkSoft,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          _PinPad(
            enabled: widget.enabled,
            onDigit: _type,
            onErase: _erase,
            leading: widget.leading,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Finan2Space.lg,
              Finan2Space.sm,
              Finan2Space.lg,
              Finan2Space.md,
            ),
            child: SizedBox(height: 44, child: Center(child: widget.footer)),
          ),
        ],
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled, required this.error});

  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = error ? colors.expense : Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < AppLockPolicy.pinLength; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 9),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? accent : Colors.transparent,
              border: Border.all(color: i < filled ? accent : colors.line, width: 2),
            ),
          ),
      ],
    );
  }
}

/// The 3x4 keypad: 1-9, then [leading] (or nothing), 0 and erase.
class _PinPad extends StatelessWidget {
  const _PinPad({
    required this.enabled,
    required this.onDigit,
    required this.onErase,
    this.leading,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onErase;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    Widget key(String digit) => _PadKey(
      onTap: enabled ? () => onDigit(digit) : null,
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: enabled ? colors.ink : colors.inkFaint,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
    Widget row(List<Widget> keys) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: keys);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row([key('1'), key('2'), key('3')]),
          row([key('4'), key('5'), key('6')]),
          row([key('7'), key('8'), key('9')]),
          row([
            SizedBox(
              width: _PadKey.size,
              height: _PadKey.size,
              child: Center(child: leading),
            ),
            key('0'),
            _PadKey(
              plain: true,
              onTap: onErase,
              child: Tooltip(
                message: context.l10n.appLockErase,
                child: Icon(Icons.backspace_outlined, color: colors.inkSoft),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({required this.child, this.onTap, this.plain = false});

  static const size = 76.0;

  final Widget child;
  final VoidCallback? onTap;

  /// No disc behind it - erase is a tool, not a digit.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: plain ? Colors.transparent : colors.surfaceAlt,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
