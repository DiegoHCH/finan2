import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/app_language.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_providers.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_section_label.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../language_picker.dart';
import '../theme_mode_picker.dart';

/// Tu perfil: who the account is (name, sign-in email, password) and the
/// preferences that follow it to every phone. The name is the account's,
/// not the household's; the household keeps a copy for the partner.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showFinan2InputSheet(
      context,
      title: context.l10n.profileName,
      fieldLabel: context.l10n.commonName,
      controller: controller,
    );
    final name = toTitleCase(result ?? '');
    if (name.isEmpty || name == current) return;
    try {
      await ref.read(profileControllerProvider.notifier).updateName(name);
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  /// A link by email rather than typing the old and new here: the same
  /// path as «¿Olvidaste tu contraseña?», which already works.
  Future<void> _changePassword(BuildContext context, WidgetRef ref, String email) async {
    final l10n = context.l10n;
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      if (!context.mounted) return;
      await showFinan2InfoSheet(
        context,
        title: l10n.profilePasswordSentTitle,
        message: l10n.profilePasswordSentMessage(email),
      );
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final user = ref.watch(authStateChangesProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final household = ref.watch(currentHouseholdProvider).value;
    final name = profile?.name ?? (user == null ? '' : household?.memberInfo[user.uid]?.name ?? '');
    final email = profile?.email ?? user?.email ?? '';
    final withGoogle = ref.read(authControllerProvider.notifier).signedInWithGoogle;
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final language = ref.watch(appLanguageControllerProvider).value ?? AppLanguage.system;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsAccountSettings,
              title: l10n.profileTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.xs,
                  Finan2Space.lg,
                  Finan2Space.xxl,
                ),
                children: [
                  Finan2Sheet(
                    children: [
                      Finan2SetRow(
                        icon: Icons.badge_outlined,
                        label: l10n.profileName,
                        value: name,
                        onTap: () => _editName(context, ref, name),
                      ),
                      Finan2SetRow(
                        icon: Icons.alternate_email,
                        label: l10n.profileEmail,
                        detail: email,
                      ),
                      if (withGoogle)
                        Finan2SetRow(
                          icon: Icons.key_outlined,
                          label: l10n.profilePassword,
                          detail: l10n.profilePasswordGoogle,
                        )
                      else
                        Finan2SetRow(
                          icon: Icons.key_outlined,
                          label: l10n.profileChangePassword,
                          onTap: email.isEmpty ? null : () => _changePassword(context, ref, email),
                        ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2SectionLabel(l10n.profilePreferences),
                  const SizedBox(height: Finan2Space.xs),
                  Finan2Sheet(
                    children: [
                      Finan2SetRow(
                        icon: Icons.translate_outlined,
                        label: l10n.settingsLanguage,
                        value: appLanguageLabel(l10n, language),
                        onTap: () => pickAppLanguage(context, ref, language),
                      ),
                      Finan2SetRow(
                        icon: themeModeIcons[themeMode]!,
                        label: l10n.settingsTheme,
                        value: themeModeLabel(l10n, themeMode),
                        onTap: () => pickThemeMode(context, ref, themeMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      l10n.profilePreferencesNote,
                      style: TextStyle(fontSize: 12.5, height: 1.45, color: colors.inkFaint),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
