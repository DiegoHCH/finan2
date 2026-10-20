import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../../core/observability/error_reporter.dart';

/// The Remote Config switch for the test-data rows in Ajustes. False - the
/// default, and what applies if it was never set - hides them.
const dummyDataParameter = 'dummyData';

/// Reads [dummyDataParameter], so the test-data rows can be shown or hidden
/// from the Firebase console with no new build.
class DemoAccessRepository {
  const DemoAccessRepository({this.remoteConfig});

  /// Null uses the app's Firebase instance.
  final FirebaseRemoteConfig? remoteConfig;

  /// From the server when it answers, from the last value this device saw
  /// otherwise. Never throws: without Firebase (tests, a failed start) the
  /// rows stay hidden.
  Future<bool> dummyDataEnabled() async {
    final FirebaseRemoteConfig config;
    try {
      config = remoteConfig ?? FirebaseRemoteConfig.instance;
      await config.setDefaults(const {dummyDataParameter: false});
    } catch (_) {
      return false;
    }
    try {
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          // Turning it on or off should show within minutes, not hours.
          minimumFetchInterval: const Duration(minutes: 5),
        ),
      );
      await config.fetchAndActivate();
    } catch (e, st) {
      // Offline or throttled: the last activated value still applies.
      ErrorReporter.recoverable(e, st, reason: 'remote config not fetched');
    }
    return config.getBool(dummyDataParameter);
  }
}
