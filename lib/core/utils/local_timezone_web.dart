import 'dart:js_interop';

/// Binds to the browser's `Intl.DateTimeFormat().resolvedOptions().timeZone`
/// - every evergreen browser supports it, no polyfill needed.
@JS('Intl.DateTimeFormat')
extension type _JSDateTimeFormat._(JSObject _) implements JSObject {
  external _JSDateTimeFormat();
  external _JSResolvedOptions resolvedOptions();
}

extension type _JSResolvedOptions._(JSObject _) implements JSObject {
  external JSString? get timeZone;
}

Future<String> getLocalTimezone() async {
  final timeZone = _JSDateTimeFormat().resolvedOptions().timeZone;
  return timeZone?.toDart ?? 'UTC';
}
