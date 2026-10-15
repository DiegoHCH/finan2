import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/crypto/household_crypto.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
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

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
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
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final textStyle = TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: context.l10n.backupTitle,
              title: context.l10n.backupSubtitle,
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Text(context.l10n.backupDescription, style: textStyle),
                  const SizedBox(height: Finan2Space.sm),
                  Text(context.l10n.backupSameHouseholdOnly, style: textStyle),
                  const SizedBox(height: Finan2Space.xl),
                  FilledButton.icon(
                    onPressed: _busy ? null : _create,
                    icon: const Icon(Icons.save_alt),
                    label: Text(context.l10n.backupCreate),
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _restore,
                    icon: const Icon(Icons.restore),
                    label: Text(context.l10n.backupRestoreAction),
                  ),
                  if (_busy) ...[
                    const SizedBox(height: Finan2Space.lg),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
