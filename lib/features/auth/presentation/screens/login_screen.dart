import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_centered_form.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_google_icon.dart';
import '../../../../core/widgets/finan2_logo_tile.dart';
import '../viewmodels/auth_providers.dart';
import '../widgets/google_sign_in_web_button.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Lets GoogleSignInWebButton's embedded GIS button actually render -
      // otherwise it has nothing to wait on.
      ref.read(authRepositoryProvider).ensureGoogleWebButtonReady();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _emailController.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Te enviamos un enlace a tu correo para elegir una contraseña nueva.',
            ),
            const SizedBox(height: Finan2Space.md),
            Finan2Field(
              label: 'Correo',
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    // Not disposed here on purpose: the dialog route is still animating out
    // when showDialog's future resolves, and its TextFormField (bound to
    // this controller) briefly rebuilds during that exit transition -
    // disposing immediately crashes it mid-animation. Same tradeoff
    // AccountSettingsScreen._askPassword already makes for the same reason.
    if (email == null || email.isEmpty || !mounted) return;
    await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (!state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si $email tiene una cuenta, te llegará un correo para recuperarla.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(next.error))),
        );
      }
    });
    if (kIsWeb) {
      // Keeps this repository stream subscribed while the screen is visible
      // (and unsubscribes automatically once it isn't) - authStateChanges()
      // picks up the resulting sign-in on its own, this is only watched to
      // surface errors the same way the controller-driven flows do above.
      ref.watch(googleWebSignInEventsProvider);
      ref.listen<AsyncValue<void>>(googleWebSignInEventsProvider, (previous, next) {
        if (next.hasError && !next.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authErrorMessage(next.error))),
          );
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
          child: Form(
            key: _formKey,
            child: Finan2CenteredForm(
              children: [
                const Finan2LogoTile(),
                const SizedBox(height: Finan2Space.lg),
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.headlineSmall,
                    children: [
                      const TextSpan(text: 'Bienvenido a Finan'),
                      TextSpan(
                        text: '2',
                        style: TextStyle(
                          color: Theme.of(context)
                              .extension<Finan2Colors>()!
                              .saving,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Finan2Space.xs),
                Text(
                  'Entra con tu cuenta. Cada quien tiene la suya; '
                  'las finanzas del hogar son compartidas.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Finan2Space.xl),
                Finan2Field(
                  label: 'Correo',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'Ingresa un correo válido'
                      : null,
                ),
                const SizedBox(height: Finan2Space.md),
                Finan2Field(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Ingresa tu contraseña'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authState.isLoading ? null : _forgotPassword,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: Finan2Space.sm),
                FilledButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión'),
                ),
                const SizedBox(height: Finan2Space.md),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Finan2Space.sm,
                      ),
                      child: Text(
                        'o',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: Finan2Space.md),
                // Web can't reuse the same button: GoogleSignIn.authenticate()
                // throws UnimplementedError there - GIS requires the user to
                // interact with its own rendered button instead of a popup
                // this app triggers imperatively.
                if (kIsWeb)
                  const GoogleSignInWebButton()
                else
                  OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle(),
                    icon: const Finan2GoogleIcon(),
                    label: const Text('Continuar con Google'),
                  ),
                const SizedBox(height: Finan2Space.lg),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: '¿No tienes cuenta? '),
                          TextSpan(
                            text: 'Créala aquí',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps common Firebase Auth errors to short, Spanish, user-facing messages.
String authErrorMessage(Object? error) {
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
  return 'Algo salió mal, intenta de nuevo.';
}
