import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../core/widgets/finan2_tile.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../notification_prefs/presentation/screens/notification_preferences_screen.dart';
import '../../domain/entities/household_notification.dart';
import '../../domain/notification_age.dart';
import '../notification_look.dart';
import '../viewmodels/notification_providers.dart';

/// Avisos: each notice in the color of what it's about, the unread ones
/// with a violet dot after the title.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(notificationControllerProvider.notifier);
    await controller.markAllRead();
    final result = ref.read(notificationControllerProvider);
    if (result.hasError && context.mounted) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error!));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: household?.name,
              title: l10n.notificationsTitle,
              onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
              action: Finan2HeadAction(
                icon: Icons.tune,
                tooltip: l10n.notificationPrefsTitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const NotificationPreferencesScreen()),
                ),
              ),
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Finan2Space.xl),
                        child: Text(
                          l10n.notificationsEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, height: 1.45, color: colors.inkSoft),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Finan2Space.lg,
                      Finan2Space.xs,
                      Finan2Space.lg,
                      Finan2Space.xxl,
                    ),
                    children: [
                      Finan2Sheet(
                        children: [
                          for (final notification in notifications)
                            _NotificationRow(notification: notification),
                        ],
                      ),
                      if (unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: Finan2Space.sm),
                          child: Center(
                            child: TextButton(
                              onPressed: () => _markAllRead(context, ref),
                              style: TextButton.styleFrom(foregroundColor: colors.inkSoft),
                              child: Text(l10n.notificationsMarkAllRead),
                            ),
                          ),
                        ),
                    ],
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

/// The `.ntf` line: its tile, the title in bold (with the dot while
/// unread), what happened, and when.
class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification});

  final HouseholdNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final look = notificationLook(context, ref, notification);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Finan2Tile(icon: look.icon, tone: look.tone),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: notification.title,
                    children: [
                      if (!notification.read)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Semantics(
                            label: l10n.notificationsUnread,
                            child: Container(
                              key: const Key('notificationUnreadDot'),
                              margin: const EdgeInsets.only(left: 6),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: colors.ink,
                  ),
                ),
                if (notification.body.isNotEmpty)
                  Text(
                    notification.body,
                    style: TextStyle(fontSize: 12.5, height: 1.4, color: colors.inkSoft),
                  ),
                const SizedBox(height: 3),
                Text(
                  _ageLabel(l10n, notification.createdAt),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _ageLabel(AppLocalizations l10n, DateTime at) {
  final age = notificationAge(at, DateTime.now());
  return switch (age.unit) {
    NotificationAgeUnit.minutes => l10n.notificationsMinutesAgo(age.count),
    NotificationAgeUnit.hours => l10n.notificationsHoursAgo(age.count),
    NotificationAgeUnit.yesterday => l10n.notificationsYesterday,
    NotificationAgeUnit.date => DateFormat.MMMd(l10n.localeName).format(at).replaceAll('.', ''),
  };
}
