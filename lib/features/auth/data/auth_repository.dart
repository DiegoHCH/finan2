import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

/// The auto-created "Web client" OAuth ID for the finan2 Firebase project
/// (from android/app/google-services.json's oauth_client, client_type 3 -
/// the same client Google generates for you and that Android already uses
/// internally). Only needed on web; native platforms read their client ID
/// from GoogleService-Info.plist/google-services.json instead.
const _webGoogleClientId =
    '1048748616099-m1mphbsbin27i0kab9adf0lv8c8ebf8m.apps.googleusercontent.com';

/// Wraps Firebase Auth (email/password + Google) for the household app.
///
/// Every method that mutates auth state throws the underlying
/// [FirebaseAuthException]/[GoogleSignInException] as-is; the presentation
/// layer maps those to user-facing messages.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance {
    // Controls the language of every email/SMS Firebase Auth sends on our
    // behalf (password reset, email verification...) - without this it
    // defaults to English regardless of the device's locale.
    _auth.setLanguageCode(Intl.defaultLocale ?? 'es');
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleSignInInit;

  /// [GoogleSignIn.initialize] must be called exactly once and awaited
  /// before any other method - caching the future (not just a bool) means
  /// concurrent callers await the same in-flight call instead of racing.
  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= _googleSignIn.initialize(
      clientId: kIsWeb ? _webGoogleClientId : null,
    );
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Whether the signed-in user's only sign-in method is Google (so
  /// deleting the account must reauthenticate via Google, not a password).
  bool get signedInWithGoogle {
    return _auth.currentUser?.providerData.any((info) => info.providerId == 'google.com') ?? false;
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    // updateDisplayName() only lands on the server - without a reload the
    // in-memory `currentUser` (what authStateChangesProvider and every
    // "displayName ?? email" fallback reads) keeps returning null, so
    // whoever creates/joins a household right after signup silently gets
    // their email baked in as their member name instead.
    await credential.user?.reload();
    return credential;
  }

  /// Updates the signed-in user's display name in both Firebase Auth and
  /// the local cached profile (see [signUpWithEmail]'s comment on why the
  /// reload matters).
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  Future<UserCredential> signInWithEmail({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sends the "reset your password" email. Firebase doesn't reveal whether
  /// the address actually has an account (a `user-not-found` error is
  /// possible but shouldn't be surfaced differently - that would let someone
  /// probe which emails are registered).
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Native platforms only - the web plugin's `authenticate()` throws
  /// `UnimplementedError`. Web uses [ensureGoogleWebButtonReady] +
  /// [googleWebSignInEvents] instead, since GIS requires the user to
  /// interact with its own rendered button (see login_screen.dart).
  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  /// Web only: initializes google_sign_in so the embedded GIS button
  /// (GoogleSignInWebButton) has something to render. Safe to call more
  /// than once.
  Future<void> ensureGoogleWebButtonReady() => _ensureGoogleSignInInitialized();

  /// Web only: fires whenever the embedded GIS button completes a sign-in,
  /// already exchanged for a signed-in Firebase user. AuthGate reacts to
  /// authStateChanges() on its own once this succeeds - callers only need
  /// to surface errors (a sign-in the user cancelled, a network failure).
  Stream<void> get googleWebSignInEvents {
    return _googleSignIn.authenticationEvents.asyncMap((event) async {
      if (event is! GoogleSignInAuthenticationEventSignIn) return;
      final idToken = event.user.authentication.idToken;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Re-proves identity with the current password, as Firebase requires for
  /// sensitive operations like account deletion.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    final credential = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  /// Same as [reauthenticateWithPassword], for accounts that only ever
  /// signed in with Google.
  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _ensureGoogleSignInInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await user.reauthenticateWithCredential(credential);
  }

  /// Permanently deletes the signed-in user. Must be called right after a
  /// successful reauthentication.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
