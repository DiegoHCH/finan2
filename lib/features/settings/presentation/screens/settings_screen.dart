import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/pwa/pwa_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../annual_summary/presentation/screens/annual_summary_screen.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../budget/presentation/screens/budget_screen.dart';
import '../../../budget/presentation/viewmodels/budget_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/screens/invite_household_screen.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../investments/presentation/screens/investments_screen.dart';
import '../../../investments/presentation/viewmodels/investment_providers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_providers.dart';
import '../../../../l10n/l10n.dart';
import 'account_settings_screen.dart';
import 'financial_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({required this.household, super.key});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household.members;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final totalPlanned = (ref.watch(currentMonthBudgetProvider).value ?? const {}).values.fold(
      0,
      (sum, v) => sum + v,
    );
    final totalInvestments = ref.watch(totalInvestmentValueProvider);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final hasKey = ref.watch(householdHasKeyProvider(household.id)).value;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(label: l10n.settingsTitle, title: l10n.settingsHeading),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
                children: [
                  if (hasKey == false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Finan2Space.md),
                      child: Container(
                        padding: const EdgeInsets.all(Finan2Space.md),
                        decoration: BoxDecoration(
                          color: colors.savingTint,
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                          border: Border.all(color: colors.saving),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.vpn_key_outlined, color: colors.saving),
                                const SizedBox(width: Finan2Space.sm),
                                Expanded(
                                  child: Text(
                                    l10n.settingsMissingKeyBanner,
                                    style: TextStyle(color: colors.ink, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Finan2Space.sm),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _importMissingKey(context, ref, household.id),
                                child: Text(l10n.settingsPasteCodeToUnlock),
                              ),
                            ),
                            const SizedBox(height: Finan2Space.sm),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _recoverWithPhrase(context, ref, household.id),
                                child: Text(l10n.settingsUseRecoveryPhrase),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (kIsWeb && ref.watch(persistentStorageStatusProvider) == false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Finan2Space.md),
                      child: Container(
                        padding: const EdgeInsets.all(Finan2Space.md),
                        decoration: BoxDecoration(
                          color: colors.savingTint,
                          borderRadius: BorderRadius.circular(Finan2Radius.card),
                          border: Border.all(color: colors.saving),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: colors.saving),
                            const SizedBox(width: Finan2Space.sm),
                            Expanded(
                              child: Text(
                                l10n.settingsStorageWarning,
                                style: TextStyle(color: colors.ink, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(Finan2Radius.card),
                    onTap: () => _shareHousehold(context, ref, household),
                    child: Container(
                      padding: const EdgeInsets.all(Finan2Space.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.heroStart, colors.heroEnd],
                        ),
                        borderRadius: BorderRadius.circular(Finan2Radius.card),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: members.isEmpty ? 0 : (30.0 + (members.length - 1) * 21),
                            height: 30,
                            child: Stack(
                              children: [
                                for (var i = 0; i < members.length; i++)
                                  Positioned(
                                    left: i * 21.0,
                                    child: Finan2Avatar(
                                      label: _initial(household.memberInfo[members[i]]?.name),
                                      memberIndex: i,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Finan2Space.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  household.name,
                                  style: TextStyle(
                                    color: colors.onHero,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${l10n.settingsMemberCount(members.length)} · '
                                  '${members.length < 2 ? l10n.settingsTapToInvite : l10n.settingsTapToShareKey}',
                                  style: TextStyle(color: colors.onHero, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2ListCard(
                    children: [
                      Finan2ListRow(
                        icon: Icons.tune,
                        label: l10n.settingsFinancialSettings,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FinancialSettingsScreen(household: household),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.manage_accounts_outlined,
                        label: l10n.settingsAccountSettings,
                        value: l10n.settingsAccountSettingsSubtitle,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AccountSettingsScreen(household: household),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.ios_share_outlined,
                        label: l10n.settingsExportReport,
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const ExportScreen())),
                      ),
                      Finan2ListRow(
                        icon: Icons.cloud_sync_outlined,
                        label: l10n.settingsBackup,
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const BackupScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2ListCard(
                    children: [
                      Finan2ListRow(
                        icon: Icons.donut_large_outlined,
                        label: l10n.settingsBudget,
                        value: l10n.settingsBudgetPlanned(formatMoney(totalPlanned)),
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const BudgetScreen())),
                      ),
                      Finan2ListRow(
                        icon: Icons.bar_chart_outlined,
                        label: l10n.settingsAnnualSummary,
                        value: '${DateTime.now().year}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AnnualSummaryScreen(household: household),
                          ),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Icons.trending_up,
                        label: l10n.settingsInvestments,
                        value: formatMoney(totalInvestments),
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const InvestmentsScreen())),
                      ),
                      Finan2ListRow(
                        icon: Icons.notifications_none_outlined,
                        label: l10n.settingsNotificationCenter,
                        value: unreadNotifications > 0 ? '$unreadNotifications' : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  OutlinedButton(
                    onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                    style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
                    child: Text(l10n.settingsSignOut),
                  ),
                  const SizedBox(height: Finan2Space.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _importMissingKey(BuildContext context, WidgetRef ref, String householdId) async {
  final controller = TextEditingController();
  final pasted = await showFinan2InputSheet(
    context,
    title: context.l10n.settingsUnlockAmountsTitle,
    message: context.l10n.settingsUnlockAmountsMessage,
    fieldLabel: context.l10n.settingsUnlockCodeLabel,
    controller: controller,
    confirmLabel: context.l10n.settingsUnlock,
  );
  if (pasted == null || pasted.trim().isEmpty) return;

  final error = await ref
      .read(householdControllerProvider.notifier)
      .importMissingKey(householdId: householdId, pastedCode: pasted);
  if (!context.mounted) return;

  if (error != null) {
    await showFinan2ErrorSheet(context, message: error);
  } else {
    await showFinan2InfoSheet(
      context,
      title: context.l10n.settingsAmountsUnlockedTitle,
      message: context.l10n.settingsAmountsUnlockedMessage,
    );
  }
}

Future<void> _recoverWithPhrase(BuildContext context, WidgetRef ref, String householdId) async {
  final controller = TextEditingController();
  final input = await showFinan2InputSheet(
    context,
    title: context.l10n.householdRecoveryPhraseTitle,
    message: context.l10n.settingsRecoveryPhraseMessage,
    fieldLabel: context.l10n.settingsRecoveryPhraseLabel,
    controller: controller,
    keyboardType: TextInputType.text,
    confirmLabel: context.l10n.settingsUnlock,
  );
  if (input == null || input.trim().isEmpty || !context.mounted) return;

  final error = await ref
      .read(householdControllerProvider.notifier)
      .recoverKeyWithPhrase(householdId: householdId, input: input);
  if (!context.mounted) return;

  if (error != null) {
    await showFinan2ErrorSheet(context, message: error);
  } else {
    await showFinan2InfoSheet(
      context,
      title: context.l10n.settingsAmountsUnlockedTitle,
      message: context.l10n.settingsAmountsUnlockedMessage,
    );
  }
}

/// With room in the household, creates a fresh invite and shows it; once
/// both members are in, shares the key alone so a partner who lost it on a
/// device can unlock amounts again. Goes through the share sheet rather than
/// the clipboard, where other apps and clipboard history can read it.
Future<void> _shareHousehold(BuildContext context, WidgetRef ref, Household household) async {
  final controller = ref.read(householdControllerProvider.notifier);
  if (household.members.length < 2) {
    final shareCode = await controller.createInvite(household.id);
    if (!context.mounted) return;
    if (shareCode == null) {
      await showFinan2ErrorSheet(context, message: context.l10n.settingsNoKeyToInvite);
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => InviteHouseholdScreen(shareCode: shareCode)));
    return;
  }

  final shareCode = await controller.keyShareCode(household.id);
  if (!context.mounted) return;
  if (shareCode == null) {
    await showFinan2ErrorSheet(context, message: context.l10n.settingsNoKeyToShare);
    return;
  }
  await SharePlus.instance.share(
    ShareParams(
      text: shareCode,
      title: context.l10n.settingsKeyShareSubject,
      subject: context.l10n.settingsKeyShareSubject,
    ),
  );
}

String _initial(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  return name.trim().substring(0, 1).toUpperCase();
}
