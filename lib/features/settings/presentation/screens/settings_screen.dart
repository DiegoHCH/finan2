import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../demo/presentation/demo_data_actions.dart';
import '../../../../core/locale/app_language.dart';
import '../../../../core/pwa/pwa_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/theme/theme_mode_providers.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_split.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/domain/entities/debt.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/key_recovery_actions.dart';
import '../../../household/presentation/screens/invite_household_screen.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../../investments/presentation/screens/investments_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_providers.dart';
import '../../../recurring_bills/presentation/screens/recurring_bills_screen.dart';
import '../../../recurring_bills/presentation/viewmodels/recurring_bill_providers.dart';
import '../language_picker.dart';
import '../theme_mode_picker.dart';
import 'account_settings_screen.dart';
import 'financial_settings_screen.dart';

/// Ajustes, grouped by what each thing is: first what's money (accounts,
/// categories, fijos, investments), then what's the app's, then you. Every
/// row has an icon in a color of its own, to find it without reading.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({required this.household, super.key});

  final Household household;

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final members = household.members;
    final myUid = ref.watch(authStateChangesProvider).value?.uid;
    final memberLabel = ref.watch(memberLabelProvider);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final hasKey = ref.watch(householdHasKeyProvider(household.id)).value;
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final language = ref.watch(appLanguageControllerProvider).value ?? AppLanguage.system;
    final accountCount = ref.watch(accountsProvider).value?.length ?? 0;
    final cardCount = (ref.watch(debtsProvider).value ?? const [])
        .where((d) => d.type.isCard)
        .length;
    final categoryCount = ref.watch(categoriesProvider).value?.length ?? 0;
    final billCount = ref.watch(recurringBillsProvider).value?.length ?? 0;
    final l10n = context.l10n;

    Finan2Tone tone(Color color) => Finan2Tone.of(context, color);
    final neutral = Finan2Tone(colors.inkSoft, colors.surfaceAlt);
    final myIndex = myUid == null ? 0 : memberLabel(myUid).index;
    final partnerIndex = myIndex == 0 ? 1 : 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(overLabel: l10n.settingsTitle, title: household.name),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.lg,
                  Finan2Space.xs,
                  Finan2Space.lg,
                  Finan2Space.xxl,
                ),
                children: [
                  if (hasKey == false)
                    _Banner(
                      icon: Icons.vpn_key_outlined,
                      message: l10n.settingsMissingKeyBanner,
                      actions: [
                        FilledButton(
                          onPressed: () => unlockWithCode(context, ref, household.id),
                          child: Text(l10n.settingsPasteCodeToUnlock),
                        ),
                        OutlinedButton(
                          onPressed: () => unlockWithPhrase(context, ref, household.id),
                          child: Text(l10n.settingsUseRecoveryPhrase),
                        ),
                      ],
                    ),
                  if (kIsWeb && ref.watch(persistentStorageStatusProvider) == false)
                    _Banner(
                      icon: Icons.warning_amber_rounded,
                      message: l10n.settingsStorageWarning,
                    ),
                  Finan2Split(
                    children: [
                      for (final uid in members.take(2))
                        _MemberBlock(
                          name: memberLabel(uid).firstName,
                          note: uid == myUid ? l10n.settingsMemberYou : l10n.settingsMemberPartner,
                          tone: Finan2Tone.member(context, memberLabel(uid).index),
                        ),
                      if (members.length < 2)
                        _MemberBlock(
                          name: l10n.settingsInviteSomeone,
                          icon: Icons.person_add_alt_1_outlined,
                          tone: Finan2Tone.member(context, partnerIndex),
                          onTap: () => _shareHousehold(context, ref, household),
                        ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.md),
                  Finan2Sheet(
                    children: [
                      Finan2SetRow(
                        icon: Finan2Icons.banco,
                        tone: tone(Finan2Palette.casa),
                        label: l10n.settingsAccountsAndCards,
                        value: '${accountCount + cardCount}',
                        onTap: () => _open(context, const AccountsScreen()),
                      ),
                      Finan2SetRow(
                        icon: Finan2Icons.categorias,
                        tone: tone(Finan2Palette.mercado),
                        label: l10n.categoriesTitle,
                        value: '$categoryCount',
                        onTap: () => _open(context, const CategoriesScreen()),
                      ),
                      Finan2SetRow(
                        icon: Icons.autorenew,
                        tone: tone(Finan2Palette.servicios),
                        label: l10n.recurringBillsTitle,
                        value: '$billCount',
                        onTap: () => _open(context, const RecurringBillsScreen()),
                      ),
                      Finan2SetRow(
                        icon: Icons.trending_up,
                        tone: tone(Finan2Palette.ahorro),
                        label: l10n.settingsInvestments,
                        onTap: () => _open(context, const InvestmentsScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.md),
                  Finan2Sheet(
                    children: [
                      Finan2SetRow(
                        icon: Finan2Icons.notificacion,
                        tone: tone(Finan2Palette.ocio),
                        label: l10n.notificationsTitle,
                        value: unreadNotifications > 0 ? '$unreadNotifications' : null,
                        onTap: () => _open(context, const NotificationsScreen()),
                      ),
                      Finan2SetRow(
                        icon: Icons.file_download_outlined,
                        tone: tone(Finan2Palette.transporte),
                        label: l10n.settingsExportReport,
                        onTap: () => _open(context, const ExportScreen()),
                      ),
                      Finan2SetRow(
                        icon: Icons.shield_outlined,
                        tone: Finan2Tone(accent, colors.brandTint),
                        label: l10n.settingsBackup,
                        onTap: () => _open(context, const BackupScreen()),
                      ),
                      Finan2SetRow(
                        icon: members.length < 2
                            ? Icons.person_add_alt_1_outlined
                            : Finan2Icons.codigo,
                        tone: Finan2Tone.member(context, partnerIndex),
                        label: members.length < 2 ? l10n.settingsInvite : l10n.settingsShareKey,
                        onTap: () => _shareHousehold(context, ref, household),
                      ),
                      Finan2SetRow(
                        icon: Finan2Icons.moneda,
                        tone: neutral,
                        label: l10n.settingsFinancialSettings,
                        value: household.currency,
                        onTap: () => _open(context, FinancialSettingsScreen(household: household)),
                      ),
                      Finan2SetRow(
                        icon: themeModeIcons[themeMode]!,
                        tone: neutral,
                        label: l10n.settingsTheme,
                        value: themeModeLabel(l10n, themeMode),
                        onTap: () => pickThemeMode(context, ref, themeMode),
                      ),
                      Finan2SetRow(
                        icon: Icons.translate_outlined,
                        tone: neutral,
                        label: l10n.settingsLanguage,
                        value: appLanguageLabel(l10n, language),
                        onTap: () => pickAppLanguage(context, ref, language),
                      ),
                    ],
                  ),
                  const SizedBox(height: Finan2Space.md),
                  Finan2Sheet(
                    children: [
                      Finan2SetRow(
                        icon: Icons.person_outline,
                        tone: Finan2Tone.member(context, myIndex),
                        label: l10n.settingsAccountSettings,
                        value: myUid == null ? null : memberLabel(myUid).firstName,
                        onTap: () => _open(context, AccountSettingsScreen(household: household)),
                      ),
                    ],
                  ),
                  if (demoDataEnabled) ...[
                    const SizedBox(height: Finan2Space.md),
                    Finan2Sheet(
                      children: [
                        Finan2SetRow(
                          icon: Icons.science_outlined,
                          tone: neutral,
                          label: l10n.demoSeed,
                          onTap: () => seedDemoData(context, ref, household),
                        ),
                        Finan2SetRow(
                          icon: Icons.delete_sweep_outlined,
                          tone: neutral,
                          label: l10n.demoRemove,
                          onTap: () => removeDemoData(context, ref, household),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: Finan2Space.lg),
                  OutlinedButton(
                    onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                    style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
                    child: Text(l10n.settingsSignOut),
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

/// Something about this device that needs doing before anything else.
class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.message, this.actions = const []});

  final IconData icon;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: Finan2Space.md),
      child: Container(
        padding: const EdgeInsets.all(Finan2Space.md),
        decoration: BoxDecoration(color: colors.brandTint, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: colors.ink, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
            for (final action in actions) ...[const SizedBox(height: Finan2Space.sm), action],
          ],
        ),
      ),
    );
  }
}

/// One of the two people in the `.split` on top, in their color; the empty
/// second place invites someone.
class _MemberBlock extends StatelessWidget {
  const _MemberBlock({required this.name, required this.tone, this.note, this.icon, this.onTap});

  final String name;
  final String? note;
  final IconData? icon;
  final Finan2Tone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final note = this.note;
    final icon = this.icon;
    return Material(
      color: tone.tint,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: tone.color),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tone.color,
                      ),
                    ),
                    if (note != null)
                      Text(note, style: TextStyle(fontSize: 11.5, color: colors.inkFaint)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    // The invite already sent, while it lasts: opening this again must not
    // break the code the partner has.
    final invite = await controller.invite(household.id);
    if (!context.mounted) return;
    if (invite == null) {
      await showFinan2ErrorSheet(context, message: context.l10n.settingsNoKeyToInvite);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InviteHouseholdScreen(
          shareCode: invite.shareCode,
          expiresAt: invite.expiresAt,
          onNewCode: () => controller.invite(household.id, fresh: true),
        ),
      ),
    );
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
