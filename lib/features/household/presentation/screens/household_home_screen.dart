import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/household_model.dart';

/// Temporary landing screen for Fase 1: proves that two users signed in
/// separately land on the same shared household. The real dashboard comes
/// in a later phase.
class HouseholdHomeScreen extends ConsumerWidget {
  const HouseholdHomeScreen({required this.household, super.key});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final members = household.members;

    return Scaffold(
      appBar: AppBar(
        title: Text(household.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código del hogar', style: Theme.of(context).textTheme.bodySmall),
            SelectableText(
              household.inviteCode,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(letterSpacing: 3, color: Finan2Palette.brand),
            ),
            const SizedBox(height: Finan2Space.xl),
            Text('Miembros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Finan2Space.sm),
            for (var i = 0; i < members.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: Finan2Space.xs),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Finan2Sizes.avatar / 2,
                      backgroundColor:
                          i == 0 ? colors.userA : colors.userB,
                      child: Text(
                        _initial(household.memberInfo[members[i]]?.name),
                        style: const TextStyle(color: Colors.white),
                      ),
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
