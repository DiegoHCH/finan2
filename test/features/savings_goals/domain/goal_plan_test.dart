import 'package:finan2/features/savings_goals/domain/goal_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final october = DateTime(2026, 10, 15);

  group('monthlyNeeded', () {
    test('splits what is missing over the months left, rounded up', () {
      expect(
        monthlyNeeded(target: 12000000, saved: 0, targetDate: DateTime(2027, 12), now: october),
        857143,
      );
      expect(
        monthlyNeeded(
          target: 6000000,
          saved: 2400000,
          targetDate: DateTime(2027, 6, 30),
          now: october,
        ),
        450000,
      );
    });

    test('a date this month or past leaves one month to do it', () {
      expect(
        monthlyNeeded(target: 100, saved: 40, targetDate: DateTime(2026, 9), now: october),
        60,
      );
    });

    test('no date, no figure; reached, nothing more', () {
      expect(monthlyNeeded(target: 100, saved: 0, targetDate: null, now: october), isNull);
      expect(monthlyNeeded(target: 100, saved: 120, targetDate: DateTime(2027), now: october), 0);
    });
  });

  test('monthsUntil counts calendar months, at least one', () {
    expect(monthsUntil(DateTime(2026, 12, 1), october), 2);
    expect(monthsUntil(DateTime(2026, 10, 30), october), 1);
  });

  test('contributedBy sums each person', () {
    expect(contributedBy([('a', 500), ('b', 1200), ('a', 300)]), {'a': 800, 'b': 1200});
  });

  test('goalsOnTime only counts goals with a date', () {
    expect(goalsOnTime([true, false, null, true]), (onTime: 2, dated: 3));
  });
}
