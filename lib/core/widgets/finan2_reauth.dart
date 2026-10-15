import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import 'finan2_bottom_sheet.dart';

/// Re-proves it's really the account owner before a sensitive action
/// (leaving the household, deleting the account, setting the backup PIN):
/// re-signs-in with Google, or asks for the password otherwise. Returns
/// false if the user cancelled the password prompt.
Future<bool> reauthenticate(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authControllerProvider.notifier);
  if (auth.signedInWithGoogle) {
    await auth.reauthenticateWithGoogle();
    return true;
  }
  final controller = TextEditingController();
  final password = await showFinan2InputSheet(
    context,
    title: 'Confirma tu contraseña',
    fieldLabel: 'Contraseña',
    controller: controller,
    obscureText: true,
    confirmLabel: 'Confirmar',
  );
  if (password == null || password.isEmpty || !context.mounted) return false;
  await auth.reauthenticateWithPassword(password);
  return true;
}
