import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Runs before every test file: the app's default language, as main() sets
/// it on a Spanish device.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Intl.defaultLocale = 'es';
  await initializeDateFormatting();
  await testMain();
}
