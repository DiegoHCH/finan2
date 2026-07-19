import 'package:finan2/core/theme/theme_mode_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeModeRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = ThemeModeRepository();
  });

  test('defaults to system when nothing was ever saved', () async {
    expect(await repository.load(), ThemeMode.system);
  });

  test('round-trips a saved value', () async {
    await repository.save(ThemeMode.dark);
    expect(await repository.load(), ThemeMode.dark);
  });

  test('saving light then loading returns light', () async {
    await repository.save(ThemeMode.light);
    expect(await repository.load(), ThemeMode.light);
  });

  test('a later save overwrites the earlier one', () async {
    await repository.save(ThemeMode.dark);
    await repository.save(ThemeMode.light);
    expect(await repository.load(), ThemeMode.light);
  });
}
