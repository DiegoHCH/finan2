import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_messages.dart';
import '../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../l10n/l10n.dart';
import '../domain/entities/movement.dart';
import 'screens/movement_detail_screen.dart';
import 'viewmodels/transaction_providers.dart';

/// Opens [tx]'s detail; if it comes back asking to delete, deletes it with
/// «Deshacer» offered. Shared by every list that shows movements.
Future<void> openMovement(BuildContext context, Movement tx) async {
  final toDelete = await Navigator.of(
    context,
  ).push<Movement>(MaterialPageRoute<Movement>(builder: (_) => MovementDetailScreen(movement: tx)));
  if (toDelete != null && context.mounted) await deleteMovementWithUndo(context, toDelete);
}

/// Hides [tx] and only deletes it once the «Deshacer» snackbar closes
/// without being tapped. Deleting later instead of recreating on undo
/// keeps the partner's movements restorable: the rules only let a member
/// create records attributed to themselves.
Future<void> deleteMovementWithUndo(BuildContext context, Movement tx) async {
  // Outlives the screen, so the delete still happens after a tab switch.
  final container = ProviderScope.containerOf(context);
  final pending = container.read(pendingMovementDeletionsProvider.notifier);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  pending.hide(tx.id);
  messenger.hideCurrentSnackBar();
  final reason = await messenger
      .showSnackBar(
        SnackBar(
          content: Text(l10n.transactionsDeleted),
          action: SnackBarAction(label: l10n.commonUndo, onPressed: () {}),
          duration: const Duration(seconds: 5),
        ),
      )
      .closed;
  if (reason != SnackBarClosedReason.action) {
    await container.read(transactionControllerProvider.notifier).delete(tx.id);
    final result = container.read(transactionControllerProvider);
    if (result.hasError && context.mounted) {
      await showFinan2ErrorSheet(
        context,
        title: l10n.transactionsDeleteFailed,
        message: friendlyErrorMessage(result.error!),
      );
    }
  }
  pending.restore(tx.id);
}
