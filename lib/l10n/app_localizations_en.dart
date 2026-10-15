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
}
