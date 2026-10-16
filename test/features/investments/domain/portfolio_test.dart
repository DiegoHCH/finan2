import 'package:finan2/features/investments/domain/portfolio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('portfolioTotals adds what went in and what it is worth', () {
    final totals = portfolioTotals([
      (invested: 2000000, value: 2140000),
      (invested: 3940000, value: 4260000),
      (invested: 2090000, value: 2000000),
    ]);
    expect(totals.invested, 8030000);
    expect(totals.value, 8400000);
    expect(totals.gain, 370000);
  });

  test('a loss is a negative gain', () {
    expect(portfolioTotals([(invested: 1000000, value: 910000)]).gain, -90000);
  });

  test('no investments add up to zero', () {
    expect(portfolioTotals(const []), (invested: 0, value: 0, gain: 0));
  });
}
