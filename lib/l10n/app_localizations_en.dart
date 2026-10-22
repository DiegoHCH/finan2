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
  String budgetEmptyTitle(String month) {
    return '$month has no plan yet.';
  }

  @override
  String get budgetEmptyDescription =>
      'Set how much you want to spend on each category and you\'ll see here what\'s left of each one.';

  @override
  String get budgetEmptyAction => 'Plan a category';

  @override
  String budgetEmptyCopy(String month) {
    return 'Copy $month\'s plan';
  }

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
  String get dashboardDecrypting => 'Decrypting the amounts on this phone…';

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
  String get authLoginSubtitle =>
      'Each person signs in with their own account. If you share the household, you both see what you write down.';

  @override
  String get authLoginHeadline => 'The household notebook,\nfor you or for the two of you.';

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
  String get authSignupTitle => 'Your account';

  @override
  String get authSignupSubtitle =>
      'It\'s yours alone. You\'ll set up or join the household in the next step.';

  @override
  String get authNameRequired => 'Enter your name';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authHaveAccountLink => 'I already have an account';

  @override
  String get householdDefaultName => 'Our home';

  @override
  String get householdCreateJoinTitle => 'Setting up the household, or joining one?';

  @override
  String get householdCreateJoinSubtitle =>
      'Create it yourself. If someone else will log with you, they join with a code.';

  @override
  String get householdCreateOptionTitle => 'Create the household';

  @override
  String get householdCreateOptionSubtitle => 'I\'ll start. I can invite someone later if I want.';

  @override
  String get householdJoinOptionTitle => 'I have a code';

  @override
  String get householdJoinOptionSubtitle => 'Someone already created it and sent me the code.';

  @override
  String get householdNameLabel => 'Household name';

  @override
  String get householdNameRequired => 'Give your household a name';

  @override
  String get householdCodeLabel => 'Code';

  @override
  String get householdCodeHint => 'Paste it whole, just as it came: it carries the household key.';

  @override
  String get householdCodeRequired => 'Enter the code you were sent';

  @override
  String get householdCreateButton => 'Set up the household';

  @override
  String get householdJoinButton => 'Join the household';

  @override
  String get householdJoinedWithoutKeyTitle => 'You joined the household';

  @override
  String get householdJoinedWithoutKeyMessage =>
      'This code didn\'t include the key to see amounts. Ask whoever invited you to share it from Settings, under \"Share the key\".';

  @override
  String householdSetupStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get householdSetupCurrencyTitle => 'Which currency do you keep accounts in?';

  @override
  String get householdSetupCurrencyDescription =>
      'The one for every amount in the household. You can change it later in Settings.';

  @override
  String get householdCurrencyCop => 'Colombian peso';

  @override
  String get householdCurrencyUsd => 'US dollar';

  @override
  String get householdSetupAccountTitle => 'Where\'s the money today?';

  @override
  String get householdSetupAccountDescription =>
      'One account to start: the bank, a wallet or cash. With the real balance, what you write down adds up from day one.';

  @override
  String get householdSetupAccountNameMissingTitle => 'Give it a name';

  @override
  String get householdSetupAccountNameMissingMessage =>
      'Such as the bank or “Cash”. Or leave it for later with “Not now”.';

  @override
  String get householdSetupBalanceToday => 'Today\'s balance';

  @override
  String get householdSetupCreateAccount => 'Create account';

  @override
  String get householdRecoveryPhraseTitle => 'Recovery phrase';

  @override
  String get householdSetupRecoveryDescription =>
      'Amounts are encrypted with a key that lives only on your phones. If it\'s lost, 12 words bring it back. They\'re shown only once: write them down on paper and keep them somewhere safe. You can also do it later, from Settings.';

  @override
  String get householdSetupRecoveryTitle => 'What if you lose the key?';

  @override
  String get householdGeneratePhrase => 'Generate phrase';

  @override
  String get householdSetupLater => 'Not now';

  @override
  String get householdInviteTitle => 'Will someone else log with you?';

  @override
  String get householdInviteMessage =>
      'If you share the household, send them this code with the share button. It carries the household key, which you can\'t see here: share it only with that person and don\'t post it anywhere. If it\'s just you, carry on without inviting.';

  @override
  String get householdInviteFootnote =>
      'Works once and expires in 7 days · you can make another in Settings';

  @override
  String get householdInviteMissingPartner => 'Invite someone';

  @override
  String get householdInviteShareSubject => 'Invitation to our household on Finan2';

  @override
  String get householdInviteShare => 'Share';

  @override
  String get householdInviteSkip => 'Just me for now';

  @override
  String get householdRecoveryConfirmMessage =>
      'If the household key is ever on no phone at all, these 12 words recover the amounts. You\'ll see them only once: write them down on paper and keep them somewhere safe. Any previous phrase or PIN will stop working.';

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
      'That code doesn\'t include the full key. Ask the other person in the household to share it again from Settings, under \"Share the key\".';

  @override
  String get householdKeyWrongHousehold =>
      'That key isn\'t for this household. Check that it\'s the code shared from this same household.';

  @override
  String get householdRecoveryNotSet => 'This household has no recovery phrase set up.';

  @override
  String get householdRecoveryPhraseMismatch =>
      'That phrase doesn\'t match this household. If a new one was generated, the old one stopped working.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountsAndCards => 'Accounts and cards';

  @override
  String get settingsMemberYou => 'you';

  @override
  String get settingsMemberPartner => 'in the household';

  @override
  String get settingsInvite => 'Invite to the household';

  @override
  String get settingsInviteSomeone => 'Invite';

  @override
  String get settingsShareKey => 'Share the key';

  @override
  String get settingsMissingKeyBanner =>
      'This device doesn\'t have the key to see this household\'s amounts. Paste the code shared from Settings, under \"Share the key\", or type the recovery phrase.';

  @override
  String get settingsPasteCodeToUnlock => 'Paste code to unlock amounts';

  @override
  String get settingsUseRecoveryPhrase => 'Use recovery phrase';

  @override
  String get settingsStorageWarning =>
      'Your browser didn\'t guarantee that Finan2\'s data will be kept. If you don\'t open the app for several days, you could lose access to this device\'s encrypted amounts. Make sure you have a recovery phrase in Settings, under \"Your account\".';

  @override
  String get settingsFinancialSettings => 'Currency and year';

  @override
  String get settingsAccountSettings => 'Your account';

  @override
  String get settingsExportReport => 'Export';

  @override
  String get settingsBackup => 'Backup and key';

  @override
  String get settingsInvestments => 'Investments';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsUnlockAmountsTitle => 'Unlock amounts';

  @override
  String get settingsUnlockAmountsMessage =>
      'Paste the full code (with the key after the dot) shared from Settings, under \"Share the key\".';

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
  String get settingsHouseholdMembers => 'Household members';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Same as the phone';

  @override
  String get settingsLanguageSystemSubtitle => 'Follows your phone’s language.';

  @override
  String get settingsLanguageFixedSubtitle => 'Always in this language, whatever the phone uses.';

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
  String get coreSheetErrorTitle => 'Something went wrong';

  @override
  String get coreReauthTitle => 'Confirm your password';

  @override
  String get corePassword => 'Password';

  @override
  String get corePeriodBackToToday => 'Back to today';

  @override
  String get coreMissingKeyTitle => 'This phone doesn\'t have the household\'s key.';

  @override
  String get coreMissingKeyBody =>
      'Amounts are encrypted with a key that only lives on your phones. Without it, this one can\'t open your movements or log new ones.';

  @override
  String get coreMissingKeyUsePhrase => 'Use the 12-word phrase';

  @override
  String coreMissingKeyAskPartner(String name) {
    return 'Ask $name for the code';
  }

  @override
  String get coreMissingKeyPasteCode => 'Paste the key code';

  @override
  String get coreOffline =>
      'You\'re offline. What you log is kept here and sent on its own once you\'re back online.';

  @override
  String get coreUnsynced => 'not sent yet';

  @override
  String get coreLoading => 'Loading';

  @override
  String get coreNotificationPrimerTitle => 'Turn on notifications';

  @override
  String get coreNotificationPrimerBody =>
      'We\'ll let you know when a payment is coming up or you go over budget and, if you share the household, when the other person logs something. You can change this later in Settings.';

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
  String get coreSplashTagline => 'Household finances - for you or for the two of you';

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
      'That invite doesn\'t exist or has expired. Ask whoever invited you for a new one from Settings.';

  @override
  String get errorHouseholdFull =>
      'We couldn\'t add you: the household already has 2 members or the invite is no longer valid.';

  @override
  String get errorGeneric => 'Something went wrong, please try again.';

  @override
  String get errorMissingKey =>
      'This device doesn\'t have the key to see this household\'s amounts. Ask the other person in the household for the full invite code.';

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
  String get debtsEmptyTitle => 'You owe nothing.';

  @override
  String get debtsEmptyDescription =>
      'If a card or a loan comes along, add it here and the app will tell you when you\'ll be done with it.';

  @override
  String get debtsEmptyAction => 'Add a debt';

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
  String get debtsCreditLimit => 'Limit';

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
  String get savingsGoalsEmptyTitle => 'No goals yet.';

  @override
  String get savingsGoalsEmptyDescription =>
      'A trip, a cushion, a car: give it an amount and a date, and you\'ll see here how much is left and how much to set aside each month.';

  @override
  String get savingsGoalsEmptyAction => 'Create a goal';

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
  String get investmentsEmptyTitle => 'No investments yet.';

  @override
  String get investmentsEmptyDescription =>
      'Add your CDs, funds or crypto to keep tabs on your portfolio.';

  @override
  String get investmentsEmptyAction => 'Add an investment';

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
  String transactionsEmptyTitle(String month) {
    return '$month is a blank page.';
  }

  @override
  String get transactionsEmptyDescription =>
      'The first thing you log shows up here, with who paid it. The month\'s recurring items log themselves on their day.';

  @override
  String get transactionsEmptyDescriptionMonth =>
      'Nothing was logged that month. If something was left out, you can still log it with its date.';

  @override
  String get transactionsEmptyAction => 'Log the first one';

  @override
  String transactionsSeeMonth(String month) {
    return 'See $month';
  }

  @override
  String get transactionsRecurringBills => 'Recurring';

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
  String get transfersHistoryTitle => 'Moves between accounts';

  @override
  String get transfersDeleteTitle => 'Delete transfer';

  @override
  String get transfersDeleteMessage =>
      'The balance change will be reversed on both accounts. This can\'t be undone.';

  @override
  String get transfersDeletedAccount => 'Deleted account';

  @override
  String get transfersEmptyTitle => 'No money moved yet.';

  @override
  String get transfersEmptyDescription =>
      'When you move money from one account to another it\'s recorded here, without counting as spending.';

  @override
  String get transfersEmptyAction => 'Move money';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsEmptyTitle => 'No accounts yet.';

  @override
  String get accountsEmptyDescription =>
      'Add the cash, bank or wallet the money comes from, and you\'ll see here how much you have available.';

  @override
  String get accountsEmptyAction => 'Add an account';

  @override
  String get accountsTransferBetween => 'Move between accounts';

  @override
  String get accountsNewTitle => 'New account';

  @override
  String get accountsEditTitle => 'Edit account';

  @override
  String get accountsTypeLabel => 'Type';

  @override
  String get accountsCurrentBalance => 'Today\'s balance';

  @override
  String get accountsIncludeInAvailable => 'Counts in «Available»';

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
    return '\"$name\" has $_temp0 (transactions, transfers, card payments or recurring bills). Delete them or move them to another account first. To just leave it out of the total, turn off «Counts in Available».';
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
  String categoriesRowUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions this year',
      one: '1 transaction this year',
      zero: 'No transactions this year',
    );
    return '$_temp0';
  }

  @override
  String get categoriesRowRollover => 'Carries over';

  @override
  String get categoriesNoneOfType => 'No categories of this kind yet. Add one with +.';

  @override
  String get categoriesEmptyTitle => 'No categories yet.';

  @override
  String get categoriesEmptyDescription =>
      'Every movement goes in a category: create the first one to start logging.';

  @override
  String get categoriesEmptyAction => 'Create a category';

  @override
  String get categoriesNewTitle => 'New category';

  @override
  String get categoriesNewChip => 'New';

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
      'What\'s left or overspent counts toward next month; it resets in January.';

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
      other: '$count recurring items',
      one: '1 recurring item',
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
  String get recurringBillsTitle => 'Recurring';

  @override
  String get recurringBillsCommittedLabel => 'Committed each month';

  @override
  String recurringBillsCommittedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring items',
      one: '1 recurring item',
      zero: 'Nothing active',
    );
    return '$_temp0';
  }

  @override
  String get recurringBillsAveragedNote => 'non-monthly ones averaged';

  @override
  String get recurringBillsAutoNote =>
      'They\'re logged in Transactions on their own, on the day they\'re due.';

  @override
  String get recurringBillsEmptyTitle => 'Nothing recurring yet.';

  @override
  String get recurringBillsEmptyDescription =>
      'Schedule rent, utilities or your salary so they\'re logged on their own on the day they\'re due.';

  @override
  String get recurringBillsEmptyAction => 'Add a recurring item';

  @override
  String get recurringBillsStatusPaused => 'Paused';

  @override
  String get recurringBillsStatusEnded => 'Ended';

  @override
  String get recurringBillsTypeIncome => 'Income';

  @override
  String get recurringBillsTypeBill => 'Bill';

  @override
  String get recurringBillsNewTitle => 'New recurring item';

  @override
  String get recurringBillsEditTitle => 'Edit recurring item';

  @override
  String get recurringBillsMissingFields => 'Fill in the name, amount, category and account.';

  @override
  String get recurringBillsSemimonthlyDayTitle => 'Pick a day up to the 15th';

  @override
  String get recurringBillsSemimonthlyDayMessage =>
      'A twice-a-month bill repeats 15 days after the first date. Pick a first payment between the 1st and the 15th - for example the 15th to get paid on the 15th and the 30th.';

  @override
  String get recurringBillsDelete => 'Delete recurring item';

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
  String get recurringBillsRepeats => 'How often';

  @override
  String get recurringBillsFrom => 'From';

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
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': 'Every Monday',
      'tuesday': 'Every Tuesday',
      'wednesday': 'Every Wednesday',
      'thursday': 'Every Thursday',
      'friday': 'Every Friday',
      'saturday': 'Every Saturday',
      'other': 'Every Sunday',
    });
    return '$_temp0';
  }

  @override
  String recurringBillsScheduleBiweekly(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': 'Every other Monday',
      'tuesday': 'Every other Tuesday',
      'wednesday': 'Every other Wednesday',
      'thursday': 'Every other Thursday',
      'friday': 'Every other Friday',
      'saturday': 'Every other Saturday',
      'other': 'Every other Sunday',
    });
    return '$_temp0';
  }

  @override
  String recurringBillsScheduleSemimonthly(int day, int secondDay) {
    return 'Days $day and $secondDay';
  }

  @override
  String recurringBillsScheduleMonthly(int day) {
    return 'Monthly, on day $day';
  }

  @override
  String recurringBillsScheduleYearly(String date) {
    return 'Every year, $date';
  }

  @override
  String recurringBillsScheduleUntil(String schedule, String date) {
    return '$schedule, until $date';
  }

  @override
  String recurringBillsMonthlyCost(String kind, String amount) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'average': 'About $amount a month',
      'other': '$amount a month',
    });
    return '$_temp0';
  }

  @override
  String get monthlyNotesTitle => 'Notes for the month';

  @override
  String get monthlyNotesThisMonth => 'This month\'s notes';

  @override
  String get monthlyNotesNextMonth => 'For next month';

  @override
  String get monthlyNotesEmpty => 'Nothing written yet. Tap to write.';

  @override
  String get monthlyNotesWrite => 'Write';

  @override
  String get monthlyNotesHint => 'What doesn\'t fit in numbers.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsUnread => 'Unread';

  @override
  String get notificationsEmpty =>
      'Upcoming payments, goals on track, anything over budget and, if you share the household, what the other person logs show up here.';

  @override
  String get notificationsEmptyTitle => 'All quiet.';

  @override
  String get notificationsEmptyAction => 'Choose what to be told';

  @override
  String notificationsMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String notificationsHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get notificationsYesterday => 'yesterday';

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
    return 'Someone in the household added a contribution to $goal.';
  }

  @override
  String get notificationsPartnerMovementTitle => 'New transaction';

  @override
  String get notificationsPartnerMovementBody => 'Someone in the household logged a transaction.';

  @override
  String get notificationsPartnerTransferTitle => 'New transfer';

  @override
  String get notificationsPartnerTransferBody =>
      'Someone in the household logged a transfer between accounts.';

  @override
  String get notificationsPartnerDebtTitle => 'New debt';

  @override
  String get notificationsPartnerAccountTitle => 'New account';

  @override
  String get notificationsPartnerInvestmentTitle => 'New investment';

  @override
  String get notificationsPartnerBillTitle => 'New recurring item';

  @override
  String get notificationsPartnerCategoryTitle => 'New category';

  @override
  String get notificationsPartnerChallengeTitle => 'New savings challenge';

  @override
  String get notificationsPartnerGoalTitle => 'New savings goal';

  @override
  String get notificationPrefsTitle => 'What to notify';

  @override
  String notificationPrefsIntro(String name) {
    return 'Just for you: $name picks their own.';
  }

  @override
  String get notificationPrefsIntroSolo => 'Just for you: everyone picks their own.';

  @override
  String get notificationPrefsDailyReminder => 'Reminder to log';

  @override
  String get notificationPrefsDailyReminderWhen => 'Every day, at this time';

  @override
  String get notificationPrefsDailyReminderTimeTooltip => 'Change the time';

  @override
  String get notificationPrefsDebtPayments => 'Payments coming up';

  @override
  String get notificationPrefsDebtPaymentsWhen => '3, 2 and 1 day before, and on the day';

  @override
  String get notificationPrefsGoalProgress => 'Goal progress';

  @override
  String get notificationPrefsGoalProgressWhen => 'Once, when a goal passes 90%';

  @override
  String get notificationPrefsBudgetExceeded => 'A category going over';

  @override
  String get notificationPrefsBudgetExceededWhen => 'Once per category and month';

  @override
  String get notificationPrefsPartnerActivity => 'What the other person adds';

  @override
  String notificationPrefsPartnerActivityNamed(String name) {
    return 'What $name adds';
  }

  @override
  String get notificationPrefsPartnerActivityWhen => 'Each new transaction, account or goal';

  @override
  String get notificationPrefsWeeklySummary => 'Weekly summary';

  @override
  String notificationPrefsWeeklySummaryWhen(String time) {
    return 'Sundays, $time';
  }

  @override
  String get exportTitle => 'Export';

  @override
  String get exportPeriod => 'Period';

  @override
  String exportPeriodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get exportPeriodThisMonth => 'This month';

  @override
  String get exportPeriodQuarter => '3 months';

  @override
  String get exportPeriodYear => '12 months';

  @override
  String get exportInclude => 'What to include';

  @override
  String get exportTransactions => 'Transactions';

  @override
  String get exportBudget => 'Budget';

  @override
  String get exportDebtsAndSavings => 'Debts and goals';

  @override
  String get exportPdfTitle => 'PDF';

  @override
  String get exportPdfFor => 'To read or print, with the amounts formatted.';

  @override
  String get exportCsvTitle => 'CSV for a spreadsheet';

  @override
  String get exportCsvFor => 'One file per section, with plain numbers and YYYY-MM-DD dates.';

  @override
  String get exportOnDevice =>
      'The file is put together on this phone from the data it already decrypted: nothing leaves until you share it.';

  @override
  String get exportAction => 'Export';

  @override
  String get exportDebts => 'Debts';

  @override
  String get exportSavingsGoals => 'Savings goals';

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
  String get backupDescription =>
      'The whole household in a file encrypted with the household key. Without the key no one can read it: you can keep it in your email or in the cloud.';

  @override
  String get backupCreate => 'Back up now';

  @override
  String get backupRestoreAction => 'Restore a backup';

  @override
  String get backupRestoreLead => 'When restoring';

  @override
  String get backupRestoreNote =>
      ', the household goes back to how it was that day, for everyone in it: anything created since is deleted. It only works in this same household.';

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
    return 'The household will go back to how it was on $date. Anything created since is deleted and anything changed goes back to how it was, for the other person in the household too.';
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
          '$count deleted records of the other person\'s are now in your name: you can only create records as yourself. Transactions keep who paid.',
      one:
          '1 deleted record of the other person\'s is now in your name: you can only create records as yourself. Transactions keep who paid.',
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
  String get goalsSavedTogether => 'Saved in the household';

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

  @override
  String get accountsAvailableLabel => 'Available across accounts';

  @override
  String get accountsAvailableNote => 'cards and loans don\'t count here';

  @override
  String get accountsCards => 'Cards';

  @override
  String accountsRowExcluded(String type) {
    return '$type · not in «Available»';
  }

  @override
  String get accountsIncludeHint =>
      'Turn it off for accounts you don\'t touch, like separate savings.';

  @override
  String get accountsAdd => 'New account';

  @override
  String get commonCreate => 'Create';

  @override
  String debtsFormTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'tarjeta': 'Credit card',
      'credito': 'Loan',
      'hipoteca': 'Mortgage',
      'vehiculo': 'Car loan',
      'other': 'Debt',
    });
    return '$_temp0';
  }

  @override
  String debtsCardDays(int cutoff, int day) {
    return 'Closes on day $cutoff · due on day $day';
  }

  @override
  String debtsCardPayDay(int day) {
    return 'Due on day $day';
  }

  @override
  String get debtsCardPlaceholder => 'Your card';

  @override
  String get debtsOwedToday => 'Owed today';

  @override
  String debtsEndsIn(String date) {
    return 'Paid off in $date';
  }

  @override
  String debtsEndsSooner(String amount, String date) {
    return 'Paying $amount more a month: $date.';
  }

  @override
  String get debtsNeverEnds => 'That payment never pays it off';

  @override
  String get debtsNeverEndsHint => 'The interest eats the payment: raise it or pay extra.';

  @override
  String get investmentsWorthToday => 'Worth today';

  @override
  String investmentsPutIn(String amount) {
    return 'put in $amount';
  }

  @override
  String get investmentsGaining => 'gaining';

  @override
  String get investmentsLosing => 'losing';

  @override
  String get investmentsManualNote => 'Updated by hand: the app doesn\'t connect to any bank.';

  @override
  String get investmentsAdd => 'New investment';

  @override
  String transfersRowTo(String name) {
    return 'To $name';
  }

  @override
  String transfersRowFrom(String name, String date) {
    return 'from $name · $date';
  }

  @override
  String transfersHas(String amount) {
    return 'has $amount';
  }

  @override
  String transfersLeaves(String amount) {
    return 'ends with $amount';
  }

  @override
  String get transfersNotExpense => 'Not an expense: it doesn\'t touch the budget.';

  @override
  String get transfersSwap => 'Swap direction';

  @override
  String get demoSeed => 'Fill with test data';

  @override
  String get demoRemove => 'Remove test data';

  @override
  String get demoSeedTitle => 'Fill with test data?';

  @override
  String get demoSeedMessage =>
      'Adds three months of made-up accounts, a card, a loan, goals, investments, recurring bills and movements. What you already have isn\'t touched, and nobody gets notified.';

  @override
  String get demoSeedConfirm => 'Fill';

  @override
  String get demoSeedDoneTitle => 'Done';

  @override
  String demoSeedDone(int count) {
    return '$count test records written.';
  }

  @override
  String get demoRemoveTitle => 'Remove the test data?';

  @override
  String get demoRemoveMessage => 'Only the made-up data is deleted. What you logged stays.';

  @override
  String get demoRemoveConfirm => 'Remove';

  @override
  String get demoRemoveDoneTitle => 'Removed';

  @override
  String demoRemoveDone(int count) {
    return '$count test records deleted.';
  }

  @override
  String get demoError =>
      'Couldn\'t finish. Check the connection and try again: it can be repeated without duplicating anything.';

  @override
  String householdInviteValidUntil(String date) {
    return 'Works once and expires on $date.';
  }

  @override
  String get householdInviteNewCode => 'Make a new code';

  @override
  String get householdInviteNewCodeTitle => 'Make a new code?';

  @override
  String get householdInviteNewCodeMessage =>
      'The code you already sent will stop working. Do it if it reached the wrong person or got lost.';

  @override
  String householdJoinConfirmTitle(String household) {
    return 'Join $household?';
  }

  @override
  String get householdJoinConfirmTitleUnnamed => 'Join this household?';

  @override
  String householdJoinConfirmMessage(String name) {
    return '$name invited you. From now on you’ll both see and log this household’s money.';
  }

  @override
  String get householdJoinConfirmMessageUnnamed =>
      'From now on you’ll both see and log this household’s money.';

  @override
  String get appLockTitle => 'App lock';

  @override
  String get appLockIntro =>
      'Finan2 asks for your PIN when it opens and when you come back after 30 seconds away, so you don\'t have to sign in every time. It\'s for this phone only.';

  @override
  String get appLockBiometrics => 'Use fingerprint or face';

  @override
  String get appLockBiometricsWhen => 'Opens without typing the PIN. The PIN still works.';

  @override
  String get appLockChangePin => 'Change PIN';

  @override
  String get appLockEnterPin => 'Enter your PIN';

  @override
  String get appLockEnterPinMessage => 'Finan2 is locked on this phone.';

  @override
  String appLockWrongPin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wrong PIN. $count tries left.',
      one: 'Wrong PIN. 1 try left.',
      zero: 'Wrong PIN.',
    );
    return '$_temp0';
  }

  @override
  String appLockWait(int seconds) {
    return 'Too many tries. Try again in $seconds s.';
  }

  @override
  String get appLockForgot => 'Forgot your PIN?';

  @override
  String get appLockForgotTitle => 'Remove the PIN by signing out';

  @override
  String get appLockForgotMessage =>
      'Signing out removes the PIN from this phone. Sign back in with your email or Google and your data is still there.';

  @override
  String get appLockUseBiometrics => 'Use fingerprint or face';

  @override
  String get appLockBiometricReason => 'Unlock Finan2';

  @override
  String get appLockErase => 'Delete';

  @override
  String appLockStep(int step) {
    return 'Step $step of 2';
  }

  @override
  String get appLockCreateTitle => 'Choose a PIN';

  @override
  String get appLockCreateMessage =>
      '4 digits you\'ll type when you open Finan2. Better one that isn\'t your birthday.';

  @override
  String get appLockConfirmTitle => 'Type it again';

  @override
  String get appLockConfirmMessage => 'To be sure it\'s the one you want.';

  @override
  String get appLockMismatch => 'They don\'t match. Choose the PIN again.';

  @override
  String get appLockCurrentTitle => 'Enter your current PIN';

  @override
  String get appLockCurrentMessage => 'Changing the lock needs the PIN you have now.';

  @override
  String get appLockValuePin => 'PIN only';

  @override
  String get appLockValueBiometrics => 'With fingerprint or face';

  @override
  String get appLockBiometricsUnavailable =>
      'This phone has no fingerprint or face set up. Add one in the phone\'s settings and come back here.';

  @override
  String get onboardingNotificationsTitle => 'Don\'t miss a thing';

  @override
  String get onboardingNotificationsMessage =>
      'We\'ll tell you when a payment is near, when you go over budget and, if you share the household, when the other person records something. Change it anytime in Settings › Notifications.';

  @override
  String get onboardingPinTitle => 'Create your PIN';

  @override
  String get onboardingPinMessage =>
      'With these 4 digits you open Finan2 without signing in again. It only works on this phone.';

  @override
  String get onboardingBiometricsTitle => 'Unlock with your fingerprint or face?';

  @override
  String get onboardingBiometricsMessage =>
      'Faster than typing the PIN, which still works. Change it anytime in Settings › App lock.';

  @override
  String get onboardingBiometricsFailed =>
      'We couldn\'t recognize you. Try again or choose «Not now».';

  @override
  String get notificationPrefsOffBanner =>
      'Notifications are off on this phone: no alerts reach you.';

  @override
  String get notificationPrefsBlockedTitle => 'Turn them on from the phone';

  @override
  String get notificationPrefsBlockedMessage =>
      'The phone no longer lets the app ask. Go to the phone\'s settings › Apps › Finan2 › Notifications and turn them on.';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePassword => 'Password';

  @override
  String get profilePasswordGoogle =>
      'You sign in with Google: the password is changed in your Google account.';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profilePasswordSentTitle => 'Check your email';

  @override
  String profilePasswordSentMessage(String email) {
    return 'We sent a link to $email to choose a new password.';
  }

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profilePreferencesNote =>
      'Language and theme are saved to your account: you\'ll find them the same on another phone.';
}
