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
        title: 'No se pudo completar',
        message: error is BackupException || error is Finan2CryptoException
            ? error.toString()
            : friendlyErrorMessage(error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() => _run(() async {
        final bytes = await ref.read(backupControllerProvider.notifier).create();
        if (bytes == null) return;
        final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                Uint8List.fromList(bytes),
                mimeType: 'application/json',
                name: 'finan2-copia-$stamp.finan2',
              ),
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
        final confirmed = await showFinan2ConfirmSheet(
          context,
          title: 'Restaurar la copia',
          message: 'El hogar volverá a como estaba el '
              '${DateFormat("d 'de' MMMM 'de' y, h:mm a", 'es').format(info.createdAt)}. '
              'Lo que se haya creado después se borra y lo que cambió vuelve a '
              'como estaba, también para tu pareja.',
          confirmLabel: 'Restaurar',
          destructive: true,
        );
        if (!confirmed) return;
        final result = await backup.restore(bytes);
        if (result == null || !mounted) return;
        await showFinan2InfoSheet(
          context,
          title: 'Copia restaurada',
          message: [
            '${result.restored} registros restaurados'
                '${result.removed > 0 ? ' y ${result.removed} posteriores borrados' : ''}.',
            if (result.reattributed > 0)
              '${result.reattributed} registros de tu pareja que se habían borrado '
                  'quedan a tu nombre: solo puedes crear registros como tuyos. En los '
                  'movimientos se conserva quién pagó.',
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
            const Finan2AppTop(
              label: 'Copia de seguridad',
              title: 'Todo el hogar, cifrado',
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Text(
                    'La copia guarda cuentas, movimientos, presupuestos, deudas, metas, '
                    'facturas recurrentes y notas en un archivo cifrado con la llave del '
                    'hogar. Sin esa llave no se puede leer, así que puedes guardarlo en '
                    'tu correo o en la nube.',
                    style: textStyle,
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  Text(
                    'Solo se puede restaurar en este mismo hogar.',
                    style: textStyle,
                  ),
                  const SizedBox(height: Finan2Space.xl),
                  FilledButton.icon(
                    onPressed: _busy ? null : _create,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Crear copia'),
                  ),
                  const SizedBox(height: Finan2Space.sm),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _restore,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restaurar una copia'),
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
