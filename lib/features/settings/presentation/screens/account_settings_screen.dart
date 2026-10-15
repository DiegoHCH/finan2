import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_providers.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../core/widgets/finan2_option_card.dart';
import '../../../../core/widgets/finan2_reauth.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/widgets/recovery_phrase_flow.dart';
import '../../../../l10n/l10n.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';

String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.light => l10n.settingsThemeLight,
  ThemeMode.dark => l10n.settingsThemeDark,
  ThemeMode.system => l10n.settingsThemeSystem,
};

String _themeModeSubtitle(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.light => l10n.settingsThemeLightSubtitle,
  ThemeMode.dark => l10n.settingsThemeDarkSubtitle,
  ThemeMode.system => l10n.settingsThemeSystemSubtitle,
};

const _themeModeIcons = <ThemeMode, IconData>{
  ThemeMode.light: Icons.light_mode_outlined,
  ThemeMode.dark: Icons.dark_mode_outlined,
  ThemeMode.system: Icons.brightness_auto_outlined,
};

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({required this.household, super.key});

  final Household household;

  Future<void> _leaveHousehold(BuildContext context, WidgetRef ref) async {
    final isSolo = household.members.length <= 1;
    final l10n = context.l10n;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: l10n.settingsLeaveHousehold,
      message: isSolo
          ? l10n.settingsLeaveHouseholdSoloMessage(household.name)
          : l10n.settingsLeaveHouseholdMessage(household.name),
      confirmLabel: isSolo ? l10n.settingsLeaveAndDelete : l10n.settingsLeave,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final reauthenticated = await reauthenticate(context, ref);
      if (!reauthenticated || !context.mounted) return;
      await ref.read(householdControllerProvider.notifier).leaveHousehold(household.id);
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  Future<void> _editMyName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showFinan2InputSheet(
      context,
      title: context.l10n.settingsMyName,
      fieldLabel: context.l10n.commonName,
      controller: controller,
    );
    final name = toTitleCase(result ?? '');
    if (name.isEmpty || name == currentName) return;
    await ref.read(householdControllerProvider.notifier).updateMyName(name);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final isSolo = household.members.length <= 1;
    final l10n = context.l10n;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: l10n.settingsDeleteAccount,
      message: isSolo
          ? l10n.settingsDeleteAccountSoloMessage(household.name)
          : l10n.settingsDeleteAccountMessage,
      confirmLabel: l10n.commonContinue,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final reauthenticated = await reauthenticate(context, ref);
      if (!reauthenticated || !context.mounted) return;
      await ref.read(householdControllerProvider.notifier).deleteAccount();
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref, ThemeMode current) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sheetContext.l10n.settingsTheme,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: Finan2Space.md),
              for (final mode in ThemeMode.values) ...[
                Finan2OptionCard(
                  icon: _themeModeIcons[mode]!,
                  title: _themeModeLabel(sheetContext.l10n, mode),
                  subtitle: _themeModeSubtitle(sheetContext.l10n, mode),
                  selected: current == mode,
                  onTap: () {
                    ref.read(themeModeControllerProvider.notifier).setThemeMode(mode);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                if (mode != ThemeMode.values.last) const SizedBox(height: Finan2Space.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household.members;
    final memberNames = members.map((uid) => household.memberInfo[uid]?.name ?? '?').join(', ');
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final myUid = ref.watch(authStateChangesProvider).value?.uid;
    final myName = myUid == null ? '' : (household.memberInfo[myUid]?.name ?? '');
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: l10n.settingsAccountSettings,
              title: l10n.settingsAccountSettingsSubtitle,
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Finan2ListCard(
                    children: [
                      if (myUid != null)
                        Finan2ListRow(
                          icon: Icons.badge_outlined,
                          label: l10n.settingsMyName,
                          value: myName,
                          onTap: () => _editMyName(context, ref, myName),
                        ),
                      Finan2ListRow(
                        icon: Finan2Icons.miembros,
                        label: l10n.settingsHouseholdMembers,
                        value: memberNames,
                      ),
                      Finan2ListRow(
                        icon: Icons.notifications_outlined,
                        label: l10n.settingsNotifications,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationPreferencesScreen(),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: _themeModeIcons[themeMode]!,
                        label: l10n.settingsTheme,
                        value: _themeModeLabel(l10n, themeMode),
                        onTap: () => _pickThemeMode(context, ref, themeMode),
                      ),
                      Finan2ListRow(
                        icon: Icons.vpn_key_outlined,
                        label: l10n.householdRecoveryPhraseTitle,
                        value: l10n.settingsRecoveryPhraseHint,
                        onTap: () => createRecoveryPhrase(context, ref, household),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  OutlinedButton(
                    onPressed: () => _leaveHousehold(context, ref),
                    style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
                    child: Text(l10n.settingsLeaveHousehold),
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  TextButton(
                    onPressed: () => _deleteAccount(context, ref),
                    style: TextButton.styleFrom(foregroundColor: colors.inkFaint),
                    child: Text(l10n.settingsDeleteAccount),
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
