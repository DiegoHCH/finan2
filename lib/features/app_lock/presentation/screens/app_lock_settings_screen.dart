import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/app_lock_providers.dart';
import 'app_lock_screen.dart';
import 'pin_setup_screen.dart';

/// Bloqueo: the PIN is required (set in the onboarding), so this is where
/// fingerprint/face goes on or off later and where the PIN changes - after
/// typing the current one, or anyone holding the open app could. On is
/// green here, as in Qué avisar: a switch that's on isn't an action.
class AppLockSettingsScreen extends ConsumerWidget {
  const AppLockSettingsScreen({super.key});

  Future<bool> _checkCurrent(BuildContext context) async {
    final ok = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AppLockScreen(checkOnly: true)));
    return ok ?? false;
  }

  Future<void> _choosePin(BuildContext context, WidgetRef ref) async {
    final pin = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const PinSetupScreen()));
    if (pin != null) await ref.read(appLockSettingsProvider.notifier).setPin(pin);
  }

  /// Turning it on proves the finger or face works before relying on it.
  Future<void> _setBiometrics(BuildContext context, WidgetRef ref, bool on) async {
    if (on) {
      final reason = context.l10n.appLockBiometricReason;
      if (!await ref.read(biometricUnlockProvider).authenticate(reason)) return;
    }
    await ref.read(appLockSettingsProvider.notifier).setBiometrics(on);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final settingsAsync = ref.watch(appLockSettingsProvider);
    final biometricsAvailable = ref.watch(biometricsAvailableProvider).value ?? false;
    final l10n = context.l10n;

    final theme = Theme.of(context);
    final switchTheme = theme.switchTheme.copyWith(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.income : colors.line,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.appLockTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
            ),
            Expanded(
              child: settingsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(rows: 3),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (settings) => Theme(
                  data: theme.copyWith(switchTheme: switchTheme),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Finan2Space.lg,
                      0,
                      Finan2Space.lg,
                      Finan2Space.xxl,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          l10n.appLockIntro,
                          style: TextStyle(fontSize: 13, height: 1.45, color: colors.inkSoft),
                        ),
                      ),
                      const SizedBox(height: Finan2Space.md),
                      Finan2Sheet(
                        children: [
                          Finan2SetRow(
                            label: l10n.appLockBiometrics,
                            detail: biometricsAvailable
                                ? l10n.appLockBiometricsWhen
                                : l10n.appLockBiometricsUnavailable,
                            trailing: Switch(
                              key: const Key('appLockBiometricsSwitch'),
                              value: settings.biometrics && biometricsAvailable,
                              onChanged: biometricsAvailable
                                  ? (on) => _setBiometrics(context, ref, on)
                                  : null,
                            ),
                          ),
                          Finan2SetRow(
                            label: l10n.appLockChangePin,
                            onTap: () async {
                              if (await _checkCurrent(context) && context.mounted) {
                                await _choosePin(context, ref);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
