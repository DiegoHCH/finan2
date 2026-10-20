import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_centered_form.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_google_icon.dart';
import '../../../../core/widgets/finan2_logo_tile.dart';
import '../../../../l10n/l10n.dart';
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
      ref.read(authControllerProvider.notifier).prepareGoogleWebButton();
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
    await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: _emailController.text.trim(), password: _passwordController.text);
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _emailController.text.trim());
    final email = await showFinan2InputSheet(
      context,
      title: context.l10n.authResetPasswordTitle,
      message: context.l10n.authResetPasswordMessage,
      fieldLabel: context.l10n.authEmailLabel,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      confirmLabel: context.l10n.authResetPasswordSend,
    );
    final trimmedEmail = email?.trim();
    if (trimmedEmail == null || trimmedEmail.isEmpty || !mounted) return;
    await ref.read(authControllerProvider.notifier).sendPasswordReset(trimmedEmail);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (!state.hasError) {
      await showFinan2InfoSheet(
        context,
        title: context.l10n.authResetPasswordSentTitle,
        message: context.l10n.authResetPasswordSentMessage(trimmedEmail),
      );
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
    if (kIsWeb) {
      // Keeps this repository stream subscribed while the screen is visible
      // (and unsubscribes automatically once it isn't) - authStateChanges()
      // picks up the resulting sign-in on its own, this is only watched to
      // surface errors the same way the controller-driven flows do above.
      ref.watch(googleWebSignInEventsProvider);
      ref.listen<AsyncValue<void>>(googleWebSignInEventsProvider, (previous, next) {
        if (next.hasError && !next.isLoading) {
          showFinan2ErrorSheet(context, message: friendlyErrorMessage(next.error));
        }
      });
    }

    final l10n = context.l10n;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Finan2Space.lg),
          child: Form(
            key: _formKey,
            child: Finan2CenteredForm(
              children: [
                const SizedBox(height: Finan2Space.lg),
                const Finan2LogoTile(),
                const SizedBox(height: Finan2Space.md),
                // Says what the app is, not «Bienvenido».
                Text(l10n.authLoginHeadline, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: Finan2Space.sm),
                Text(
                  l10n.authLoginSubtitle,
                  style: TextStyle(fontSize: 14, height: 1.5, color: colors.inkSoft),
                ),
                const SizedBox(height: Finan2Space.lg),
                Finan2Field(
                  label: l10n.authEmailLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) =>
                      (value == null || !value.contains('@')) ? l10n.authEmailInvalid : null,
                ),
                const SizedBox(height: Finan2Space.sm),
                Finan2Field(
                  label: l10n.authPasswordLabel,
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) =>
                      (value == null || value.isEmpty) ? l10n.authPasswordRequired : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authState.isLoading ? null : _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.inkSoft,
                      textStyle: const TextStyle(
                        fontFamily: Finan2Type.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l10n.authForgotPassword),
                  ),
                ),
                FilledButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.authSignIn),
                ),
                const SizedBox(height: Finan2Space.sm),
                // Web can't reuse the same button: GoogleSignIn.authenticate()
                // throws UnimplementedError there - GIS requires the user to
                // interact with its own rendered button instead of a popup
                // this app triggers imperatively.
                if (kIsWeb)
                  const Center(child: GoogleSignInWebButton())
                else
                  OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                    icon: const Finan2GoogleIcon(),
                    label: Text(l10n.authContinueWithGoogle),
                  ),
                const SizedBox(height: Finan2Space.sm),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute<void>(builder: (_) => const SignupScreen())),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.inkSoft,
                        ),
                        children: [
                          TextSpan(text: l10n.authNoAccount),
                          TextSpan(
                            text: l10n.authCreateAccountHere,
                            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Finan2Space.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
