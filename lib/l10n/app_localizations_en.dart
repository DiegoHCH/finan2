// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finan2';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonName => 'Name';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonDate => 'Date';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonAccount => 'Account';

  @override
  String get recurringBillsTitle => 'Recurring bills';

  @override
  String recurringBillsMonthlyTotal(String amount) {
    return '$amount a month';
  }

  @override
  String get recurringBillsAutoBadge => 'Auto';

  @override
  String get recurringBillsEmptyTitle => 'No recurring bills yet';

  @override
  String get recurringBillsEmptyDescription =>
      'Schedule rent, utilities or your salary so they\'re logged on their own every month.';

  @override
  String get recurringBillsEmptyAction => '+ New recurring bill';

  @override
  String get recurringBillsAutoLogged => 'Logged automatically';

  @override
  String recurringBillsActiveCount(int count) {
    return '$count active';
  }

  @override
  String get recurringBillsStatusPaused => 'paused';

  @override
  String get recurringBillsStatusEnded => 'ended';

  @override
  String get recurringBillsTypeIncome => 'Income';

  @override
  String get recurringBillsTypeBill => 'Bill';

  @override
  String get recurringBillsNewTitle => 'New recurring bill';

  @override
  String get recurringBillsEditTitle => 'Edit recurring bill';

  @override
  String get recurringBillsMissingFields => 'Fill in the name, amount, category and account.';

  @override
  String get recurringBillsSemimonthlyDayTitle => 'Pick a day up to the 15th';

  @override
  String get recurringBillsSemimonthlyDayMessage =>
      'A twice-a-month bill repeats 15 days after the first date. Pick a first payment between the 1st and the 15th - for example the 15th to get paid on the 15th and the 30th.';

  @override
  String get recurringBillsDelete => 'Delete recurring bill';

  @override
  String recurringBillsDeleteMessage(String name) {
    return '\"$name\" will be deleted and stop being logged. Transactions it already created stay. This can\'t be undone. If you only want to stop it for a while, pause it.';
  }

  @override
  String get recurringBillsNoCategories =>
      'No categories of this type yet. Create them in Settings.';

  @override
  String get recurringBillsNoAccounts => 'No accounts yet. Create them in Settings.';

  @override
  String get recurringBillsSelectAccount => 'Select an account';

  @override
  String get recurringBillsRepeats => 'Repeats';

  @override
  String get recurringBillsFrom => 'From';

  @override
  String get recurringBillsFirstTime => 'First time';

  @override
  String recurringBillsLoggedOn(String schedule) {
    return 'Logged $schedule.';
  }

  @override
  String get recurringBillsUntil => 'Until';

  @override
  String get recurringBillsNoEndDate => 'No end date';

  @override
  String get recurringBillsRemoveEndDate => 'Remove end date';

  @override
  String get recurringBillsPaused => 'Paused';

  @override
  String get recurringBillsPausedHint =>
      'Nothing is logged while it\'s paused. When you resume it, the dates that went by aren\'t logged.';

  @override
  String get recurringBillsFrequencyWeekly => 'Weekly';

  @override
  String get recurringBillsFrequencyBiweekly => 'Every 2 weeks';

  @override
  String get recurringBillsFrequencySemimonthly => 'Twice a month';

  @override
  String get recurringBillsFrequencyMonthly => 'Monthly';

  @override
  String get recurringBillsFrequencyYearly => 'Yearly';

  @override
  String recurringBillsScheduleWeekly(String weekday) {
    return 'every $weekday';
  }

  @override
  String recurringBillsScheduleBiweekly(String weekday) {
    return 'every 2 weeks, on $weekday';
  }

  @override
  String recurringBillsScheduleSemimonthly(int day, int secondDay) {
    return 'on days $day and $secondDay';
  }

  @override
  String recurringBillsScheduleMonthly(String day) {
    return 'monthly, on day $day';
  }

  @override
  String recurringBillsScheduleYearly(String date) {
    return 'every year, $date';
  }

  @override
  String get monthlyNotesTitle => 'Notes';

  @override
  String get monthlyNotesThisMonth => 'This month\'s notes';

  @override
  String get monthlyNotesNextMonth => 'For next month';

  @override
  String get monthlyNotesEmpty => 'Tap to add notes.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsNewCount(int count) {
    return '$count new';
  }

  @override
  String get notificationsUpToDate => 'All caught up';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty =>
      'No notifications yet. Payment, goal and budget alerts will show up here.';

  @override
  String notificationsMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String notificationsHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String notificationsDaysAgo(int days) {
    return '$days d ago';
  }

  @override
  String notificationsDebtDueTodayTitle(String name) {
    return '$name is due today';
  }

  @override
  String notificationsDebtDueTodayBody(String name) {
    return 'Today is the payment day for your $name debt.';
  }

  @override
  String notificationsDebtDueSoonTitle(String name) {
    return '$name payment coming up';
  }

  @override
  String notificationsDebtDueSoonBody(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Your $name payment is due in $_temp0.';
  }

  @override
  String get notificationsGoalNearTitle => 'Almost at your goal!';

  @override
  String notificationsGoalNearBody(String name, int percent) {
    return '$name is at $percent%.';
  }

  @override
  String get notificationsBudgetExceededTitle => 'You went over budget';

  @override
  String notificationsBudgetExceededBody(String category) {
    return '$category went over plan this month.';
  }

  @override
  String get notificationsUnknownCategory => 'A category';

  @override
  String get notificationsContributionTitle => 'Contribution added';

  @override
  String notificationsContributionBody(String goal) {
    return 'Your partner added a contribution to $goal.';
  }

  @override
  String get notificationsPartnerMovementTitle => 'New transaction';

  @override
  String get notificationsPartnerMovementBody => 'Your partner logged a transaction.';

  @override
  String get notificationsPartnerTransferTitle => 'New transfer';

  @override
  String get notificationsPartnerTransferBody => 'Your partner logged a transfer between accounts.';

  @override
  String get notificationsPartnerDebtTitle => 'New debt';

  @override
  String get notificationsPartnerAccountTitle => 'New account';

  @override
  String get notificationsPartnerInvestmentTitle => 'New investment';

  @override
  String get notificationsPartnerBillTitle => 'New recurring bill';

  @override
  String get notificationsPartnerCategoryTitle => 'New category';

  @override
  String get notificationsPartnerChallengeTitle => 'New savings challenge';

  @override
  String get notificationsPartnerGoalTitle => 'New savings goal';

  @override
  String get notificationPrefsTitle => 'Preferences';

  @override
  String get notificationPrefsRemindersHeader => 'REMINDERS';

  @override
  String get notificationPrefsDailyReminder => 'Daily reminder';

  @override
  String get notificationPrefsDebtPayments => 'Debt payments';

  @override
  String get notificationPrefsGoalProgress => 'Goal progress';

  @override
  String get notificationPrefsAlertsHeader => 'ALERTS';

  @override
  String get notificationPrefsBudgetExceeded => 'Over budget';

  @override
  String get notificationPrefsPartnerActivity => 'My partner\'s activity';

  @override
  String get notificationPrefsWeeklySummary => 'Weekly summary';

  @override
  String get exportTitle => 'Export report';

  @override
  String get exportSubtitle => 'PDF or CSV';

  @override
  String get exportCsvHint =>
      'One file per section, with unformatted amounts and YYYY-MM-DD dates, ready for a spreadsheet.';

  @override
  String get exportPeriod => 'Period';

  @override
  String get exportPeriodThisMonth => 'This month';

  @override
  String get exportPeriodQuarter => 'Quarter';

  @override
  String get exportPeriodYear => 'Year';

  @override
  String get exportInclude => 'Include in the report';

  @override
  String get exportTransactions => 'Transactions';

  @override
  String get exportBudget => 'Budget';

  @override
  String get exportDebtsAndSavings => 'Debts and savings';

  @override
  String get exportDebts => 'Debts';

  @override
  String get exportSavingsGoals => 'Savings goals';

  @override
  String get exportGeneratePdf => 'Create PDF';

  @override
  String get exportGenerateCsv => 'Create CSV';

  @override
  String get exportPdfFileName => 'finan2_report.pdf';

  @override
  String get exportNoData => 'No data for this period.';

  @override
  String get exportColumnType => 'Type';

  @override
  String get exportColumnPaidBy => 'Paid by';

  @override
  String get exportColumnTags => 'Tags';

  @override
  String get exportColumnPlanned => 'Planned';

  @override
  String get exportColumnActual => 'Actual';

  @override
  String get exportColumnBalance => 'Balance';

  @override
  String get exportColumnRate => 'Annual rate';

  @override
  String get exportColumnRatePercent => 'Annual rate (%)';

  @override
  String get exportColumnSaved => 'Saved';

  @override
  String get exportColumnTarget => 'Target';

  @override
  String get exportColumnCompleted => '% Complete';

  @override
  String get exportColumnCompletedPercent => 'Complete (%)';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupSubtitle => 'Your whole household, encrypted';

  @override
  String get backupDescription =>
      'The backup keeps accounts, transactions, budgets, debts, goals, recurring bills and notes in a file encrypted with the household key. Without that key no one can read it, so you can keep it in your email or in the cloud.';

  @override
  String get backupSameHouseholdOnly => 'It can only be restored to this same household.';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupRestoreAction => 'Restore a backup';

  @override
  String get backupErrorTitle => 'Couldn\'t finish';

  @override
  String backupFileName(String date) {
    return 'finan2-backup-$date.finan2';
  }

  @override
  String get backupRestoreTitle => 'Restore backup';

  @override
  String backupRestoreMessage(String date) {
    return 'The household will go back to how it was on $date. Anything created since is deleted and anything changed goes back to how it was, for your partner too.';
  }

  @override
  String get backupRestoreConfirm => 'Restore';

  @override
  String get backupRestoredTitle => 'Backup restored';

  @override
  String backupRestoredSummary(int restored) {
    String _temp0 = intl.Intl.pluralLogic(
      restored,
      locale: localeName,
      other: '$restored records restored',
      one: '1 record restored',
    );
    return '$_temp0.';
  }

  @override
  String backupRestoredSummaryWithRemoved(int restored, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      restored,
      locale: localeName,
      other: '$restored records restored',
      one: '1 record restored',
    );
    String _temp1 = intl.Intl.pluralLogic(
      removed,
      locale: localeName,
      other: '$removed newer ones deleted',
      one: '1 newer one deleted',
    );
    return '$_temp0 and $_temp1.';
  }

  @override
  String backupReattributed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count deleted records of your partner\'s are now in your name: you can only create records as yourself. Transactions keep who paid.',
      one:
          '1 deleted record of your partner\'s is now in your name: you can only create records as yourself. Transactions keep who paid.',
    );
    return '$_temp0';
  }

  @override
  String get backupErrorOtherHousehold =>
      'This backup is from another household. It can only be restored to the household it was made in.';

  @override
  String get backupErrorDamaged => 'The backup is damaged or was modified. It can\'t be opened.';

  @override
  String get backupErrorNewerVersion =>
      'This backup was made with a newer version of Finan2. Update the app.';

  @override
  String get backupErrorNotABackup => 'This file isn\'t a Finan2 backup.';

  @override
  String backupErrorUnsupportedType(String type) {
    return 'Unsupported data type in the backup: $type';
  }
}
