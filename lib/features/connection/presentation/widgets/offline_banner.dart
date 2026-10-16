import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/connection_providers.dart';

/// The `.offline` line under a screen's head while this device can't reach
/// the server: calm, in the sheet's tone rather than an alarm's, saying
/// what still works. Takes no room while online.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    this.padding = const EdgeInsets.fromLTRB(Finan2Space.lg, 0, Finan2Space.lg, Finan2Space.sm),
    super.key,
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(offlineProvider).value != true) return const SizedBox.shrink();
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: padding,
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off_outlined, size: 16, color: colors.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.coreOffline,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: colors.inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
