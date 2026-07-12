// The embedded Google Identity Services button - the only way to trigger
// Google Sign-In on web, since GoogleSignIn.authenticate() throws
// UnimplementedError there (see auth_repository.dart).
export 'google_sign_in_web_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_web_button_web.dart';
