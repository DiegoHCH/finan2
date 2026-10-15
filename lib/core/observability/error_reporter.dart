import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Single place errors leave the app through. Crashlytics on Android and iOS;
/// on the web (where Crashlytics doesn't exist), in tests and before Firebase
/// is up, the error only goes to the debug console.
///
/// Never send amounts or decrypted data in [reason]: describe what was being
/// done, not with what.
class ErrorReporter {
  ErrorReporter._();

  static bool get _crashlyticsAvailable => !kIsWeb && Firebase.apps.isNotEmpty;

  /// Hooks Flutter's and the platform's uncaught-error handlers. Collection is
  /// off in debug builds so local runs don't pollute the dashboard.
  static Future<void> install() async {
    if (!_crashlyticsAvailable) return;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Records an error the app recovered from - the ones that used to end in a
  /// silent `catch (_)`.
  static void recoverable(Object error, StackTrace stack, {required String reason}) {
    debugPrint('[$reason] $error');
    if (!_crashlyticsAvailable) return;
    unawaited(FirebaseCrashlytics.instance.recordError(error, stack, reason: reason));
  }
}
