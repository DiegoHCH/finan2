import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_model.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_household_crypto.dart';

const _householdId = 'h1';

void main() {
  late FakeFirebaseFirestore firestore;
  late HouseholdCrypto crypto;
  late SavingsGoalRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    crypto = await testHouseholdCrypto(_householdId);
    repository = SavingsGoalRepository(firestore: firestore, crypto: crypto);
  });

  Future<String> seedGoal(int targetAmount) async {
    final goal = SavingsGoal(
      id: '',
      name: 'Viaje',
      iconSlug: 'viaje',
      targetAmount: targetAmount,
      targetDate: null,
      monthlyContribution: 100000,
      interestRate: 0,
      contributions: const [],
      createdBy: 'u1',
    );
    return repository.createGoal(_householdId, goal);
  }

  Future<bool?> readNearFlag(String goalId) async {
    final doc = await firestore
        .collection('households')
        .doc(_householdId)
        .collection('goalAlerts')
        .doc(goalId)
        .get();
    return doc.data()?['near'] as bool?;
  }

  test('a contribution that crosses 90% sets the plaintext near flag', () async {
    final goalId = await seedGoal(1000000);
    await repository.addContribution(
      _householdId,
      goalId,
      Contribution(date: DateTime(2026, 7, 1), amount: 950000, createdBy: 'u1'),
    );
    expect(await readNearFlag(goalId), isTrue);
  });

  test('a contribution below 90% leaves the flag false', () async {
    final goalId = await seedGoal(1000000);
    await repository.addContribution(
      _householdId,
      goalId,
      Contribution(date: DateTime(2026, 7, 1), amount: 500000, createdBy: 'u1'),
    );
    expect(await readNearFlag(goalId), isFalse);
  });

  test('a contribution that fully completes the goal clears the flag (no longer "near")', () async {
    final goalId = await seedGoal(1000000);
    await repository.addContribution(
      _householdId,
      goalId,
      Contribution(date: DateTime(2026, 7, 1), amount: 1000000, createdBy: 'u1'),
    );
    expect(await readNearFlag(goalId), isFalse);
  });
}
