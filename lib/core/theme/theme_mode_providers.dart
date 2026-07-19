import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_mode_repository.dart';

final themeModeRepositoryProvider = Provider<ThemeModeRepository>((ref) {
  return ThemeModeRepository();
});

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() {
    return ref.read(themeModeRepositoryProvider).load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(themeModeRepositoryProvider).save(mode);
  }
}

final themeModeControllerProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
