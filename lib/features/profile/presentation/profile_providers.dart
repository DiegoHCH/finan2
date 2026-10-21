import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/app_language.dart';
import '../../../core/observability/error_reporter.dart';
import '../../../core/theme/theme_mode_providers.dart';
import '../../auth/presentation/viewmodels/auth_providers.dart';
import '../../household/presentation/viewmodels/household_providers.dart';
import '../data/user_profile_repository.dart';
import '../domain/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(),
);

/// The signed-in account's profile; null while signed out or not created yet.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(userProfileRepositoryProvider).watch(uid);
});

class ProfileController extends Notifier<void> {
  @override
  void build() {}

  /// The profile's name and, so the partner sees it, the household's copy
  /// (with the Auth display name, as before).
  Future<void> updateName(String name) async {
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).updateName(uid, name);
    await ref.read(householdControllerProvider.notifier).updateMyName(name);
    final result = ref.read(householdControllerProvider);
    if (result.hasError) throw result.error!;
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, void>(ProfileController.new);

/// Kept alive by the AuthGate while someone is signed in: creates their
/// profile the first time, and keeps language and theme the same on all
/// their phones. On sign-in the account's choice wins over this phone's;
/// an account without one yet takes this phone's. After that, a change here
/// goes up.
final profileSyncProvider = Provider<void>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return;
  final repository = ref.watch(userProfileRepositoryProvider);
  final uid = user.uid;
  final email = user.email ?? '';
  final fallbackName = (user.displayName?.trim().isNotEmpty ?? false)
      ? user.displayName!.trim()
      : email.split('@').first;

  void report(Object error, StackTrace stack) =>
      ErrorReporter.recoverable(error, stack, reason: 'profile sync');

  unawaited(repository.ensure(uid, name: fallbackName, email: email).catchError(report));

  var settled = false;
  ref.listen(userProfileProvider, (_, next) async {
    final profile = next.value;
    if (settled || profile == null) return;
    final theme = await ref.read(themeModeControllerProvider.future);
    final language = await ref.read(appLanguageControllerProvider.future);
    settled = true;

    final cloudTheme = ThemeMode.values.where((m) => m.name == profile.theme).firstOrNull;
    final cloudLanguage = AppLanguage.values.where((l) => l.name == profile.language).firstOrNull;
    if (cloudTheme != null && cloudTheme != theme) {
      await ref.read(themeModeControllerProvider.notifier).setThemeMode(cloudTheme);
    }
    if (cloudLanguage != null && cloudLanguage != language) {
      await ref.read(appLanguageControllerProvider.notifier).setLanguage(cloudLanguage);
    }
    if (cloudTheme == null || cloudLanguage == null) {
      await repository
          .updatePreferences(
            uid,
            theme: cloudTheme == null ? theme.name : null,
            language: cloudLanguage == null ? language.name : null,
          )
          .catchError(report);
    }
  }, fireImmediately: true);

  ref.listen(themeModeControllerProvider, (previous, next) {
    final mode = next.value;
    if (!settled || mode == null || mode == previous?.value) return;
    unawaited(repository.updatePreferences(uid, theme: mode.name).catchError(report));
  });
  ref.listen(appLanguageControllerProvider, (previous, next) {
    final language = next.value;
    if (!settled || language == null || language == previous?.value) return;
    unawaited(repository.updatePreferences(uid, language: language.name).catchError(report));
  });
});
