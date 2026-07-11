import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../data/notification_model.dart';
import '../viewmodels/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: 'Notificaciones',
              title: unreadCount > 0 ? '$unreadCount nuevas' : 'Al día',
              trailing: unreadCount > 0
                  ? GestureDetector(
                      onTap: () => ref
                          .read(notificationControllerProvider.notifier)
                          .markAllRead(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.brandTint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Marcar leídas',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: colors.brandDeep,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Finan2Space.xl),
                        child: Text(
                          'Aún no hay notificaciones. Aquí verás avisos de pagos, '
                          'metas y presupuesto.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: colors.inkSoft),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(Finan2Space.xl),
                    children: [
                      for (final notification in notifications)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _NotificationRow(notification: notification),
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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final HouseholdNotification notification;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final (icon, tint, iconColor) = switch (notification.type) {
      NotificationType.debtDue => (
          Icons.credit_card_outlined,
          colors.expense.withValues(alpha: 0.14),
          colors.expense,
        ),
      NotificationType.goalNear => (
          Icons.track_changes_outlined,
          colors.brandTint,
          brand,
        ),
      NotificationType.contribution => (
          Icons.savings_outlined,
          colors.savingTint,
          colors.saving,
        ),
      NotificationType.budgetExceeded => (
          Icons.warning_amber_outlined,
          colors.expense.withValues(alpha: 0.14),
          colors.expense,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: notification.read
            ? Border.all(color: colors.line)
            : Border(
                top: BorderSide(color: colors.line),
                right: BorderSide(color: colors.line),
                bottom: BorderSide(color: colors.line),
                left: BorderSide(color: brand, width: 3),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body,
                  style: TextStyle(fontSize: 11, color: colors.inkSoft, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  _relativeTime(notification.createdAt).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
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

String _relativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes.clamp(1, 59)} min';
  final today = DateTime(now.year, now.month, now.day);
  final thatDay = DateTime(date.year, date.month, date.day);
  final days = today.difference(thatDay).inDays;
  if (days <= 0) return diff.inHours < 24 ? 'Hace ${diff.inHours} h' : 'Hoy';
  if (days == 1) return 'Ayer';
  return 'Hace $days d';
}
