import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_code_box.dart';

/// Shown after creating a household (or from its card in Ajustes): the invite
/// a member shares with their partner so they can join. Invites expire after
/// 7 days and only work once.
///
/// [shareCode] is `<code>.<key>` - the short human-readable invite code the
/// UI displays, plus the household's data encryption key riding along after
/// the dot (never sent to Firestore). Copying always copies the full string;
/// only the code half is shown in the big code box.
class InviteHouseholdScreen extends StatelessWidget {
  const InviteHouseholdScreen({required this.shareCode, super.key});

  final String shareCode;

  String get _displayCode => shareCode.split('.').first;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: Finan2Sizes.iconXl,
                color: brand,
              ),
              const SizedBox(height: Finan2Space.md),
              Text(
                'Invita a tu pareja',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Finan2Space.xs),
              Text(
                'Comparte este código para que entre con su propia cuenta '
                'al mismo hogar. Sirve una sola vez y vence en 7 días.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.inkSoft),
              ),
              const SizedBox(height: Finan2Space.lg),
              Finan2CodeBox(code: _displayCode),
              const SizedBox(height: Finan2Space.sm),
              Text(
                'Usa el botón de compartir y envíalo por WhatsApp o mensaje - '
                'no lo dictes de viva voz, lleva pegada una llave más larga '
                'que no se ve aquí. Sin el código completo, tu pareja no '
                'podrá ver los montos.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colors.inkSoft),
              ),
              const SizedBox(height: Finan2Space.lg),
              FilledButton.icon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text: shareCode,
                    title: 'Invitación a nuestro hogar en Finan2',
                    subject: 'Invitación a nuestro hogar en Finan2',
                  ),
                ),
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Compartir invitación'),
              ),
              const SizedBox(height: Finan2Space.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Omitir por ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
