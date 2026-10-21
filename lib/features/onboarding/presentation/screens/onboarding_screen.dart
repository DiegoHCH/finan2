import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_opt_in.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_prompt_page.dart';
import '../../../../core/widgets/finan2_splash_screen.dart';
import '../../../../core/widgets/finan2_steps.dart';
import '../../../../l10n/l10n.dart';
import '../../../app_lock/presentation/viewmodels/app_lock_providers.dart';
import '../../../app_lock/presentation/widgets/pin_entry_view.dart';

enum _Step { notifications, pin, biometrics }

/// The first time someone signs in on a phone: notifications, the PIN that
/// opens the app from then on (required - it's what spares signing in
/// again) and, when the phone has one, fingerprint or face. Steps that
/// don't apply are left out: notifications already allowed, no biometrics.
/// Nothing is saved until the end, so the app moves on once, all set.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  List<_Step>? _steps;
  var _index = 0;
  var _busy = false;

  /// The PIN's two halves: chosen, then typed again.
  String? _firstPin;
  String? _pin;
  var _pinMismatch = false;

  @override
  void initState() {
    super.initState();
    _decideSteps();
  }

  Future<void> _decideSteps() async {
    final notificationsAllowed = await ref.read(pushServiceProvider).notificationsAllowed();
    final biometricsAvailable = await ref.read(biometricsAvailableProvider.future);
    if (notificationsAllowed) await NotificationOptIn.record(optedIn: true);
    if (!mounted) return;
    setState(() {
      _steps = [
        if (!notificationsAllowed) _Step.notifications,
        _Step.pin,
        if (biometricsAvailable) _Step.biometrics,
      ];
    });
  }

  _Step get _step => _steps![_index];

  Future<void> _next() async {
    if (_index + 1 < _steps!.length) {
      setState(() => _index++);
      return;
    }
    await _finish(biometrics: false);
  }

  Future<void> _finish({required bool biometrics}) async {
    setState(() => _busy = true);
    await ref.read(appLockSettingsProvider.notifier).setUp(pin: _pin!, biometrics: biometrics);
  }

  Future<void> _askNotifications({required bool enable}) async {
    setState(() => _busy = true);
    final allowed = enable && await ref.read(pushServiceProvider).requestNotificationPermission();
    // A «no» to the system prompt counts as «Ahora no»: not asked again unasked.
    await NotificationOptIn.record(optedIn: allowed);
    ref.invalidate(notificationsAllowedProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    await _next();
  }

  Future<bool> _pinEntered(String pin) async {
    final first = _firstPin;
    if (first == null) {
      setState(() {
        _firstPin = pin;
        _pinMismatch = false;
      });
      return true;
    }
    if (pin != first) {
      setState(() {
        _firstPin = null;
        _pinMismatch = true;
      });
      return false;
    }
    _pin = pin;
    await _next();
    return true;
  }

  Future<void> _enableBiometrics() async {
    final reason = context.l10n.appLockBiometricReason;
    final ok = await ref.read(biometricUnlockProvider).authenticate(reason);
    if (!mounted) return;
    if (!ok) {
      await showFinan2ErrorSheet(context, message: context.l10n.onboardingBiometricsFailed);
      return;
    }
    await _finish(biometrics: true);
  }

  /// Back goes one step back - within the PIN, to choosing it again.
  void _back() {
    if (_step == _Step.pin && _firstPin != null) {
      setState(() => _firstPin = null);
    } else if (_index > 0) {
      setState(() {
        _index--;
        _firstPin = null;
        _pinMismatch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    if (steps == null) return const Finan2SplashScreen();
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    // A single step needs no «1 of 1».
    final showProgress = steps.length > 1;
    final over = showProgress ? l10n.householdSetupStep(_index + 1, steps.length) : null;
    final progress = showProgress ? Finan2Steps(reached: _index + 1, total: steps.length) : null;

    final laterButton = TextButton(
      onPressed: _busy
          ? null
          : _step == _Step.notifications
          ? () => _askNotifications(enable: false)
          : _next,
      style: TextButton.styleFrom(
        foregroundColor: colors.inkSoft,
        textStyle: const TextStyle(
          fontFamily: Finan2Type.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(l10n.householdSetupLater),
    );

    final Widget body = switch (_step) {
      _Step.notifications => Finan2PromptPage(
        top: progress,
        over: over,
        title: l10n.onboardingNotificationsTitle,
        message: l10n.onboardingNotificationsMessage,
        actions: [
          FilledButton(
            onPressed: _busy ? null : () => _askNotifications(enable: true),
            child: Text(l10n.coreNotificationPrimerEnable),
          ),
          laterButton,
        ],
        children: const [_StepIcon(icon: Finan2Icons.notificacion)],
      ),
      _Step.pin => PinEntryView(
        // A new key per half so the dots start empty.
        key: ValueKey(_firstPin != null),
        top: progress == null
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.md,
                  Finan2Space.lg,
                  0,
                ),
                child: progress,
              ),
        over: over,
        title: _firstPin == null ? l10n.onboardingPinTitle : l10n.appLockConfirmTitle,
        message: _firstPin == null ? l10n.onboardingPinMessage : l10n.appLockConfirmMessage,
        hint: _pinMismatch ? l10n.appLockMismatch : null,
        hintIsError: _pinMismatch,
        enabled: !_busy,
        onCompleted: _pinEntered,
      ),
      _Step.biometrics => Finan2PromptPage(
        top: progress,
        over: over,
        title: l10n.onboardingBiometricsTitle,
        message: l10n.onboardingBiometricsMessage,
        actions: [
          FilledButton(
            onPressed: _busy ? null : _enableBiometrics,
            child: Text(l10n.appLockBiometrics),
          ),
          laterButton,
        ],
        children: const [_StepIcon(icon: Icons.fingerprint)],
      ),
    };

    return PopScope(
      // Nothing behind it to go back to; back walks the steps instead.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(body: body),
    );
  }
}

/// The step's subject in a large tinted tile, like the notifications primer.
class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Center(
      child: Container(
        width: 96,
        height: 96,
        margin: const EdgeInsets.only(top: Finan2Space.xl),
        decoration: BoxDecoration(color: colors.brandTint, borderRadius: BorderRadius.circular(28)),
        child: Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
