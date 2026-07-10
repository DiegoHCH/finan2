import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/household/presentation/screens/create_join_household_screen.dart';
import '../../features/household/presentation/screens/household_home_screen.dart';
import '../../features/household/presentation/viewmodels/household_providers.dart';

/// Root of the navigation: signed out -> auth screens; signed in without a
/// household -> create/join; signed in with a household -> its home.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

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
        return HouseholdHomeScreen(household: household);
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
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
