import 'local_timezone_web.dart' if (dart.library.io) 'local_timezone_native.dart' as impl;

/// The device's IANA timezone identifier (e.g. "America/Bogota"). Talks to
/// a small platform channel we own (see MainActivity.kt/AppDelegate.swift)
/// on native platforms, or the browser's Intl API on web - replaces
/// flutter_timezone, which still applies the Kotlin Gradle Plugin the old
/// way and has no fix yet for Flutter's built-in-Kotlin migration.
Future<String> getLocalTimezone() => impl.getLocalTimezone();
