import 'package:firebase_auth/firebase_auth.dart';

import '../../features/household/data/household_repository.dart';

/// Maps common exceptions (Firebase Auth, household join/create) to short,
/// Spanish, user-facing messages - the app never shows a raw exception
/// string to the user.
String friendlyErrorMessage(Object? error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'network-request-failed':
        return 'Problema de conexión, intenta de nuevo.';
      default:
        return 'Algo salió mal (${error.code}).';
    }
  }
  if (error is HouseholdNotFoundException) {
    return 'Esa invitación no existe o ya venció. Pide a tu pareja una nueva '
        'desde Ajustes.';
  }
  if (error is HouseholdFullException) {
    return 'No pudimos unirte: el hogar ya tiene 2 miembros o la invitación '
        'dejó de ser válida.';
  }
  return 'Algo salió mal, intenta de nuevo.';
}
