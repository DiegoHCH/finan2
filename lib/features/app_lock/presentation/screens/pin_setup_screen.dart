import 'package:flutter/material.dart';

import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../l10n/l10n.dart';
import '../widgets/pin_entry_view.dart';

/// Choosing a PIN: type it, then type it again. Pops the PIN once both
/// match; a mismatch starts over from the first step, saying so.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _first;
  var _mismatch = false;

  Future<bool> _entered(String pin) async {
    final first = _first;
    if (first == null) {
      setState(() {
        _first = pin;
        _mismatch = false;
      });
      return true;
    }
    if (pin == first) {
      Navigator.of(context).pop(pin);
      return true;
    }
    setState(() {
      _first = null;
      _mismatch = true;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confirming = _first != null;
    return Scaffold(
      body: PinEntryView(
        // A new key per step so the dots start empty.
        key: ValueKey(confirming),
        top: Finan2BackHead(title: l10n.appLockTitle),
        over: l10n.appLockStep(confirming ? 2 : 1),
        title: confirming ? l10n.appLockConfirmTitle : l10n.appLockCreateTitle,
        message: confirming ? l10n.appLockConfirmMessage : l10n.appLockCreateMessage,
        hint: _mismatch ? l10n.appLockMismatch : null,
        hintIsError: _mismatch,
        onCompleted: _entered,
      ),
    );
  }
}
