import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_reauth.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/widgets/recovery_phrase_flow.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';
import '../../../profile/presentation/profile_providers.dart';
import 'profile_screen.dart';

/// Tu cuenta: what's yours rather than the household's - your name, what to
/// be notified of, the recovery phrase - and leaving or deleting the
/// account.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final memberNames = household.members
        .map((uid) => household.memberInfo[uid]?.name ?? '?')
        .join(', ');
    final myUid = ref.watch(authStateChangesProvider).value?.uid;
    final myName = myUid == null ? '' : (household.memberInfo[myUid]?.name ?? '');
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.settingsAccountSettings,
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
                      if (myUid != null)
                        Finan2SetRow(
                          icon: Icons.badge_outlined,
                          label: l10n.profileTitle,
                          value: ref.watch(userProfileProvider).value?.name ?? myName,
                          onTap: () => Navigator.of(
                            context,
                          ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
                        ),
                      Finan2SetRow(
                        icon: Finan2Icons.miembros,
                        label: l10n.settingsHouseholdMembers,
                        detail: memberNames,
                      ),
                      Finan2SetRow(
                        icon: Finan2Icons.notificacion,
                        label: l10n.notificationPrefsTitle,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationPreferencesScreen(),
                          ),
                        ),
                      ),
                      Finan2SetRow(
                        icon: Finan2Icons.codigo,
                        label: l10n.householdRecoveryPhraseTitle,
                        detail: l10n.settingsRecoveryPhraseHint,
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
