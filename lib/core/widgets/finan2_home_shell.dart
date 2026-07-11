import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/budget/presentation/viewmodels/budget_providers.dart';
import '../../features/categories/presentation/viewmodels/category_providers.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/debts/presentation/viewmodels/debt_providers.dart';
import '../../features/household/data/household_model.dart';
import '../../features/household/presentation/viewmodels/household_providers.dart';
import '../../features/notification_prefs/data/notification_prefs.dart';
import '../../features/notification_prefs/presentation/viewmodels/notification_prefs_providers.dart';
import '../../features/notifications/presentation/viewmodels/notification_providers.dart';
import '../../features/savings_goals/presentation/screens/savings_goals_screen.dart';
import '../../features/savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/viewmodels/transaction_providers.dart';
import '../notifications/notification_providers.dart';
import '../theme/app_theme.dart';
import 'finan2_list_icon.dart';

/// The app's root navigation once a household exists: bottom nav with the
/// 5 destinations from the design mockup. Also the integration point for
/// the notification scanner - it re-runs whenever debts/goals/budget/
/// transactions change while the app is open (there's no backend to
/// trigger it on a schedule), and (re)schedules the per-debt local payment
/// reminders.
class Finan2HomeShell extends ConsumerStatefulWidget {
  const Finan2HomeShell({required this.household, super.key});

  final Household household;

  @override
  ConsumerState<Finan2HomeShell> createState() => _Finan2HomeShellState();
}

class _Finan2HomeShellState extends ConsumerState<Finan2HomeShell> {
  var _index = 0;

  Future<void> _runScan() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return;
    final prefs =
        ref.read(notificationPrefsControllerProvider).value ?? NotificationPrefs.defaults;
    await ref.read(notificationScannerProvider).scan(
          householdId: householdId,
          currentUid: uid,
          debts: ref.read(debtsProvider).value ?? const [],
          goals: ref.read(savingsGoalsProvider).value ?? const [],
          budget: ref.read(currentMonthBudgetProvider).value ?? const {},
          transactionsThisMonth: ref.read(transactionsForMonthProvider).value ?? const [],
          categories: ref.read(categoriesProvider).value ?? const [],
          prefs: prefs,
          formatMoney: ref.read(moneyFormatterProvider),
        );
  }

  Future<void> _rescheduleDebtReminders() async {
    final prefs =
        ref.read(notificationPrefsControllerProvider).value ?? NotificationPrefs.defaults;
    if (!prefs.debtPayments) return;
    final debts = ref.read(debtsProvider).value ?? const [];
    try {
      await ref.read(notificationServiceProvider).scheduleDebtPaymentReminders(debts);
    } catch (_) {
      // Permission not granted yet (user hasn't opened notification prefs) -
      // scanning/in-app alerts still work regardless.
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _runScan();
      _rescheduleDebtReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(debtsProvider, (previous, next) {
      _runScan();
      _rescheduleDebtReminders();
    });
    ref.listen(savingsGoalsProvider, (previous, next) => _runScan());
    ref.listen(currentMonthBudgetProvider, (previous, next) => _runScan());
    ref.listen(transactionsForMonthProvider, (previous, next) => _runScan());

    final tabs = [
      DashboardScreen(household: widget.household),
      const TransactionsScreen(),
      const DebtsScreen(),
      const SavingsGoalsScreen(),
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
