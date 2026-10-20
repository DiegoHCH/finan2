import 'package:flutter/material.dart';

import '../crypto/household_crypto.dart';
import 'finan2_missing_key_state.dart';

/// What every screen's `.when(error: ...)` renders: the «sin llave» state
/// for [Finan2CryptoException] - this device can't en/decrypt amounts yet,
/// and the raw exception text means nothing actionable to a user - the raw
/// error message for anything else, same as before.
///
/// Riverpod retries a failed provider, and while it does the value is a
/// reload that still carries the error: screens pass
/// `skipLoadingOnReload: true` to `.when` so the missing key shows at once
/// instead of a skeleton through every retry.
class Finan2AsyncErrorView extends StatelessWidget {
  const Finan2AsyncErrorView({required this.error, super.key});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error is Finan2CryptoException) return const Finan2MissingKeyState();
    return Center(child: Text('$error'));
  }
}
