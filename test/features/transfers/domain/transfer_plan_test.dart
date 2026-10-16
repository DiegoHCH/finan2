import 'package:finan2/features/transfers/domain/transfer_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('balancesAfterTransfer moves the amount from one to the other', () {
    final after = balancesAfterTransfer(fromBalance: 4120000, toBalance: 1000000, amount: 500000);
    expect(after.from, 3620000);
    expect(after.to, 1500000);
    expect(after.overdrawn, isFalse);
  });

  test('balancesAfterTransfer says when the source goes below zero', () {
    final after = balancesAfterTransfer(fromBalance: 100000, toBalance: 0, amount: 150000);
    expect(after.from, -50000);
    expect(after.overdrawn, isTrue);
  });

  test('groupByMonth puts the newest month first, newest item first', () {
    final dates = [
      DateTime(2026, 9, 9),
      DateTime(2026, 10, 3),
      DateTime(2026, 9, 18),
      DateTime(2026, 10, 14),
      DateTime(2025, 10, 1),
    ];
    final groups = groupByMonth(dates, (d) => d);
    expect(groups.map((g) => g.month), [DateTime(2026, 10), DateTime(2026, 9), DateTime(2025, 10)]);
    expect(groups.first.items, [DateTime(2026, 10, 14), DateTime(2026, 10, 3)]);
    expect(groups[1].items, [DateTime(2026, 9, 18), DateTime(2026, 9, 9)]);
  });

  test('groupByMonth of nothing is empty', () {
    expect(groupByMonth(<DateTime>[], (d) => d), isEmpty);
  });
}
