import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_code_box.dart';

/// Shown right after creating a household: the code the creator shares with
/// their partner so they can join the same household.
class InviteHouseholdScreen extends StatelessWidget {
  const InviteHouseholdScreen({required this.inviteCode, super.key});

  final String inviteCode;

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
                'al mismo hogar.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.inkSoft),
              ),
              const SizedBox(height: Finan2Space.lg),
              Finan2CodeBox(code: inviteCode),
              const SizedBox(height: Finan2Space.lg),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: inviteCode));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar código'),
              ),
              const SizedBox(height: Finan2Space.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
