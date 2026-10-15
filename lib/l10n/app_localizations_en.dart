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
}
