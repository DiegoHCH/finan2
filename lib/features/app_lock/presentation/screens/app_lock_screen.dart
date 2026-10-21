import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../domain/app_lock_policy.dart';
import '../viewmodels/app_lock_providers.dart';
import '../widgets/pin_entry_view.dart';

/// Asks for the PIN (or the fingerprint/face). Two uses: the lock itself,
/// over everything when the app opens; and, with [checkOnly], a step in
/// Ajustes before turning the lock off or changing the PIN - that one pops
/// true on a right PIN and has a back arrow instead of «forgot».
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({this.checkOnly = false, super.key});

  final bool checkOnly;

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String? _hint;
  var _hintIsError = false;
  DateTime? _lockedUntil;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    unawaited(_loadWait());
    if (!widget.checkOnly) {
      // After the first frame: on Android the prompt needs the activity up.
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadWait() async {
    final until = await ref.read(appLockRepositoryProvider).lockedUntil();
    if (until != null && mounted) _startWait(until);
  }

  bool get _biometricsOn =>
      !widget.checkOnly &&
      (ref.read(appLockSettingsProvider).value?.biometrics ?? false) &&
      (ref.read(biometricsAvailableProvider).value ?? false);

  Future<void> _tryBiometrics() async {
    if (widget.checkOnly) return;
    // Awaited, not read: on a cold start neither has landed by the first frame.
    final settings = await ref.read(appLockSettingsProvider.future);
    final available = await ref.read(biometricsAvailableProvider.future);
    if (!settings.biometrics || !available || _lockedUntil != null || !mounted) return;
    final reason = context.l10n.appLockBiometricReason;
    final ok = await ref.read(biometricUnlockProvider).authenticate(reason);
    if (!ok || !mounted) return;
    await ref.read(appLockRepositoryProvider).recordUnlock();
    _done();
  }

  void _done() {
    if (widget.checkOnly) {
      Navigator.of(context).pop(true);
    } else {
      ref.read(appLockedProvider.notifier).unlock();
    }
  }

  Future<bool> _check(String pin) async {
    final result = await ref.read(appLockRepositoryProvider).verify(pin);
    if (!mounted) return result.ok;
    if (result.ok) {
      _done();
      return true;
    }
    final until = result.lockedUntil;
    if (until != null) {
      _startWait(until);
    } else {
      setState(() {
        _hint = context.l10n.appLockWrongPin(AppLockPolicy.attemptsLeft(result.failures));
        _hintIsError = true;
      });
    }
    return false;
  }

  void _startWait(DateTime until) {
    _ticker?.cancel();
    void tick() {
      final left = until.difference(DateTime.now());
      if (!mounted) return;
      if (left <= Duration.zero) {
        _ticker?.cancel();
        setState(() {
          _lockedUntil = null;
          _hint = null;
          _hintIsError = false;
        });
        return;
      }
      setState(() {
        _lockedUntil = until;
        _hint = context.l10n.appLockWait((left.inMilliseconds / 1000).ceil());
        _hintIsError = true;
      });
    }

    tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> _forgot() async {
    final l10n = context.l10n;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: l10n.appLockForgotTitle,
      message: l10n.appLockForgotMessage,
      confirmLabel: l10n.settingsSignOut,
      destructive: true,
    );
    if (!confirmed) return;
    // Signing back in proves it's you, and with no PIN left the onboarding
    // asks for a new one.
    await ref.read(appLockRepositoryProvider).clear();
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Watched so the button shows once the async checks land.
    ref.watch(appLockSettingsProvider);
    ref.watch(biometricsAvailableProvider);
    final waiting = _lockedUntil != null;

    return PopScope(
      canPop: widget.checkOnly,
      child: Scaffold(
        body: PinEntryView(
          top: widget.checkOnly ? Finan2BackHead(title: l10n.appLockTitle) : null,
          title: widget.checkOnly ? l10n.appLockCurrentTitle : l10n.appLockEnterPin,
          message: widget.checkOnly ? l10n.appLockCurrentMessage : l10n.appLockEnterPinMessage,
          hint: _hint,
          hintIsError: _hintIsError,
          enabled: !waiting,
          onCompleted: _check,
          leading: _biometricsOn
              ? IconButton(
                  tooltip: l10n.appLockUseBiometrics,
                  iconSize: 30,
                  onPressed: waiting ? null : _tryBiometrics,
                  icon: Icon(Icons.fingerprint, color: Theme.of(context).colorScheme.primary),
                )
              : null,
          footer: widget.checkOnly
              ? null
              : TextButton(onPressed: _forgot, child: Text(l10n.appLockForgot)),
        ),
      ),
    );
  }
}
