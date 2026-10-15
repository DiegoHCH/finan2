import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_centered_form.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_logo_tile.dart';
import '../../../../l10n/l10n.dart';
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
    await ref
        .read(authControllerProvider.notifier)
        .signUpWithEmail(
          name: toTitleCase(_nameController.text),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    // SignupScreen is pushed on top of LoginScreen, which is what AuthGate
    // actually swaps to the household flow once signed in - without popping
    // back to it here, a successful signup leaves this screen stuck on top,
    // hiding that the app already moved on underneath.
    //
    // The mounted check must come before ref.read(), not combined into one
    // `ref.read(...) && mounted` condition - `&&` still evaluates ref.read()
    // first, which throws if the widget was unmounted during the await above.
    if (!mounted) return;
    if (!ref.read(authControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        showFinan2ErrorSheet(context, message: friendlyErrorMessage(next.error));
      }
    });

    final l10n = context.l10n;
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
                Text(l10n.authSignupTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: Finan2Space.xs),
                Text(l10n.authSignupSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: Finan2Space.xl),
                Finan2Field(
                  label: l10n.commonName,
                  controller: _nameController,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? l10n.authNameRequired : null,
                ),
                const SizedBox(height: Finan2Space.md),
                Finan2Field(
                  label: l10n.authEmailLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) =>
                      (value == null || !value.contains('@')) ? l10n.authEmailInvalid : null,
                ),
                const SizedBox(height: Finan2Space.md),
                Finan2Field(
                  label: l10n.authPasswordLabel,
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: validateNewPassword,
                ),
                const SizedBox(height: Finan2Space.md),
                Finan2Field(
                  label: l10n.authConfirmPasswordLabel,
                  controller: _confirmController,
                  obscureText: true,
                  validator: (value) =>
                      value != _passwordController.text ? l10n.authPasswordsDontMatch : null,
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
                      : Text(l10n.authCreateAccount),
                ),
                const SizedBox(height: Finan2Space.md),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const LoginScreen())),
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(text: l10n.authHaveAccount),
                          TextSpan(
                            text: l10n.authSignInLink,
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
