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
