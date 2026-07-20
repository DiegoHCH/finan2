import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// left the splash's loading state on screen for a single frame - too fast
/// to register as the intended branding moment. This holds it visible for
/// at least this long regardless of how fast the real check finishes.
const _minSplashDuration = Duration(seconds: 5);

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
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}
