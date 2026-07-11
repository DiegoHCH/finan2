import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../budget/presentation/viewmodels/budget_providers.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import '../../../transactions/presentation/viewmodels/transaction_providers.dart';
import '../../data/report_builder.dart';

final reportBuilderProvider = Provider<ReportBuilder>((ref) {
  return ReportBuilder(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    budgetRepository: ref.watch(budgetRepositoryProvider),
    debtRepository: ref.watch(debtRepositoryProvider),
    savingsGoalRepository: ref.watch(savingsGoalRepositoryProvider),
  );
});
