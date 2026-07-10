import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_logo_tile.dart';
import '../viewmodels/auth_providers.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Finan2LogoTile(),
                const SizedBox(height: Finan2Space.lg),
                Text(
                  'Crea tu cuenta',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: Finan2Space.xs),
                Text(
                  'Regístrate para empezar a organizar las finanzas del hogar.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Finan2Space.xl),
                Finan2Field(
                  label: 'Nombre',
                  controller: _nameController,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa tu nombre'
                      : null,
                ),
                const SizedBox(height: Finan2Space.md),
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
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                const SizedBox(height: Finan2Space.md),
                Finan2Field(
                  label: 'Confirmar contraseña',
                  controller: _confirmController,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                const SizedBox(height: Finan2Space.lg),
                FilledButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: Finan2Space.md),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: '¿Ya tienes cuenta? '),
                          TextSpan(
                            text: 'Inicia sesión',
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
