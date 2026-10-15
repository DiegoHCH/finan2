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
}
