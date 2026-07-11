import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/household/data/household_model.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../theme/app_theme.dart';
import 'finan2_coming_soon.dart';
import 'finan2_list_icon.dart';

/// The app's root navigation once a household exists: bottom nav with the
/// 5 destinations from the design mockup. Deudas/Metas are placeholders
/// until Fase 4/5.
class Finan2HomeShell extends StatefulWidget {
  const Finan2HomeShell({required this.household, super.key});

  final Household household;

  @override
  State<Finan2HomeShell> createState() => _Finan2HomeShellState();
}

class _Finan2HomeShellState extends State<Finan2HomeShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardScreen(household: widget.household),
      const TransactionsScreen(),
      const DebtsScreen(),
      const Finan2ComingSoon(title: 'Metas', icon: Finan2Icons.metas),
      SettingsScreen(household: widget.household),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Finan2Icons.inicio),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Finan2ListIcon(),
            label: 'Movimientos',
          ),
          const NavigationDestination(
            icon: Icon(Finan2Icons.deudas),
            label: 'Deudas',
          ),
          const NavigationDestination(
            icon: Icon(Finan2Icons.metas),
            label: 'Metas',
          ),
          const NavigationDestination(
            icon: Icon(Finan2Icons.ajustes),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
