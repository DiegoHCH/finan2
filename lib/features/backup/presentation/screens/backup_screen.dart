import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_prompt_page.dart';
import '../../../../l10n/l10n.dart';
import '../../data/backup_repository.dart';
import '../viewmodels/backup_providers.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  var _busy = false;

  /// Which of the two is running, for its button's spinner.
  var _restoring = false;

  Future<void> _run(Future<void> Function() action, {bool restoring = false}) async {
    setState(() {
      _busy = true;
      _restoring = restoring;
    });
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      await showFinan2ErrorSheet(
        context,
        title: context.l10n.backupErrorTitle,
        message: error is BackupException || error is Finan2CryptoException
            ? error.toString()
            : friendlyErrorMessage(error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() => _run(() async {
    final fileName = context.l10n.backupFileName(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final bytes = await ref.read(backupControllerProvider.notifier).create();
    if (bytes == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(Uint8List.fromList(bytes), mimeType: 'application/json', name: fileName),
        ],
      ),
    );
  });

  Future<void> _restore() => _run(() async {
    final file = await FilePicker.pickFile();
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final backup = ref.read(backupControllerProvider.notifier);
    final info = backup.inspect(bytes);
    if (!mounted) return;
    final l10n = context.l10n;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: l10n.backupRestoreTitle,
      message: l10n.backupRestoreMessage(DateFormat.yMMMMd().add_jm().format(info.createdAt)),
      confirmLabel: l10n.backupRestoreConfirm,
      destructive: true,
    );
    if (!confirmed) return;
    final result = await backup.restore(bytes);
    if (result == null || !mounted) return;
    await showFinan2InfoSheet(
      context,
      title: l10n.backupRestoredTitle,
      message: [
        result.removed > 0
            ? l10n.backupRestoredSummaryWithRemoved(result.restored, result.removed)
            : l10n.backupRestoredSummary(result.restored),
        if (result.reattributed > 0) l10n.backupReattributed(result.reattributed),
      ].join(' '),
    );
  }, restoring: true);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final busySpinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: colors.inkFaint),
    );
    return Scaffold(
      body: Finan2PromptPage(
        top: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, size: Finan2Sizes.iconMd, color: colors.inkSoft),
          ),
        ),
        title: l10n.backupTitle,
        message: l10n.backupDescription,
        // Creating is the screen's one action; restoring - rare and the
        // dangerous one - sits back on the sunken tone.
        actions: [
          FilledButton(
            onPressed: _busy ? null : _create,
            child: _busy && !_restoring ? busySpinner : Text(l10n.backupCreate),
          ),
          OutlinedButton(onPressed: _busy ? null : _restore, child: Text(l10n.backupRestoreAction)),
        ],
        children: [
          // What restoring does - for both, and it erases what came later -
          // is said before touching anything, not only in the confirmation.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 12.5, height: 1.5, color: colors.inkSoft),
                children: [
                  TextSpan(
                    text: l10n.backupRestoreLead,
                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink),
                  ),
                  TextSpan(text: l10n.backupRestoreNote),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
