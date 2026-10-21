import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/finan2_splash_screen.dart';
import '../../auth/presentation/viewmodels/auth_providers.dart';
import '../domain/app_lock_policy.dart';
import 'screens/app_lock_screen.dart';
import 'viewmodels/app_lock_providers.dart';

/// Puts the lock screen in front of [child] when the lock is on: at a cold
/// start, and on coming back after [AppLockPolicy.backgroundGrace] away.
/// Sits in `MaterialApp.builder`, above the app's Navigator, so it covers
/// whatever screen was open - and [child] stays mounted underneath, so
/// unlocking returns right there. Signed out, there's nothing to lock.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late final AppLifecycleListener _lifecycle;
  DateTime? _hiddenAt;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _hiddenAt = DateTime.now(),
      onShow: () {
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (hiddenAt == null) return;
        if (DateTime.now().difference(hiddenAt) >= AppLockPolicy.backgroundGrace) {
          FocusManager.instance.primaryFocus?.unfocus();
          ref.read(appLockedProvider.notifier).lock();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(authStateChangesProvider.select((auth) => auth.value != null));
    final settings = signedIn ? ref.watch(appLockSettingsProvider) : null;
    final locked = ref.watch(appLockedProvider);
    // Unknown yet: the splash rather than a flash of the money behind.
    final loading = settings != null && !settings.hasValue && !settings.hasError;
    final showLock = (settings?.value?.enabled ?? false) && locked;
    final cover = loading || showLock;
    // Always this same tree, only what's visible changes: swapping [child]
    // in and out of it would rebuild the app's Navigator and lose the
    // screen that was open.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Offstage keeps the app's state without painting a pixel of it.
        Offstage(
          offstage: cover,
          child: TickerMode(enabled: !cover, child: widget.child),
        ),
        if (loading) const Finan2SplashScreen(),
        // Its own Navigator: the lock's sheets («forgot your PIN?») need one,
        // and the app's is the one being covered.
        if (showLock)
          HeroControllerScope.none(
            child: Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute<void>(builder: (_) => const AppLockScreen()),
            ),
          ),
      ],
    );
  }
}
