import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/notification_prefs_providers.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final prefsAsync = ref.watch(notificationPrefsControllerProvider);
    final notifier = ref.read(notificationPrefsControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: context.l10n.notificationsTitle,
              title: context.l10n.notificationPrefsTitle,
              showBackButton: true,
            ),
            Expanded(
              child: prefsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (prefs) => ListView(
                  padding: const EdgeInsets.all(Finan2Space.xl),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        context.l10n.notificationPrefsRemindersHeader,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: colors.inkFaint,
                        ),
                      ),
                    ),
                    Finan2ListCard(
                      children: [
                        _ToggleRow(
                          icon: Icons.notifications_outlined,
                          label: context.l10n.notificationPrefsDailyReminder,
                          value: prefs.dailyReminder,
                          onChanged: (v) =>
                              notifier.updatePrefs((c) => c.copyWith(dailyReminder: v)),
                          trailing: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: prefs.dailyReminderTime,
                              );
                              if (picked != null) {
                                await notifier.updatePrefs(
                                  (c) => c.copyWith(dailyReminderTime: picked),
                                );
                              }
                            },
                            child: Text(
                              prefs.dailyReminderTime.format(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.inkFaint,
                              ),
                            ),
                          ),
                        ),
                        _ToggleRow(
                          icon: Icons.credit_card_outlined,
                          label: context.l10n.notificationPrefsDebtPayments,
                          value: prefs.debtPayments,
                          onChanged: (v) =>
                              notifier.updatePrefs((c) => c.copyWith(debtPayments: v)),
                        ),
                        _ToggleRow(
                          icon: Icons.track_changes_outlined,
                          label: context.l10n.notificationPrefsGoalProgress,
                          value: prefs.goalProgress,
                          onChanged: (v) =>
                              notifier.updatePrefs((c) => c.copyWith(goalProgress: v)),
                        ),
                      ],
                    ),
                    const SizedBox(height: Finan2Space.lg),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        context.l10n.notificationPrefsAlertsHeader,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: colors.inkFaint,
                        ),
                      ),
                    ),
                    Finan2ListCard(
                      children: [
                        _ToggleRow(
                          icon: Icons.warning_amber_outlined,
                          label: context.l10n.notificationPrefsBudgetExceeded,
                          value: prefs.budgetExceeded,
                          onChanged: (v) =>
                              notifier.updatePrefs((c) => c.copyWith(budgetExceeded: v)),
                        ),
                        _ToggleRow(
                          icon: Icons.people_outline,
                          label: context.l10n.notificationPrefsPartnerActivity,
                          value: prefs.partnerActivity,
                          onChanged: (v) =>
                              notifier.updatePrefs((c) => c.copyWith(partnerActivity: v)),
                        ),
                        _ToggleRow(
                          icon: Icons.bar_chart_outlined,
                          label: context.l10n.notificationPrefsWeeklySummary,
                          value: prefs.weeklySummary,
                          onChanged: (v) =>
                              notifier.updatePrefs((c) => c.copyWith(weeklySummary: v)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: colors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
