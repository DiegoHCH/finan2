import 'package:flutter/services.dart';

const _channel = MethodChannel('finan2/timezone');

/// Backed by MainActivity.kt (`TimeZone.getDefault().id`) on Android and
/// AppDelegate.swift (`TimeZone.current.identifier`) on iOS - those are the
/// two platforms this app actually ships on. Falls back to UTC rather than
/// throwing on any other native target (e.g. macOS/desktop, only ever used
/// for local `flutter run` during development) where no handler exists.
Future<String> getLocalTimezone() async {
  try {
    final id = await _channel.invokeMethod<String>('getLocalTimezone');
    return id ?? 'UTC';
  } on MissingPluginException {
    return 'UTC';
  }
}
