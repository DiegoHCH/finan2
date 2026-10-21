import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_opt_in.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../data/notification_prefs.dart';
import '../viewmodels/notification_prefs_providers.dart';

/// Qué avisar: each switch says, under it, when its notice arrives - what
/// decides whether it gets in the way. On is green here, not violet: a
/// switch that's on isn't an action.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  /// For whoever said «Ahora no» at first: asks now, and registers this
  /// phone for pushes if it's a yes. A phone that won't ask anymore gets
  /// the way to do it by hand.
  Future<void> _turnOn(BuildContext context, WidgetRef ref) async {
    final push = ref.read(pushServiceProvider);
    final allowed = await push.requestNotificationPermission();
    await NotificationOptIn.record(optedIn: allowed);
    ref.invalidate(notificationsAllowedProvider);
    if (allowed) {
      final householdId = ref.read(currentHouseholdProvider).value?.id;
      final uid = ref.read(authStateChangesProvider).value?.uid;
      if (householdId != null && uid != null) await push.registerToken(householdId, uid);
      return;
    }
    if (!context.mounted) return;
    await showFinan2InfoSheet(
      context,
      title: context.l10n.notificationPrefsBlockedTitle,
      message: context.l10n.notificationPrefsBlockedMessage,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final prefsAsync = ref.watch(notificationPrefsControllerProvider);
    final notifier = ref.read(notificationPrefsControllerProvider.notifier);
    final l10n = context.l10n;

    final myUid = ref.watch(authStateChangesProvider).value?.uid;
    final members = ref.watch(currentHouseholdProvider).value?.members ?? const <String>[];
    final partnerUid = members.where((uid) => uid != myUid).firstOrNull;
    final partner = partnerUid == null
        ? null
        : ref.watch(memberLabelProvider)(partnerUid).firstName;
    final hasPartner = partner != null && partner != '?';

    // Green for on, for this screen only.
    final theme = Theme.of(context);
    final switchTheme = theme.switchTheme.copyWith(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.income : colors.line,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.settingsTitle,
              title: l10n.notificationPrefsTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
            ),
            Expanded(
              child: prefsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(rows: 5),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (prefs) {
                  Future<void> update(NotificationPrefs Function(NotificationPrefs) change) =>
                      notifier.updatePrefs(change);
                  Widget toggle(bool value, NotificationPrefs Function(bool) change) =>
                      Switch(value: value, onChanged: (v) => update((_) => change(v)));

                  return Theme(
                    data: theme.copyWith(switchTheme: switchTheme),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Finan2Space.lg,
                        0,
                        Finan2Space.lg,
                        Finan2Space.xxl,
                      ),
                      children: [
                        if (ref.watch(notificationsAllowedProvider).value == false) ...[
                          Finan2Notice(
                            icon: Icons.notifications_off_outlined,
                            title: l10n.coreNotificationPrimerEnable,
                            message: l10n.notificationPrefsOffBanner,
                            onTap: () => _turnOn(context, ref),
                          ),
                          const SizedBox(height: Finan2Space.md),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            hasPartner
                                ? l10n.notificationPrefsIntro(partner)
                                : l10n.notificationPrefsIntroSolo,
                            style: TextStyle(fontSize: 13, height: 1.45, color: colors.inkSoft),
                          ),
                        ),
                        const SizedBox(height: Finan2Space.md),
                        Finan2Sheet(
                          children: [
                            Finan2SetRow(
                              label: l10n.notificationPrefsDebtPayments,
                              detail: l10n.notificationPrefsDebtPaymentsWhen,
                              trailing: toggle(
                                prefs.debtPayments,
                                (v) => prefs.copyWith(debtPayments: v),
                              ),
                            ),
                            Finan2SetRow(
                              label: l10n.notificationPrefsBudgetExceeded,
                              detail: l10n.notificationPrefsBudgetExceededWhen,
                              trailing: toggle(
                                prefs.budgetExceeded,
                                (v) => prefs.copyWith(budgetExceeded: v),
                              ),
                            ),
                            Finan2SetRow(
                              label: hasPartner
                                  ? l10n.notificationPrefsPartnerActivityNamed(partner)
                                  : l10n.notificationPrefsPartnerActivity,
                              detail: l10n.notificationPrefsPartnerActivityWhen,
                              trailing: toggle(
                                prefs.partnerActivity,
                                (v) => prefs.copyWith(partnerActivity: v),
                              ),
                            ),
                            Finan2SetRow(
                              label: l10n.notificationPrefsGoalProgress,
                              detail: l10n.notificationPrefsGoalProgressWhen,
                              trailing: toggle(
                                prefs.goalProgress,
                                (v) => prefs.copyWith(goalProgress: v),
                              ),
                            ),
                            Finan2SetRow(
                              label: l10n.notificationPrefsDailyReminder,
                              detail: l10n.notificationPrefsDailyReminderWhen,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    key: const Key('dailyReminderTime'),
                                    onPressed: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: prefs.dailyReminderTime,
                                        helpText: l10n.notificationPrefsDailyReminderTimeTooltip,
                                      );
                                      if (picked != null) {
                                        await update((c) => c.copyWith(dailyReminderTime: picked));
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: colors.inkFaint,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(
                                      prefs.dailyReminderTime.format(context),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colors.inkFaint,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ),
                                  toggle(
                                    prefs.dailyReminder,
                                    (v) => prefs.copyWith(dailyReminder: v),
                                  ),
                                ],
                              ),
                            ),
                            Finan2SetRow(
                              label: l10n.notificationPrefsWeeklySummary,
                              detail: l10n.notificationPrefsWeeklySummaryWhen(
                                NotificationService.weeklySummaryTime.format(context),
                              ),
                              trailing: toggle(
                                prefs.weeklySummary,
                                (v) => prefs.copyWith(weeklySummary: v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
