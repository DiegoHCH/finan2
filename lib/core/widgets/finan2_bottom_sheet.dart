import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';
import 'finan2_field.dart';
import 'finan2_tile.dart';

/// A confirm/cancel prompt as a bottom sheet - the app never shows a
/// centered [AlertDialog] for these, always a sheet from the bottom.
/// Returns true only if the user tapped [confirmLabel]; false for Cancelar
/// or dismissing the sheet.
Future<bool> showFinan2ConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Finan2Space.xl, 0, Finan2Space.xl, Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: Finan2Space.sm),
              Text(message, style: TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45)),
              const SizedBox(height: Finan2Space.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: Text(sheetContext.l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: Finan2Space.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: destructive
                          ? FilledButton.styleFrom(backgroundColor: colors.expense)
                          : null,
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// A single-button error notice as a bottom sheet - the app never shows
/// errors in a [SnackBar], always a sheet the user must dismiss explicitly.
/// [title] and [confirmLabel] default to a generic "something went wrong" /
/// "got it" in the app's language.
Future<void> showFinan2ErrorSheet(
  BuildContext context, {
  String? title,
  required String message,
  String? confirmLabel,
}) {
  return _showFinan2NoticeSheet(
    context,
    title: title ?? context.l10n.coreSheetErrorTitle,
    message: message,
    confirmLabel: confirmLabel ?? context.l10n.commonGotIt,
    isError: true,
  );
}

/// A single-button informational notice as a bottom sheet - same rationale
/// as [showFinan2ErrorSheet], for non-error feedback (e.g. "email sent")
/// that the app also never puts in a [SnackBar].
Future<void> showFinan2InfoSheet(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) {
  return _showFinan2NoticeSheet(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel ?? context.l10n.commonGotIt,
  );
}

Future<void> _showFinan2NoticeSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isError = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Finan2Space.xl, 0, Finan2Space.xl, Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isError) ...[
                // .state .glyph in the over tone: an error reads as one at a glance.
                Finan2Tile(
                  icon: Finan2Icons.alerta,
                  tone: Finan2Tone(colors.expense, colors.expenseTint),
                  size: 44,
                ),
                const SizedBox(height: Finan2Space.md),
              ],
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: Finan2Space.sm),
              Text(message, style: TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45)),
              const SizedBox(height: Finan2Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// A single-field text prompt as a bottom sheet - same rationale as
/// [showFinan2ConfirmSheet]. Returns the entered text, or null if
/// cancelled/dismissed. The sheet is scroll-controlled and padded above the
/// keyboard, matching every other input sheet in the app (Nuevo aporte,
/// Registrar pago...).
///
/// [controller] is intentionally never disposed here - the sheet route is
/// still animating out when this function's Future resolves, and disposing
/// immediately crashes the still-visible TextFormField mid-transition. The
/// caller owns [controller] and may dispose it once it's done with it, but
/// not synchronously after this call.
Future<String?> showFinan2InputSheet(
  BuildContext context, {
  required String title,
  String? message,
  required String fieldLabel,
  required TextEditingController controller,
  bool obscureText = false,
  TextInputType? keyboardType,
  List<String>? autofillHints,
  String? confirmLabel,
}) {
  final resolvedConfirmLabel = confirmLabel ?? context.l10n.commonSave;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          Finan2Space.xl,
          0,
          Finan2Space.xl,
          MediaQuery.of(sheetContext).viewInsets.bottom + Finan2Space.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: Finan2Space.sm),
              Text(message, style: TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45)),
            ],
            const SizedBox(height: Finan2Space.md),
            Finan2Field(
              label: fieldLabel,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              autofillHints: autofillHints,
            ),
            const SizedBox(height: Finan2Space.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(sheetContext.l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: Finan2Space.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(controller.text),
                    child: Text(resolvedConfirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
