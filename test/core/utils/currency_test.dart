import 'package:finan2/core/utils/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoneyCompact', () {
    test('millions keep one decimal unless it is zero', () {
      expect(formatMoneyCompact(7000000), r'$7M');
      expect(formatMoneyCompact(1900000), r'$1,9M');
      expect(formatMoneyCompact(42530000), r'$42,5M');
    });

    test('thousands round to the nearest one', () {
      expect(formatMoneyCompact(60000), r'$60k');
      expect(formatMoneyCompact(28400), r'$28k');
      expect(formatMoneyCompact(999600), r'$1M');
    });

    test('small and negative amounts', () {
      expect(formatMoneyCompact(800), r'$800');
      expect(formatMoneyCompact(-40000), r'−$40k');
      expect(formatMoneyCompact(2500, 'USD'), r'US$3k');
    });
  });
}
