import 'package:finan2/features/savings_goals/data/savings_goal_model.dart';
import 'package:flutter_test/flutter_test.dart';

SavingsGoal _goal({
  int targetAmount = 12000000,
  DateTime? targetDate,
  int monthlyContribution = 500000,
  double interestRate = 0,
  List<Contribution> contributions = const [],
}) {
  return SavingsGoal(
    id: 'goal',
    name: 'Viaje',
    iconSlug: 'viaje',
    targetAmount: targetAmount,
    targetDate: targetDate,
    monthlyContribution: monthlyContribution,
    interestRate: interestRate,
    contributions: contributions,
  );
}

void main() {
  final now = DateTime(2026, 7, 9);

  group('totalContributed / interestEarnedAsOf / currentAmountAsOf', () {
    test('with no interest rate, current amount is just the sum of contributions', () {
      final goal = _goal(
        contributions: [
          Contribution(date: now.subtract(const Duration(days: 400)), amount: 7000000, createdBy: 'u1'),
          Contribution(date: now.subtract(const Duration(days: 10)), amount: 500000, createdBy: 'u2'),
        ],
      );
      expect(goal.totalContributed, 7500000);
      expect(goal.interestEarnedAsOf(now), 0);
      expect(goal.currentAmountAsOf(now), 7500000);
    });

    test('a contribution one year old at a 12% E.A. rate earns ~12%', () {
      final goal = _goal(
        interestRate: 12,
        contributions: [
          Contribution(
            date: now.subtract(const Duration(days: 365)),
            amount: 1000000,
            createdBy: 'u1',
          ),
        ],
      );
      // (1 + monthlyRate)^12 == 1 + annualRate by construction, so ~12%
      // growth after a year - allow slack for the 30.436875-day/month
      // approximation not landing on exactly 12.0 months.
      expect(goal.interestEarnedAsOf(now), closeTo(120000, 3000));
    });

    test('a future-dated contribution (clock skew) contributes no negative interest', () {
      final goal = _goal(
        interestRate: 12,
        contributions: [
          Contribution(date: now.add(const Duration(days: 5)), amount: 100000, createdBy: 'u1'),
        ],
      );
      expect(goal.interestEarnedAsOf(now), 0);
      expect(goal.currentAmountAsOf(now), 100000);
    });
  });

  group('progressFractionAsOf', () {
    test('clamps at 1.0 once the goal is met or exceeded', () {
      final goal = _goal(
        targetAmount: 1000000,
        contributions: [
          Contribution(date: now, amount: 2000000, createdBy: 'u1'),
        ],
      );
      expect(goal.progressFractionAsOf(now), 1.0);
    });

    test('is 0 when targetAmount is not set', () {
      final goal = _goal(targetAmount: 0);
      expect(goal.progressFractionAsOf(now), 0);
    });

    test('is the plain ratio otherwise', () {
      final goal = _goal(
        targetAmount: 1000000,
        contributions: [
          Contribution(date: now, amount: 250000, createdBy: 'u1'),
        ],
      );
      expect(goal.progressFractionAsOf(now), 0.25);
    });
  });

  group('onTrackAsOf', () {
    test('is null when there is no target date', () {
      final goal = _goal(targetDate: null);
      expect(goal.onTrackAsOf(now), isNull);
    });

    test('is true once the target amount is already met', () {
      final goal = _goal(
        targetAmount: 1000000,
        targetDate: now.add(const Duration(days: 30)),
        contributions: [Contribution(date: now, amount: 1000000, createdBy: 'u1')],
      );
      expect(goal.onTrackAsOf(now), isTrue);
    });

    test('is true when the monthly contribution covers what is needed', () {
      // 6 months left, 3,000,000 remaining -> needs 500,000/mo, contributing exactly that.
      final goal = _goal(
        targetAmount: 3000000,
        targetDate: now.add(const Duration(days: 182)),
        monthlyContribution: 500000,
      );
      expect(goal.onTrackAsOf(now), isTrue);
    });

    test('is false when the monthly contribution falls short', () {
      final goal = _goal(
        targetAmount: 3000000,
        targetDate: now.add(const Duration(days: 182)),
        monthlyContribution: 100000,
      );
      expect(goal.onTrackAsOf(now), isFalse);
    });

    test('is false when the target date has already passed and the goal is unmet', () {
      final goal = _goal(
        targetAmount: 3000000,
        targetDate: now.subtract(const Duration(days: 10)),
        monthlyContribution: 500000,
      );
      expect(goal.onTrackAsOf(now), isFalse);
    });
  });
}
