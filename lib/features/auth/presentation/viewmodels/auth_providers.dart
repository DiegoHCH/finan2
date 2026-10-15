import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Emits the signed-in [User], or null when signed out.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Web only: LoginScreen watches this so it's actively subscribed to the
/// embedded Google button's sign-in events while visible (and unsubscribed
/// automatically once it isn't). authStateChangesProvider picks up the
/// resulting sign-in on its own; this is only watched for its error state.
final googleWebSignInEventsProvider = StreamProvider<void>((ref) {
  return ref.watch(authRepositoryProvider).googleWebSignInEvents;
});

/// Drives the login/signup screens: exposes loading/error state for the
/// in-flight auth action without the screens talking to Firebase directly.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(email: email, password: password),
    );
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmail(name: name, email: email, password: password),
    );
  }

  /// Never surfaces "user-not-found" distinctly from success - the caller
  /// always shows the same "revisa tu correo" message either way, so this
  /// can't be used to probe which emails have an account.
  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'user-not-found') rethrow;
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signInWithGoogle());
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signOut());
  }

  /// Web only: lets GoogleSignInWebButton's embedded GIS button render.
  void prepareGoogleWebButton() => ref.read(authRepositoryProvider).ensureGoogleWebButtonReady();

  bool get signedInWithGoogle => ref.read(authRepositoryProvider).signedInWithGoogle;

  /// Unlike the sign-in actions these throw instead of landing in [state]:
  /// they guard another action, which the caller runs only if they succeed.
  Future<void> reauthenticateWithGoogle() =>
      ref.read(authRepositoryProvider).reauthenticateWithGoogle();

  Future<void> reauthenticateWithPassword(String password) =>
      ref.read(authRepositoryProvider).reauthenticateWithPassword(password);
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
