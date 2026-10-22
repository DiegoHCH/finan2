import 'package:finan2/features/transactions/domain/earliest_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 22);

  test('movements go back to the 1st of the month the account was created', () {
    expect(
      earliestDate(accountCreatedAt: DateTime(2026, 9, 12, 18, 30), today: today),
      DateTime(2026, 9),
    );
  });

  test('without a creation date, three years back as before', () {
    expect(earliestDate(today: today), DateTime(2023));
  });

  test('an older record being edited keeps its own date reachable', () {
    expect(
      earliestDate(
        accountCreatedAt: DateTime(2026, 9, 12),
        today: today,
        current: DateTime(2026, 7, 3, 10),
      ),
      DateTime(2026, 7, 3),
    );
  });
}
