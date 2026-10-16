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
  String get budgetPreviousMonth => 'Previous month';

  @override
  String get budgetNextMonth => 'Next month';

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
  String get annualSummaryEarned => 'In';

  @override
  String get annualSummarySpent => 'Out';

  @override
  String get annualSummarySaved => 'Saved';

  @override
  String get annualSummarySpendByMonth => 'Spending by month';

  @override
  String get dashboardNoCategorizedSpending => 'No categorized spending this month.';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String dashboardLeftOfPlan(String month) {
    return 'Left of the $month plan';
  }

  @override
  String dashboardOverPlan(String month) {
    return 'Over the $month plan by';
  }

  @override
  String dashboardSpentIn(String month) {
    return 'Spent in $month';
  }

  @override
  String dashboardOfPlan(String amount) {
    return 'of $amount';
  }

  @override
  String dashboardDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'last day',
    );
    return '$_temp0';
  }

  @override
  String dashboardPerDay(String amount) {
    return 'about $amount a day';
  }

  @override
  String get dashboardNoPlan => 'No plan this month';

  @override
  String dashboardIncomeIn(String amount) {
    return '$amount came in';
  }

  @override
  String get dashboardLegendLeft => 'Left';

  @override
  String get dashboardLegendOther => 'Others';

  @override
  String get dashboardNoticeSee => 'See';

  @override
  String get dashboardWhoPaid => 'Who paid this month';

  @override
  String dashboardMovementCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get dashboardRecent => 'Latest transactions';

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
  String get coreHomeTabPlan => 'Plan';

  @override
  String get coreHomeAdd => 'Add';

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
  String get debtsEmptyTitle => 'Debt-free!';

  @override
  String get debtsEmptyDescription =>
      'You have no debts on record. If you take one on, add it to track its payoff with the Avalanche strategy.';

  @override
  String get debtsEmptyAction => '+ Add a debt';

  @override
  String get debtsFreeDateLabel => 'Debt-free in';

  @override
  String get debtsCurrentPaymentsLabel => 'At current payments';

  @override
  String get debtsCannotPayOff => 'Not enough to pay off';

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
  String get debtsCurrentBalance => 'Outstanding balance';

  @override
  String get debtsExtraPayment => 'Extra payment';

  @override
  String get debtsMonthlyInstallment => 'Monthly payment';

  @override
  String get debtsPaymentSchedule => 'Payment schedule';

  @override
  String get debtsAlreadyPaidOff => 'This debt is already paid off.';

  @override
  String get debtsNoProjection => 'No projection available.';

  @override
  String get debtsScheduledPayment => 'Planned';

  @override
  String get debtsNeedAccountFirst => 'Create an account first to record the payment.';

  @override
  String get debtsRecordPayment => 'Record payment';

  @override
  String get debtsPaymentFrom => 'From';

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
  String get savingsGoalsTotalSaved => 'Total saved';

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
  String savingsGoalsPerMonth(String amount) {
    return '$amount/mo';
  }

  @override
  String get savingsGoalsBehind => 'behind';

  @override
  String get savingsGoalsContributions => 'Contributions';

  @override
  String get savingsGoalsNoContributions => 'No contributions yet.';

  @override
  String get savingsGoalsNewContribution => 'New contribution';

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
  String get savingsGoalsTarget => 'How much you need';

  @override
  String get savingsGoalsMonthlyContribution => 'Monthly contribution';

  @override
  String get savingsGoalsTargetDate => 'By when';

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
  String get transactionsNewTitle => 'Add';

  @override
  String get transactionsEditTitle => 'Edit transaction';

  @override
  String get transactionsDetailOver => 'Transaction';

  @override
  String get transactionsEdit => 'Edit';

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
  String get transactionsTypeTransfer => 'Move';

  @override
  String get transactionsTransferNeedsTwoAccounts =>
      'Moving money needs two accounts. Create them in Settings.';

  @override
  String get transactionsIncomplete => 'Fill in the amount, category and account.';

  @override
  String get transactionsIncompleteTitle => 'Something is missing';

  @override
  String transactionsDateToday(String date) {
    return 'Today, $date';
  }

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
  String get transactionsPreviousMonth => 'Previous month';

  @override
  String get transactionsNextMonth => 'Next month';

  @override
  String transactionsDayToday(String day) {
    return 'Today · $day';
  }

  @override
  String transactionsDayYesterday(String day) {
    return 'Yesterday · $day';
  }

  @override
  String transactionsResultsTotal(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0 · $amount';
  }

  @override
  String transactionsSearchWholeYear(int year) {
    return 'All of $year';
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
  String get transactionsSearchHint => 'Search description, category, amount or #tag';

  @override
  String get transactionsFilters => 'Filters';

  @override
  String get transactionsFilterTitle => 'Filter';

  @override
  String get transactionsFilterType => 'Type';

  @override
  String get transactionsFilterNoCategories => 'No categories of this type.';

  @override
  String get transactionsFilterTag => 'Tag';

  @override
  String transactionsPaidByChip(String name) {
    return 'Paid by $name';
  }

  @override
  String get transactionsFilterBoth => 'Both';

  @override
  String get transactionsFilterClear => 'Clear';

  @override
  String transactionsFilterSee(int count) {
    return 'See $count';
  }

  @override
  String get transfersInvalid => 'Enter an amount and two different accounts.';

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

  @override
  String get planBudget => 'Budget';

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String get budgetComplete => 'Complete';

  @override
  String get budgetUnplanned => 'no plan';

  @override
  String budgetSpentOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String budgetSpentNoPlan(String spent) {
    return '$spent spent';
  }

  @override
  String budgetOverTitle(String category, String amount) {
    return '$category went $amount over';
  }

  @override
  String budgetOverManyTitle(int count) {
    return '$count categories went over';
  }

  @override
  String get budgetOverMessage => 'It comes out of what\'s left of the plan.';

  @override
  String budgetOverManyMessage(String category, String amount) {
    return '$category the most: $amount.';
  }

  @override
  String budgetPlannedRemaining(String planned, String amount) {
    return '$planned planned · $amount left to assign';
  }

  @override
  String budgetPlannedOver(String planned, String amount) {
    return '$planned planned · $amount more than came in';
  }

  @override
  String budgetPlannedNoIncome(String planned) {
    return '$planned planned · nothing has come in this month yet';
  }

  @override
  String get goalsSavedTogether => 'Saved between you two';

  @override
  String goalsOnTime(int onTime, int dated) {
    return 'on time in $onTime of $dated goals';
  }

  @override
  String goalsToGo(String amount) {
    return '$amount to go to complete them';
  }

  @override
  String goalRowLine(String saved, String target, String when) {
    return '$saved of $target · $when';
  }

  @override
  String goalFor(String date) {
    return 'by $date';
  }

  @override
  String goalsDebtsFree(String date) {
    return 'Debts: free by $date';
  }

  @override
  String get goalsDebtsStuck => 'Debts: current payments don\'t pay them off';

  @override
  String goalsDebtsOrder(String first, String second) {
    return 'First $first, then $second.';
  }

  @override
  String goalsDebtsOnly(String name) {
    return 'Only $name is left.';
  }

  @override
  String goalOnTimePace(String amount) {
    return 'On time: $amount a month';
  }

  @override
  String goalBehindPace(String amount) {
    return 'Behind: it takes $amount a month';
  }

  @override
  String get goalReached => 'Goal reached!';

  @override
  String goalOfFor(String target, String when) {
    return 'of $target · $when';
  }

  @override
  String goalInterest(String amount) {
    return 'Includes $amount in interest';
  }

  @override
  String goalContributionOf(String month) {
    return '$month contribution';
  }

  @override
  String get goalCreate => 'Create';

  @override
  String goalNeededTitle(String amount) {
    return '$amount a month';
  }

  @override
  String goalNeededMessage(String date) {
    return 'That\'s what it takes to get there by $date.';
  }

  @override
  String get commonEdit => 'Edit';

  @override
  String debtsLeftAvalanche(String amount) {
    return '$amount to go · Avalanche order (highest rate first)';
  }

  @override
  String debtsRowCard(String rate, String amount, int day) {
    return '$rate% · min. $amount · day $day';
  }

  @override
  String debtsRowLoan(String rate, String amount, int day) {
    return '$rate% · $amount installment · day $day';
  }

  @override
  String get debtsFirst => '1st';

  @override
  String debtsNextTitle(String name, String date) {
    return 'Next payment: $name, $date';
  }

  @override
  String debtsNextMinSuggested(String min, String suggested) {
    return '$min minimum · suggested $suggested';
  }

  @override
  String debtsNextMin(String min) {
    return '$min minimum';
  }

  @override
  String debtsDetailSub(String reference, int pct, String status) {
    return 'of $reference · $pct% paid · $status';
  }

  @override
  String debtsRateOnly(String rate) {
    return '$rate% APR';
  }

  @override
  String debtsRateExtra(String rate, String amount) {
    return '$rate% APR · extra payment $amount';
  }

  @override
  String get debtsPaidBy => 'Paid by';

  @override
  String debtsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'in $days days',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String debtsDeletePaymentMessage(String amount, String date) {
    return 'The $amount payment of $date will be removed.';
  }

  @override
  String get challengeSavedIn => 'Saved in the challenge';

  @override
  String challengeCells(int done, int total, String target) {
    return '$done of $total cells · goal $target';
  }

  @override
  String challengeNextTitle(String amount) {
    return 'Next: $amount';
  }

  @override
  String get challengeNextMessage => 'Mark it once you\'ve put it aside.';

  @override
  String get challengeMark => 'Mark';

  @override
  String get challengeDoneTitle => 'Challenge complete';

  @override
  String challengeDoneMessage(String amount) {
    return 'You saved $amount.';
  }

  @override
  String annualTitleYear(int year) {
    return '$year summary';
  }

  @override
  String annualAverage(String amount) {
    return 'avg. $amount';
  }

  @override
  String annualHighestTitle(String month) {
    return '$month was the highest month';
  }

  @override
  String annualHighestReason(String category, String amount) {
    return '$category: $amount more than in a usual month.';
  }
}
