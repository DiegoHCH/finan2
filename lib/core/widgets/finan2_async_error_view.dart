import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/household/presentation/viewmodels/household_providers.dart';
import '../crypto/household_crypto.dart';
import '../theme/app_theme.dart';
import 'finan2_missing_key_sheet.dart';

/// What every screen's `.when(error: ...)` renders. A friendlier "falta la
/// llave" prompt for [Finan2CryptoException] - this device can't en/decrypt
/// amounts yet, and the raw exception text means nothing actionable to a
/// user - the raw error message for anything else, same as before.
class Finan2AsyncErrorView extends ConsumerWidget {
  const Finan2AsyncErrorView({required this.error, super.key});

  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = this.error;
    if (error is! Finan2CryptoException) {
      return Center(child: Text('$error'));
    }

    final household = ref.watch(currentHouseholdProvider).value;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vpn_key_outlined, size: Finan2Sizes.iconXl, color: colors.saving),
            const SizedBox(height: Finan2Space.md),
            Text(
              'Falta la llave de este hogar para ver estos montos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.inkSoft, fontSize: 13, height: 1.45),
            ),
            if (household != null) ...[
              const SizedBox(height: Finan2Space.lg),
              FilledButton(
                onPressed: () => showMissingKeySheet(context, household),
                child: const Text('Ir a Ajustes'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
