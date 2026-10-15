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
}
