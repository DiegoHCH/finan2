import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/accounts/presentation/viewmodels/account_providers.dart';
import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/budget/presentation/viewmodels/budget_providers.dart';
import '../../features/categories/presentation/viewmodels/category_providers.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/debts/presentation/viewmodels/debt_providers.dart';
import '../../features/household/presentation/screens/household_setup_screen.dart';
import '../../features/household/data/household_model.dart';
import '../../features/household/presentation/viewmodels/household_providers.dart';
import '../../features/investments/presentation/viewmodels/investment_providers.dart';
import '../../features/notification_prefs/data/notification_prefs.dart';
import '../../features/notification_prefs/presentation/viewmodels/notification_prefs_providers.dart';
import '../../features/notifications/presentation/viewmodels/notification_providers.dart';
import '../../features/recurring_bills/presentation/viewmodels/recurring_bill_providers.dart';
import '../../features/savings_challenge/presentation/viewmodels/savings_challenge_providers.dart';
import '../../features/savings_goals/presentation/screens/savings_goals_screen.dart';
import '../../features/savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/viewmodels/transaction_providers.dart';
import '../../features/transfers/presentation/viewmodels/transfer_providers.dart';
import '../../l10n/l10n.dart';
import '../notifications/notification_primer_sheet.dart';
import '../notifications/notification_providers.dart';
import '../pwa/ios_install_detection.dart';
import '../pwa/pwa_providers.dart';
import '../theme/app_theme.dart';
import 'finan2_list_icon.dart';
import 'finan2_missing_key_sheet.dart';
import '../observability/error_reporter.dart';

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
  var _installBannerDismissed = false;

  /// Shown once per app launch if this device doesn't have the household's
  /// data encryption key yet - awaited before the notification primer sheet
  /// below so the two never fight over showing a bottom sheet at once.
  Future<void> _maybeShowMissingKeySheet() async {
    // Creating it right now: the key may not be stored yet, but it will be.
    if (ref.read(householdSetupProvider).active) return;
    final hasKey = await ref.read(householdCryptoProvider).hasKey(widget.household.id);
    if (hasKey || !mounted) return;
    await showMissingKeySheet(context, widget.household);
  }

  Future<void> _runScan() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return;
    final prefs = ref.read(notificationPrefsControllerProvider).value ?? NotificationPrefs.defaults;
    final created = await ref
        .read(notificationScannerProvider)
        .scan(
          householdId: householdId,
          currentUid: uid,
          debts: ref.read(debtsProvider).value ?? const [],
          goals: ref.read(savingsGoalsProvider).value ?? const [],
          budget: ref.read(currentMonthBudgetProvider).value ?? const {},
          transactionsThisMonth: ref.read(transactionsForMonthProvider).value ?? const [],
          categories: ref.read(categoriesProvider).value ?? const [],
          accounts: ref.read(accountsProvider).value ?? const [],
          investments: ref.read(investmentsProvider).value ?? const [],
          recurringBills: ref.read(recurringBillsProvider).value ?? const [],
          transfers: ref.read(transfersProvider).value ?? const [],
          savingsChallenge: ref.read(savingsChallengeProvider).value,
          prefs: prefs,
        );
    for (final hit in created) {
      await ref
          .read(pushServiceProvider)
          .sendPush(
            householdId: householdId,
            excludeUid: hit.excludePushUid,
            title: hit.notification.title,
            body: hit.notification.body,
          );
    }
  }

  Future<void> _runRecurringBillScan() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return;
    // Not loaded yet: confirming against an empty list would discard
    // every pending marker as belonging to a deleted bill.
    final bills = ref.read(recurringBillsProvider).value;
    if (bills == null) return;
    final scanner = ref.read(recurringBillScannerProvider);
    await scanner.scan(householdId: householdId, currentUid: uid, bills: bills);
    final pending = ref.read(pendingBillsProvider).value ?? const [];
    if (pending.isEmpty) return;
    await scanner.confirmPending(
      householdId: householdId,
      currentUid: uid,
      bills: bills,
      pending: pending,
    );
  }

  Future<void> _registerPushToken() async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (householdId == null || uid == null) return;
    try {
      await ref.read(pushServiceProvider).registerToken(householdId, uid);
    } catch (e, st) {
      // Permission denied or unsupported platform - in-app alerts still work.
      ErrorReporter.recoverable(e, st, reason: 'push token registration failed');
    }
  }

  static const _notifPrimerShownKey = 'notif_primer_shown';

  /// Registering the push token is what triggers the OS notification
  /// permission prompt automatically on first launch - shows our own
  /// explainer bottom sheet once, right before that happens, instead of
  /// hitting the user with a bare system dialog with no context.
  var _setupOpen = false;

  /// Right after creating the household - see householdSetupProvider.
  void _openSetup() {
    final shareCode = ref.read(householdSetupProvider).shareCode;
    if (shareCode == null || _setupOpen || !mounted) return;
    _setupOpen = true;
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => HouseholdSetupScreen(shareCode: shareCode)));
  }

  /// The primer waited for HouseholdSetupScreen to finish.
  var _primerDeferred = false;

  Future<void> _maybeRegisterPushToken() async {
    if (ref.read(householdSetupProvider).active) {
      _primerDeferred = true;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_notifPrimerShownKey) == true) {
      await _registerPushToken();
      return;
    }
    await prefs.setBool(_notifPrimerShownKey, true);
    if (!mounted) return;
    final proceed = await showNotificationPrimerSheet(context);
    if (proceed) {
      await _registerPushToken();
    }
  }

  Future<void> _rescheduleDebtReminders() async {
    final prefs = ref.read(notificationPrefsControllerProvider).value ?? NotificationPrefs.defaults;
    if (!prefs.debtPayments) return;
    final debts = ref.read(debtsProvider).value ?? const [];
    try {
      await ref.read(notificationServiceProvider).scheduleDebtPaymentReminders(debts);
    } catch (e, st) {
      // Without exact-alarm permission (user hasn't opened notification
      // prefs) this is expected - scanning/in-app alerts still work regardless.
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') return;
      ErrorReporter.recoverable(e, st, reason: 'debt reminders not scheduled');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Created a moment ago and the share code is already there.
      _openSetup();
      await _maybeShowMissingKeySheet();
      _runScan();
      _rescheduleDebtReminders();
      _runRecurringBillScan();
      _maybeRegisterPushToken();
      ref.read(persistentStorageStatusProvider.notifier).requestIfNeeded();
    });
    // FCM doesn't surface a system-tray alert for messages that arrive while
    // the app is foregrounded - show it ourselves the same way local
    // reminders already are.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      ref
          .read(notificationServiceProvider)
          .showNow(title: notification.title ?? '', body: notification.body ?? '');
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
    ref.listen(recurringBillsProvider, (previous, next) {
      _runScan();
      _runRecurringBillScan();
    });
    ref.listen(householdSetupProvider, (previous, next) {
      if (next.shareCode != null && previous?.shareCode == null) _openSetup();
      if (!next.active && _primerDeferred) {
        _primerDeferred = false;
        _maybeRegisterPushToken();
      }
    });
    ref.listen(pendingBillsProvider, (previous, next) {
      if (next.value?.isNotEmpty ?? false) _runRecurringBillScan();
    });
    ref.listen(accountsProvider, (previous, next) => _runScan());
    ref.listen(investmentsProvider, (previous, next) => _runScan());
    ref.listen(transfersProvider, (previous, next) => _runScan());
    ref.listen(categoriesProvider, (previous, next) => _runScan());
    ref.listen(savingsChallengeProvider, (previous, next) => _runScan());

    final tabs = [
      DashboardScreen(household: widget.household),
      const TransactionsScreen(),
      const DebtsScreen(),
      const SavingsGoalsScreen(),
      SettingsScreen(household: widget.household),
    ];

    final showInstallBanner = kIsWeb && !_installBannerDismissed && isIOSSafariNotInstalled;

    return Scaffold(
      body: Column(
        children: [
          if (showInstallBanner)
            MaterialBanner(
              content: Text(context.l10n.coreInstallBanner),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _installBannerDismissed = true),
                  child: Text(context.l10n.commonGotIt),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(index: _index, children: tabs),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Finan2Icons.inicio),
            label: context.l10n.coreHomeTabHome,
          ),
          NavigationDestination(
            icon: const Finan2ListIcon(),
            label: context.l10n.coreHomeTabMovements,
          ),
          NavigationDestination(
            icon: const Icon(Finan2Icons.deudas),
            label: context.l10n.coreHomeTabDebts,
          ),
          NavigationDestination(
            icon: const Icon(Finan2Icons.metas),
            label: context.l10n.coreHomeTabGoals,
          ),
          NavigationDestination(
            icon: const Icon(Finan2Icons.ajustes),
            label: context.l10n.coreHomeTabSettings,
          ),
        ],
      ),
    );
  }
}
