import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_avatar.dart';
import '../../../../core/widgets/finan2_code_box.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../household/data/household_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({required this.household, super.key});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;
    final members = household.members;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(Finan2Space.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [brand, colors.brandDeep],
              ),
              borderRadius: BorderRadius.circular(Finan2Radius.card),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: members.isEmpty ? 0 : (30.0 + (members.length - 1) * 21),
                  height: 30,
                  child: Stack(
                    children: [
                      for (var i = 0; i < members.length; i++)
                        Positioned(
                          left: i * 21.0,
                          child: Finan2Avatar(
                            label: _initial(household.memberInfo[members[i]]?.name),
                            memberIndex: i,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Finan2Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        household.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${members.length} miembro${members.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Finan2Space.sm),
          Center(child: Finan2CodeBox(code: household.inviteCode)),
          const SizedBox(height: Finan2Space.lg),
          Finan2ListCard(
            children: [
              Finan2ListRow(
                icon: Finan2Icons.categorias,
                label: 'Categorías',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),
              Finan2ListRow(
                icon: Finan2Icons.cuentas,
                label: 'Cuentas',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: Finan2Space.lg),
          OutlinedButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            style: OutlinedButton.styleFrom(foregroundColor: colors.expense),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

String _initial(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  return name.trim().substring(0, 1).toUpperCase();
}
