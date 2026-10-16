import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/observability/error_reporter.dart';
import '../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/viewmodels/auth_providers.dart';
import '../../household/data/household_model.dart';
import '../data/demo_data_repository.dart';

final demoDataRepositoryProvider = Provider<DemoDataRepository>((ref) => DemoDataRepository());

/// Ajustes › «Llenar con datos de prueba», after asking.
Future<void> seedDemoData(BuildContext context, WidgetRef ref, Household household) async {
  final l10n = context.l10n;
  final uid = ref.read(authStateChangesProvider).value?.uid;
  if (uid == null) return;
  final confirmed = await showFinan2ConfirmSheet(
    context,
    title: l10n.demoSeedTitle,
    message: l10n.demoSeedMessage,
    confirmLabel: l10n.demoSeedConfirm,
  );
  if (!confirmed || !context.mounted) return;
  try {
    final written = await ref
        .read(demoDataRepositoryProvider)
        .seed(
          household.id,
          uid: uid,
          partnerUid: household.members.where((m) => m != uid).firstOrNull ?? '',
        );
    if (!context.mounted) return;
    await showFinan2InfoSheet(
      context,
      title: l10n.demoSeedDoneTitle,
      message: l10n.demoSeedDone(written),
    );
  } catch (e, st) {
    ErrorReporter.recoverable(e, st, reason: 'demo data not written');
    if (!context.mounted) return;
    await showFinan2ErrorSheet(context, message: l10n.demoError);
  }
}

/// Ajustes › «Quitar datos de prueba», after asking.
Future<void> removeDemoData(BuildContext context, WidgetRef ref, Household household) async {
  final l10n = context.l10n;
  final confirmed = await showFinan2ConfirmSheet(
    context,
    title: l10n.demoRemoveTitle,
    message: l10n.demoRemoveMessage,
    confirmLabel: l10n.demoRemoveConfirm,
  );
  if (!confirmed || !context.mounted) return;
  try {
    final removed = await ref.read(demoDataRepositoryProvider).remove(household.id);
    if (!context.mounted) return;
    await showFinan2InfoSheet(
      context,
      title: l10n.demoRemoveDoneTitle,
      message: l10n.demoRemoveDone(removed),
    );
  } catch (e, st) {
    ErrorReporter.recoverable(e, st, reason: 'demo data not removed');
    if (!context.mounted) return;
    await showFinan2ErrorSheet(context, message: l10n.demoError);
  }
}
