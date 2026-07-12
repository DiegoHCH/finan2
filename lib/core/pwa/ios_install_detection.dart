// Whether this is an iOS Safari session that hasn't been added to the
// home screen yet - iOS only grants PWA push notifications and better
// storage persistence to installed apps, and there's no automatic install
// prompt on iOS, so the UI has to nudge the user itself.
export 'ios_install_detection_stub.dart'
    if (dart.library.js_interop) 'ios_install_detection_web.dart';
