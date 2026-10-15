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
  String budgetTitle(String month) {
    return 'Budget · $month';
  }

  @override
  String budgetPlannedTotal(String amount) {
    return '$amount planned';
  }

  @override
  String budgetAssignedPct(int pct) {
    return '$pct% assigned';
  }

  @override
  String get budgetPreviousMonth => 'Previous month';

  @override
  String get budgetNextMonth => 'Next month';

  @override
  String get budgetLeftToBudget => 'Left to budget';

  @override
  String get budgetNoIncomeYet => 'Log this month\'s income';

  @override
  String get budgetOverBudgeted => 'Over-budgeted';

  @override
  String get budgetVsActual => 'Budget vs. actual';

  @override
  String get budgetEmpty => 'You haven\'t budgeted any category yet.';

  @override
  String get budgetAddCategory => '+ Budget another category';

  @override
  String budgetForCategory(String category) {
    return 'Budget for $category';
  }

  @override
  String get budgetCopyTitle => 'This month has no budget yet';

  @override
  String budgetCopyMessage(int count, String month) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copy the $count categories you planned in $month.',
      one: 'Copy the category you planned in $month.',
    );
    return '$_temp0';
  }

  @override
  String get budgetCopying => 'Copying…';

  @override
  String budgetCarryIncluded(String amount) {
    return 'Includes $amount left over from before';
  }

  @override
  String budgetCarryDeducted(String amount) {
    return 'Minus $amount overspent before';
  }

  @override
  String get annualSummaryTitle => 'Annual summary';

  @override
  String get annualSummaryPreviousYear => 'Previous year';

  @override
  String get annualSummaryNextYear => 'Next year';

  @override
  String get annualSummaryEarned => 'Earned';

  @override
  String get annualSummarySpent => 'Spent';

  @override
  String get annualSummarySaved => 'Saved';

  @override
  String get annualSummarySpendByMonth => 'Spending by month';

  @override
  String get dashboardHousehold => 'Household';

  @override
  String get dashboardNetWorth => 'Net worth';

  @override
  String get dashboardNetWorthFormula => 'Accounts + savings + investments − debts';

  @override
  String get dashboardIncome => 'Income';

  @override
  String get dashboardExpenses => 'Expenses';

  @override
  String get dashboardWhereMoneyGoes => 'Where the money goes';

  @override
  String get dashboardNoCategorizedSpending => 'No categorized spending this month.';

  @override
  String get savingsChallengeTitle => 'Savings challenge';

  @override
  String get savingsChallengeDeleteTitle => 'Delete savings challenge';

  @override
  String savingsChallengeDeleteMessage(String name) {
    return '\"$name\" and its checked-off progress will be deleted. This can\'t be undone.';
  }

  @override
  String get savingsChallengeIntro =>
      'Set up your household\'s savings challenge: boxes with fixed amounts you check off as you save them.';

  @override
  String get savingsChallengeSize => 'Size';

  @override
  String get savingsChallengeSizeSmall => 'Small';

  @override
  String get savingsChallengeSizeMedium => 'Medium';

  @override
  String get savingsChallengeSizeLarge => 'Large';

  @override
  String savingsChallengeSizeOption(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boxes',
      one: '1 box',
    );
    return '$size ($_temp0)';
  }

  @override
  String get savingsChallengeCreate => 'Create challenge';

  @override
  String get savingsChallengeGoal => 'You\'ve got this! Challenge goal';

  @override
  String get savingsChallengeProgress => 'Progress';

  @override
  String get savingsChallengeMarkHint => 'Check off each box as you save';

  @override
  String get authLoginWelcome => 'Welcome to Finan';

  @override
  String get authLoginSubtitle =>
      'Sign in with your account. You each have your own; the household\'s finances are shared.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authOr => 'or';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authCreateAccountHere => 'Create one';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordMessage => 'We\'ll email you a link to choose a new password.';

  @override
  String get authResetPasswordSend => 'Send';

  @override
  String get authResetPasswordSentTitle => 'Email sent';

  @override
  String authResetPasswordSentMessage(String email) {
    return 'If $email has an account, you\'ll get an email to recover it.';
  }

  @override
  String get authSignupTitle => 'Create your account';

  @override
  String get authSignupSubtitle => 'Sign up to start organizing your household\'s finances.';

  @override
  String get authNameRequired => 'Enter your name';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get householdDefaultName => 'Our home';

  @override
  String get householdCreateJoinTitle => 'One last step';

  @override
  String get householdCreateJoinSubtitle =>
      'Start a new household or join the one your partner already has.';

  @override
  String get householdCreateOptionTitle => 'Create a new household';

  @override
  String get householdCreateOptionSubtitle => 'Start fresh and invite your partner.';

  @override
  String get householdJoinOptionTitle => 'Join with a code';

  @override
  String get householdJoinOptionSubtitle => 'Your partner already created the household.';

  @override
  String get householdNameLabel => 'Household name';

  @override
  String get householdNameRequired => 'Give your household a name';

  @override
  String get householdCodeLabel => 'Household code (paste the full code)';

  @override
  String get householdCodeRequired => 'Enter the code you were sent';

  @override
  String get householdCreateButton => 'Create household';

  @override
  String get householdJoinButton => 'Join household';

  @override
  String get householdJoinedWithoutKeyTitle => 'You joined the household';

  @override
  String get householdJoinedWithoutKeyMessage =>
      'This code didn\'t include the key to see amounts. Ask your partner to share the full code from the household card in Settings.';

  @override
  String householdSetupStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get householdSetupCurrencyTitle => 'Household currency';

  @override
  String get householdSetupCurrencyDescription =>
      'The one you keep your books in. You can change it in Settings.';

  @override
  String get householdCurrencyCop => 'Colombian peso';

  @override
  String get householdCurrencyUsd => 'US dollar';

  @override
  String get householdSetupAccountTitle => 'Your first account';

  @override
  String get householdSetupAccountDescription =>
      'Where money comes in and goes out: a bank, a wallet or cash. Enter today\'s balance to start from the real figure.';

  @override
  String get householdSetupAccountNameMissingTitle => 'Give it a name';

  @override
  String get householdSetupAccountNameMissingMessage =>
      'Such as the bank or “Cash”. Or skip this step.';

  @override
  String get householdSetupBalanceToday => 'Today\'s balance';

  @override
  String get householdSetupCreateAccount => 'Create account';

  @override
  String get householdRecoveryPhraseTitle => 'Recovery phrase';

  @override
  String get householdSetupRecoveryDescription =>
      'Amounts are encrypted with a key that lives only on your phones. If you both lose it, these 12 words bring it back. They\'re shown only once: write them down on paper and keep them with your partner.';

  @override
  String get householdGeneratePhrase => 'Generate phrase';

  @override
  String get householdSetupLater => 'Later, from Settings';

  @override
  String get householdInviteTitle => 'Invite your partner';

  @override
  String get householdInviteMessage =>
      'Share this code so they can join the same household with their own account. It works once and expires in 7 days.';

  @override
  String get householdInviteWarning =>
      'Use the share button and send it by WhatsApp or text - don\'t read it out loud, it carries a longer key you can\'t see here. Without the full code, your partner won\'t be able to see amounts.';

  @override
  String get householdInviteShareSubject => 'Invitation to our household on Finan2';

  @override
  String get householdInviteShare => 'Share invite';

  @override
  String get householdInviteSkip => 'Skip for now';

  @override
  String get householdRecoveryConfirmMessage =>
      'If neither of you ever has the household key on your device, these 12 words recover the amounts. You\'ll see them only once: write them down on paper and keep them with your partner. Any previous phrase or PIN will stop working.';

  @override
  String get householdRecoverySavedTitle => 'Phrase saved';

  @override
  String get householdRecoverySavedMessage =>
      'From now on, this phrase can recover the household\'s amounts on any device.';

  @override
  String householdRecoverySaveFailed(String error) {
    return 'The new phrase couldn\'t be saved, so it won\'t work: the previous one is still valid. $error';
  }

  @override
  String get householdRecoveryShowTitle => 'Write down these 12 words';

  @override
  String get householdRecoveryShowMessage =>
      'In this order. They won\'t be shown again and Finan2 doesn\'t keep them.';

  @override
  String get householdRecoveryShowDone => 'I\'ve written them down';

  @override
  String get householdKeyIncomplete =>
      'That code doesn\'t include the full key. Ask your partner to share it again from the household card in Settings.';

  @override
  String get householdKeyWrongHousehold =>
      'That key isn\'t for this household. Check that it\'s the code your partner shared from this same household.';

  @override
  String get householdRecoveryNotSet => 'This household has no recovery phrase set up.';

  @override
  String get householdRecoveryPhraseMismatch =>
      'That phrase doesn\'t match this household. If your partner generated a new one, the old one stopped working.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeading => 'Preferences';

  @override
  String get settingsMissingKeyBanner =>
      'This device doesn\'t have the key to see this household\'s amounts. Paste the code your partner shared from their household card, or type the recovery phrase.';

  @override
  String get settingsPasteCodeToUnlock => 'Paste code to unlock amounts';

  @override
  String get settingsUseRecoveryPhrase => 'Use recovery phrase';

  @override
  String get settingsStorageWarning =>
      'Your browser didn\'t guarantee that Finan2\'s data will be kept. If you don\'t open the app for several days, you could lose access to this device\'s encrypted amounts. Make sure you have a recovery phrase in Account settings.';

  @override
  String settingsMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get settingsTapToInvite => 'tap to invite';

  @override
  String get settingsTapToShareKey => 'tap to share the key';

  @override
  String get settingsFinancialSettings => 'Financial settings';

  @override
  String get settingsFinancialSettingsSubtitle => 'Currency, year and categories';

  @override
  String get settingsAccountSettings => 'Account settings';

  @override
  String get settingsAccountSettingsSubtitle => 'Household and notifications';

  @override
  String get settingsExportReport => 'Export report';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBudget => 'Budget';

  @override
  String settingsBudgetPlanned(String amount) {
    return '$amount planned';
  }

  @override
  String get settingsAnnualSummary => 'Annual summary';

  @override
  String get settingsInvestments => 'Investments';

  @override
  String get settingsNotificationCenter => 'Notification center';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsUnlockAmountsTitle => 'Unlock amounts';

  @override
  String get settingsUnlockAmountsMessage =>
      'Paste the full code (with the key after the dot) your partner copied from their household card in Settings.';

  @override
  String get settingsUnlockCodeLabel => 'Full code (CODE.key)';

  @override
  String get settingsUnlock => 'Unlock';

  @override
  String get settingsAmountsUnlockedTitle => 'Amounts unlocked';

  @override
  String get settingsAmountsUnlockedMessage => 'You can now see this household\'s amounts.';

  @override
  String get settingsRecoveryPhraseMessage =>
      'Type the 12 words in order, separated by spaces. Accents and capitals don\'t matter.';

  @override
  String get settingsRecoveryPhraseLabel => 'Phrase (12 words)';

  @override
  String get settingsNoKeyToInvite =>
      'This device doesn\'t have the household key, so it can\'t invite anyone who\'d see the amounts.';

  @override
  String get settingsNoKeyToShare => 'This device doesn\'t have the household key either.';

  @override
  String get settingsKeyShareSubject => 'Our household\'s key on Finan2';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLightSubtitle => 'Always a light background.';

  @override
  String get settingsThemeDarkSubtitle => 'Always a dark background.';

  @override
  String get settingsThemeSystemSubtitle => 'Follows your device setting.';

  @override
  String get settingsLeaveHousehold => 'Leave household';

  @override
  String settingsLeaveHouseholdSoloMessage(String name) {
    return 'You\'re the only member of \"$name\". If you leave, all its data will be deleted for good: accounts, transactions, budgets, debts and goals.';
  }

  @override
  String settingsLeaveHouseholdMessage(String name) {
    return 'You\'re leaving \"$name\". Your accounts, transactions and other data stay available to the rest of the household. You can create or join another one later.';
  }

  @override
  String get settingsLeaveAndDelete => 'Leave and delete';

  @override
  String get settingsLeave => 'Leave';

  @override
  String get settingsMyName => 'My name';

  @override
  String get settingsHouseholdMembers => 'Household members';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsRecoveryPhraseHint => 'Recover amounts if you lose the key';

  @override
  String get settingsDeleteAccount => 'Delete my account';

  @override
  String settingsDeleteAccountSoloMessage(String name) {
    return 'You\'ll permanently lose access to Finan2, and this can\'t be undone. Since you\'re the only member, all of \"$name\"\'s data will be deleted too.';
  }

  @override
  String get settingsDeleteAccountMessage =>
      'You\'ll permanently lose access to Finan2, and this can\'t be undone. You\'ll also leave your household - its data stays available to the other member.';

  @override
  String get settingsCurrencyCop => 'Peso COP · \$';

  @override
  String get settingsCurrencyUsd => 'Dollar USD · US\$';

  @override
  String get settingsWeekMonday => 'Monday';

  @override
  String get settingsWeekSunday => 'Sunday';

  @override
  String get settingsPickActiveYear => 'Select the active year';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsActiveYear => 'Active year';

  @override
  String get settingsWeekStartsOn => 'Week starts on';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get coreSheetErrorTitle => 'Something went wrong';

  @override
  String get coreReauthTitle => 'Confirm your password';

  @override
  String get corePassword => 'Password';

  @override
  String get corePeriodPrevious => 'Previous';

  @override
  String get corePeriodBackToToday => 'Back to today';

  @override
  String get coreGoToSettings => 'Go to Settings';

  @override
  String get coreMissingKeyInline =>
      'This household\'s key is missing, so amounts can\'t be shown.';

  @override
  String get coreMissingKeyTitle => 'This household\'s key is missing';

  @override
  String get coreMissingKeyBody =>
      'This device can\'t see or record amounts yet. Ask your partner for the full code (with the key after the dot) or use the household\'s recovery phrase in Settings to unlock them.';

  @override
  String get coreNotificationPrimerTitle => 'Turn on notifications';

  @override
  String get coreNotificationPrimerBody =>
      'We\'ll let you know when your partner logs something, a payment is coming up, or you go over budget. You can change this later in Settings.';

  @override
  String get coreNotificationPrimerEnable => 'Turn on notifications';

  @override
  String get coreInstallBanner =>
      'To get notifications and keep your data from being cleared, install Finan2: tap Share, then \"Add to Home Screen\".';

  @override
  String get coreHomeTabHome => 'Home';

  @override
  String get coreHomeTabMovements => 'Activity';

  @override
  String get coreHomeTabDebts => 'Debts';

  @override
  String get coreHomeTabGoals => 'Goals';

  @override
  String get coreHomeTabSettings => 'Settings';

  @override
  String get coreSplashTagline => 'Household finances - for two';

  @override
  String get errorInvalidEmail => 'That email isn\'t valid.';

  @override
  String get errorWrongCredentials => 'Wrong email or password.';

  @override
  String get errorEmailInUse => 'There\'s already an account with that email.';

  @override
  String get errorWeakPassword => 'That password is too weak.';

  @override
  String get errorNetwork => 'Connection problem, please try again.';

  @override
  String errorUnknownWithCode(String code) {
    return 'Something went wrong ($code).';
  }

  @override
  String get errorInviteNotFound =>
      'That invite doesn\'t exist or has expired. Ask your partner for a new one from Settings.';

  @override
  String get errorHouseholdFull =>
      'We couldn\'t add you: the household already has 2 members or the invite is no longer valid.';

  @override
  String get errorGeneric => 'Something went wrong, please try again.';

  @override
  String get errorMissingKey =>
      'This device doesn\'t have the key to see this household\'s amounts. Ask your partner for the full invite code.';

  @override
  String errorRecoveryPhraseWordCount(int expected, int typed) {
    return 'The phrase must have $expected words (you entered $typed).';
  }

  @override
  String errorRecoveryPhraseUnknownWord(String word) {
    return '\"$word\" isn\'t a recovery phrase word. Check the spelling.';
  }

  @override
  String get errorRecoveryPhraseInvalid =>
      'That phrase isn\'t valid. Check the words are spelled right and in the right order.';

  @override
  String get validationPasswordPolicy =>
      'At least 8 characters, with an uppercase and a lowercase letter';

  @override
  String get reminderDailyChannel => 'Daily reminder';

  @override
  String get reminderDailyTitle => 'Log today\'s spending';

  @override
  String get reminderDailyBody => 'Don\'t forget to note what the household earned or spent today.';

  @override
  String get reminderWeeklyChannel => 'Weekly summary';

  @override
  String get reminderWeeklyTitle => 'Your weekly summary is ready';

  @override
  String get reminderWeeklyBody => 'See how the household did this week in Finan2.';

  @override
  String get reminderDebtChannel => 'Debt payments';

  @override
  String reminderDebtTodayTitle(String debt) {
    return '$debt is due today';
  }

  @override
  String reminderDebtTodayBody(String debt) {
    return 'Today is the payment day for $debt.';
  }

  @override
  String reminderDebtSoonTitle(String debt) {
    return '$debt payment coming up';
  }

  @override
  String reminderDebtSoonBody(String debt, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'The $debt payment is due in $_temp0.';
  }

  @override
  String get reminderActivityChannel => 'Household activity';

  @override
  String get debtsTitle => 'Debts';

  @override
  String get debtsAvalancheStrategy => 'Avalanche strategy';

  @override
  String get debtsEmptyTitle => 'Debt-free!';

  @override
  String get debtsEmptyDescription =>
      'You have no debts on record. If you take one on, add it to track its payoff with the Avalanche strategy.';

  @override
  String get debtsEmptyAction => '+ Add a debt';

  @override
  String get debtsFreeDateLabel => 'Debt-free by';

  @override
  String get debtsCurrentPaymentsLabel => 'At current payments';

  @override
  String get debtsCannotPayOff => 'Not enough to pay off';

  @override
  String debtsCardSubtitle(String rate, String minPayment) {
    return '$rate% rate · min. $minPayment/mo';
  }

  @override
  String debtsPaidAmount(String amount) {
    return 'Paid $amount';
  }

  @override
  String debtsBalanceAmount(String amount) {
    return 'Balance $amount';
  }

  @override
  String get debtsTypeCard => 'Card';

  @override
  String get debtsTypeLoan => 'Loan';

  @override
  String get debtsTypeMortgage => 'Mortgage';

  @override
  String get debtsTypeVehicle => 'Car loan';

  @override
  String get debtsStatusPaidOff => 'paid off';

  @override
  String debtsStatusFreeBy(String date) {
    return 'debt-free by $date';
  }

  @override
  String get debtsStatusCannotPayOff => 'current payments won\'t pay it off';

  @override
  String debtsRateWithStatus(String rate, String status) {
    return '$rate% APR · $status';
  }

  @override
  String get debtsCurrentBalance => 'Current balance';

  @override
  String get debtsMinPaymentShort => 'Min. payment';

  @override
  String get debtsExtraPayment => 'Extra payment';

  @override
  String get debtsPaid => 'Paid';

  @override
  String get debtsMonthlyInstallment => 'Monthly payment';

  @override
  String get debtsInstallmentsLeft => 'Payments left';

  @override
  String get debtsPaymentSchedule => 'Payment schedule';

  @override
  String get debtsAlreadyPaidOff => 'This debt is already paid off.';

  @override
  String get debtsNoProjection => 'No projection available.';

  @override
  String get debtsNextPayment => 'Next payment';

  @override
  String get debtsScheduledPayment => 'Scheduled';

  @override
  String debtsScheduleBalance(String amount) {
    return 'Balance → $amount';
  }

  @override
  String get debtsNeedAccountFirst => 'Create an account first to record the payment.';

  @override
  String get debtsRecordPayment => 'Record payment';

  @override
  String get debtsPaymentFrom => 'From';

  @override
  String get debtsRecordedPayments => 'Recorded payments';

  @override
  String get debtsNoCardPayments => 'No payments recorded for this card yet.';

  @override
  String get debtsDeletedAccount => 'Deleted account';

  @override
  String get debtsDeletePayment => 'Delete payment';

  @override
  String get debtsNewTitle => 'New debt';

  @override
  String get debtsEditTitle => 'Edit debt';

  @override
  String get debtsDelete => 'Delete debt';

  @override
  String debtsDeleteMessage(String name) {
    return '\"$name\" will be deleted. Payments and purchases already recorded stay in the history. This can\'t be undone.';
  }

  @override
  String get debtsTypeField => 'Debt type';

  @override
  String get debtsCreditLimit => 'Credit limit';

  @override
  String get debtsRatePercent => 'APR %';

  @override
  String get debtsMinPayment => 'Minimum payment';

  @override
  String get debtsCutoffDay => 'Statement day';

  @override
  String get debtsPaymentDay => 'Due day';

  @override
  String get debtsOriginalAmount => 'Original amount';

  @override
  String get debtsTermInstallments => 'Term (payments)';

  @override
  String get debtsPaidInstallments => 'Payments made';

  @override
  String get savingsGoalsTitle => 'Savings goals';

  @override
  String get savingsGoalsTotalSaved => 'Total saved';

  @override
  String savingsGoalsTotalSavedRemaining(String amount) {
    return 'Total saved · $amount to go';
  }

  @override
  String get savingsGoalsEmptyTitle => 'No goals yet';

  @override
  String get savingsGoalsEmptyDescription =>
      'Create a savings goal and keep tabs on it with your partner.';

  @override
  String get savingsGoalsEmptyAction => '+ New goal';

  @override
  String get savingsGoalsChallengeLink => 'Savings challenge';

  @override
  String get savingsGoalsNoDate => 'no date';

  @override
  String savingsGoalsCardSubtitle(String amount, String date) {
    return 'Goal $amount · $date';
  }

  @override
  String savingsGoalsPerMonth(String amount) {
    return '$amount/mo';
  }

  @override
  String savingsGoalsSavedAmount(String amount) {
    return 'Saved $amount';
  }

  @override
  String savingsGoalsSavedRemaining(String amount) {
    return 'Saved · $amount to go';
  }

  @override
  String get savingsGoalsSavedReached => 'Saved · goal reached';

  @override
  String get savingsGoalsContribution => 'Contribution';

  @override
  String get savingsGoalsInterestEarned => 'Interest earned';

  @override
  String get savingsGoalsRemaining => 'To go';

  @override
  String savingsGoalsProgressOf(int percent, String amount) {
    return '$percent% of $amount';
  }

  @override
  String savingsGoalsTargetBy(String date) {
    return 'goal $date';
  }

  @override
  String get savingsGoalsOnTrack => 'on track ✓';

  @override
  String get savingsGoalsBehind => 'behind';

  @override
  String get savingsGoalsContributions => 'Contributions';

  @override
  String get savingsGoalsNoContributions => 'No contributions yet.';

  @override
  String get savingsGoalsNewContribution => 'New contribution';

  @override
  String savingsGoalsRunningTotal(String amount) {
    return 'Total → $amount';
  }

  @override
  String get savingsGoalsIconTrip => 'Trip';

  @override
  String get savingsGoalsIconEmergency => 'Emergency';

  @override
  String get savingsGoalsIconHome => 'Home';

  @override
  String get savingsGoalsIconStudy => 'Education';

  @override
  String get savingsGoalsIconOther => 'Other';

  @override
  String get savingsGoalsNewTitle => 'New goal';

  @override
  String get savingsGoalsEditTitle => 'Edit goal';

  @override
  String get savingsGoalsDelete => 'Delete goal';

  @override
  String savingsGoalsDeleteMessage(String name) {
    return '\"$name\" and all its contributions will be deleted. This can\'t be undone.';
  }

  @override
  String get savingsGoalsIconField => 'Icon';

  @override
  String get savingsGoalsTarget => 'Target';

  @override
  String get savingsGoalsMonthlyContribution => 'Monthly contribution';

  @override
  String get savingsGoalsTargetDate => 'Target date';

  @override
  String get savingsGoalsNoDateValue => 'No date';

  @override
  String get savingsGoalsClearDate => 'Clear date';

  @override
  String get savingsGoalsAlreadySaved => 'Already saved';

  @override
  String get savingsGoalsInterestOptional => 'APY (optional)';

  @override
  String get investmentsTitle => 'Investments';

  @override
  String get investmentsEmptyTitle => 'No investments yet';

  @override
  String get investmentsEmptyDescription =>
      'Add your CDs, funds or crypto to keep tabs on your portfolio.';

  @override
  String get investmentsEmptyAction => '+ New investment';

  @override
  String get investmentsPortfolioValue => 'Portfolio value';

  @override
  String get investmentsTotalReturnSuffix => ' total return';

  @override
  String get investmentsKindFixedIncome => 'Fixed income';

  @override
  String get investmentsKindVariableIncome => 'Equities';

  @override
  String get investmentsKindHighRisk => 'High risk';

  @override
  String investmentsKindWithRate(String kind, String rate) {
    return '$kind · $rate% APY';
  }

  @override
  String get investmentsCurrentValue => 'Current value';

  @override
  String get investmentsNewTitle => 'New investment';

  @override
  String get investmentsEditTitle => 'Edit investment';

  @override
  String get investmentsDelete => 'Delete investment';

  @override
  String investmentsDeleteMessage(String name) {
    return '\"$name\" will be deleted. This can\'t be undone.';
  }

  @override
  String get investmentsKindField => 'Type';

  @override
  String get investmentsInvested => 'Invested';

  @override
  String get investmentsRate => 'APY';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsNewTitle => 'New transaction';

  @override
  String get transactionsEditTitle => 'Edit transaction';

  @override
  String get transactionsDelete => 'Delete transaction';

  @override
  String get transactionsDeleted => 'Transaction deleted';

  @override
  String get transactionsDeleteFailed => 'Couldn\'t delete it';

  @override
  String transactionsMaxTagsTitle(int max) {
    return '$max tags max';
  }

  @override
  String get transactionsMaxTagsMessage => 'Remove one before adding another.';

  @override
  String get transactionsCreditCard => 'Credit card';

  @override
  String get transactionsIncomplete => 'Fill in the amount, category and account.';

  @override
  String get transactionsNoCategoriesOfType =>
      'No categories of this type yet. Create them in Settings.';

  @override
  String get transactionsNoAccounts => 'No accounts yet. Create them in Settings.';

  @override
  String get transactionsSelectAccount => 'Select an account';

  @override
  String get transactionsTags => 'Tags';

  @override
  String get transactionsAddTagHint => 'Add a tag, e.g. trip-cartagena';

  @override
  String get transactionsAddTag => 'Add tag';

  @override
  String get transactionsReceivedBy => 'Received by';

  @override
  String get transactionsPaidBy => 'Paid by';

  @override
  String get transactionsLoggedBy => 'Logged by';

  @override
  String transactionsNet(String amount) {
    return '$amount net';
  }

  @override
  String transactionsNetInYear(String amount, int year) {
    return '$amount net in $year';
  }

  @override
  String transactionsFiltered(String text) {
    return '$text · filtered';
  }

  @override
  String get transactionsPreviousMonth => 'Previous month';

  @override
  String get transactionsNextMonth => 'Next month';

  @override
  String transactionsSearchWholeYear(int year) {
    return 'Search all of $year';
  }

  @override
  String get transactionsNoMatchTitle => 'No matches';

  @override
  String transactionsNoMatchYear(int year) {
    return 'No $year transactions match your search.';
  }

  @override
  String transactionsNoMatchMonth(String month) {
    return 'No $month transactions match your search or filters.';
  }

  @override
  String get transactionsClearSearch => 'Clear search';

  @override
  String get transactionsEmptyTitle => 'No transactions yet';

  @override
  String transactionsEmptyTitleMonth(String month) {
    return 'No transactions in $month';
  }

  @override
  String get transactionsEmptyDescription =>
      'Log your first income or expense this month to see the household summary here.';

  @override
  String get transactionsEmptyDescriptionMonth => 'No income or expenses were logged this month.';

  @override
  String get transactionsEmptyAction => '+ Add the first one';

  @override
  String get transactionsRecurringBills => 'Recurring bills';

  @override
  String get transactionsNotes => 'Notes';

  @override
  String get transactionsSearchHint => 'Search description, category or amount';

  @override
  String get transactionsFilters => 'Filters';

  @override
  String get transactionsFilterTitle => 'Filter transactions';

  @override
  String get transactionsFilterType => 'Type';

  @override
  String get transactionsFilterNoCategories => 'No categories of this type.';

  @override
  String get transactionsFilterTag => 'Tag';

  @override
  String get transactionsFilterClear => 'Clear';

  @override
  String get transactionsFilterApply => 'Apply';

  @override
  String get transfersTitle => 'Transfer';

  @override
  String get transfersInvalid => 'Enter an amount and two different accounts.';

  @override
  String get transfersAmountLabel => 'Amount to transfer';

  @override
  String get transfersFrom => 'From';

  @override
  String get transfersTo => 'To';

  @override
  String get transfersSelectAccount => 'Select an account';

  @override
  String get transfersHistoryTitle => 'Transfers';

  @override
  String get transfersDeleteTitle => 'Delete transfer';

  @override
  String get transfersDeleteMessage =>
      'The balance change will be reversed on both accounts. This can\'t be undone.';

  @override
  String get transfersDeletedAccount => 'Deleted account';

  @override
  String get transfersEmptyTitle => 'No transfers yet';

  @override
  String get transfersEmptyDescription =>
      'Money moved between your own accounts will show up here.';

  @override
  String get transfersEmptyAction => '+ Transfer';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsAvailableMoney => 'Available money';

  @override
  String get accountsTotalAvailable => 'Total available';

  @override
  String accountsCountInHousehold(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'across $count household accounts',
      one: 'across 1 household account',
    );
    return '$_temp0';
  }

  @override
  String get accountsEmptyTitle => 'No accounts yet';

  @override
  String get accountsEmptyDescription =>
      'Add your first account (cash, bank, wallet) to start logging transactions.';

  @override
  String get accountsEmptyAction => '+ New account';

  @override
  String get accountsTransferBetween => 'Transfer between accounts';

  @override
  String get accountsHistory => 'History';

  @override
  String get accountsNewTitle => 'New account';

  @override
  String get accountsEditTitle => 'Edit account';

  @override
  String get accountsTypeLabel => 'Account type';

  @override
  String get accountsCurrentBalance => 'Current balance';

  @override
  String get accountsIncludeInAvailable => 'Include in available money';

  @override
  String get accountsDeleteTitle => 'Delete account';

  @override
  String accountsDeleteMessage(String name) {
    return '\"$name\" will be deleted. This can\'t be undone.';
  }

  @override
  String get accountsCannotDeleteTitle => 'Can\'t delete it';

  @override
  String accountsCannotDeleteMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '\"$name\" has $_temp0 (transactions, transfers, card payments or recurring bills). Delete them or move them to another account first. To just leave it out of the total, turn off \"Include in available money\".';
  }

  @override
  String get accountsTypeCash => 'Cash';

  @override
  String get accountsTypeBank => 'Bank';

  @override
  String get accountsTypeWallet => 'Wallet';

  @override
  String get accountsTypeDebit => 'Debit';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String categoriesActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmptyTitle => 'No categories yet';

  @override
  String get categoriesEmptyDescription =>
      'Create your first category to start logging transactions.';

  @override
  String get categoriesEmptyAction => '+ New category';

  @override
  String get categoriesNewTitle => 'New category';

  @override
  String get categoriesEditTitle => 'Edit category';

  @override
  String get categoriesPreview => 'Preview';

  @override
  String get categoriesTypeLabel => 'Type';

  @override
  String get categoriesIcon => 'Icon';

  @override
  String get categoriesColor => 'Color';

  @override
  String get categoriesRolloverTitle => 'Roll over to next month';

  @override
  String get categoriesRolloverSubtitle =>
      'What\'s left of the budget carries into next month, and overspending is deducted. Resets every January.';

  @override
  String get categoriesDeleteTitle => 'Delete category';

  @override
  String categoriesDeleteMessage(String name) {
    return '\"$name\" will be deleted. This can\'t be undone.';
  }

  @override
  String get categoriesCannotDeleteYetTitle => 'Can\'t delete it yet';

  @override
  String categoriesCannotDeleteYetMessage(String name, String usage, String type) {
    return '\"$name\" has $usage. Create another $type category to move them to, then delete this one.';
  }

  @override
  String categoriesReassignTitle(String name) {
    return 'Where should $name\'s items go?';
  }

  @override
  String categoriesReassignMessage(String usage, String name) {
    return 'It has $usage. Pick the category that takes them; then \"$name\" is deleted.';
  }

  @override
  String categoriesUsageMovements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String categoriesUsageRecurringBills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring bills',
      one: '1 recurring bill',
    );
    return '$_temp0';
  }

  @override
  String categoriesUsageBoth(String movements, String bills) {
    return '$movements and $bills';
  }

  @override
  String get categoriesTypeIncome => 'Income';

  @override
  String get categoriesTypeBill => 'Bill';

  @override
  String get categoriesTypeExpense => 'Expense';

  @override
  String get categoriesTypeSavings => 'Savings';

  @override
  String get categoriesTypeIncomePlural => 'Income';

  @override
  String get categoriesTypeBillPlural => 'Bills';

  @override
  String get categoriesTypeExpensePlural => 'Expenses';

  @override
  String get categoriesTypeSavingsPlural => 'Savings';

  @override
  String get categoriesDefaultSalary => 'Salary';

  @override
  String get categoriesDefaultFreelance => 'Freelance';

  @override
  String get categoriesDefaultRent => 'Rent';

  @override
  String get categoriesDefaultUtilities => 'Utilities';

  @override
  String get categoriesDefaultPhoneInternet => 'Phone & internet';

  @override
  String get categoriesDefaultStreaming => 'Streaming';

  @override
  String get categoriesDefaultGroceries => 'Groceries';

  @override
  String get categoriesDefaultTransport => 'Transport';

  @override
  String get categoriesDefaultRestaurants => 'Restaurants';

  @override
  String get categoriesDefaultLeisure => 'Entertainment';

  @override
  String get categoriesDefaultHealth => 'Health';

  @override
  String get categoriesDefaultHomeCleaning => 'Home & cleaning';

  @override
  String get categoriesDefaultEmergencyFund => 'Emergency fund';

  @override
  String get categoriesDefaultTravel => 'Travel';
}
