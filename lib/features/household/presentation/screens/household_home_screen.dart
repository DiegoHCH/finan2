import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_code_box.dart';
import '../../data/household_model.dart';

/// Placeholder "Inicio" tab until the real dashboard lands (Fase 3).
class HouseholdHomeScreen extends StatelessWidget {
  const HouseholdHomeScreen({required this.household, super.key});

  final Household household;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household.members;

    return Scaffold(
      appBar: AppBar(title: Text(household.name)),
      body: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código del hogar', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Finan2Space.xs),
            Finan2CodeBox(code: household.inviteCode),
            const SizedBox(height: Finan2Space.xl),
            Text('Miembros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Finan2Space.sm),
            for (var i = 0; i < members.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: Finan2Space.xs),
                child: Row(
                  children: [
                    Finan2Avatar(
                      label: _initial(household.memberInfo[members[i]]?.name),
                      memberIndex: i,
                    ),
                    const SizedBox(width: Finan2Space.sm),
                    Text(
                      household.memberInfo[members[i]]?.name ?? members[i],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            if (members.length < 2) ...[
              const SizedBox(height: Finan2Space.lg),
              Text(
                'Comparte el código de arriba con tu pareja para que se una '
                'a este hogar.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.inkSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _initial(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  return name.trim().substring(0, 1).toUpperCase();
}
