import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/app_lock/presentation/viewmodels/app_lock_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/household/presentation/screens/create_join_household_screen.dart';
import '../../features/household/presentation/viewmodels/household_providers.dart';
import 'finan2_home_shell.dart';
import 'finan2_splash_screen.dart';

/// Root of the navigation: signed out -> auth screens; signed in without a
/// household -> create/join; signed in with a household -> its home.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

/// Firebase Auth often resolves a persisted session almost instantly, which
/// left the splash's loading state on screen for a single frame - a flash
/// rather than a moment. This holds it just long enough to read as
/// intentional; anything longer is the user waiting on nothing.
const _minSplashDuration = Duration(milliseconds: 700);

class _AuthGateState extends ConsumerState<AuthGate> {
  var _minSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_minSplashDuration, () {
      if (mounted) setState(() => _minSplashElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    // Signing out (or deleting the account) forgets this device's PIN, so
    // the next account here doesn't inherit it - and «forgot your PIN?»
    // is just signing out and back in.
    ref.listen(authStateChangesProvider, (previous, next) async {
      if (previous?.value == null || next.value != null) return;
      await ref.read(appLockRepositoryProvider).clear();
      ref.invalidate(appLockSettingsProvider);
      ref.read(appLockedProvider.notifier).lock();
    });

    if (!_minSplashElapsed) return const _LoadingScreen();

    return authState.when(
      loading: () => const _LoadingScreen(),
      error: (error, _) => _ErrorScreen(message: error.toString()),
      data: (user) {
        if (user == null) return const LoginScreen();
        return const _HouseholdGate();
      },
    );
  }
}

class _HouseholdGate extends ConsumerWidget {
  const _HouseholdGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdState = ref.watch(currentHouseholdProvider);

    return householdState.when(
      loading: () => const _LoadingScreen(),
      error: (error, _) => _ErrorScreen(message: error.toString()),
      data: (household) {
        if (household == null) return const CreateJoinHouseholdScreen();
        return Finan2HomeShell(household: household);
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Finan2SplashScreen();
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
