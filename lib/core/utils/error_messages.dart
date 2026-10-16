import 'package:firebase_auth/firebase_auth.dart';

import '../../features/household/data/household_repository.dart';
import '../../l10n/l10n.dart';

/// Maps common exceptions (Firebase Auth, household join/create) to short,
/// localized, user-facing messages - the app never shows a raw exception
/// string to the user.
String friendlyErrorMessage(Object? error) {
  final l10n = currentL10n;
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return l10n.errorWrongCredentials;
      case 'email-already-in-use':
        return l10n.errorEmailInUse;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorUnknownWithCode(error.code);
    }
  }
  // Firestore couldn't reach the server - a movement's write needs it.
  if (error is FirebaseException && error.code == 'unavailable') {
    return l10n.errorNetwork;
  }
  if (error is HouseholdNotFoundException) {
    return l10n.errorInviteNotFound;
  }
  if (error is HouseholdFullException) {
    return l10n.errorHouseholdFull;
  }
  return l10n.errorGeneric;
}
