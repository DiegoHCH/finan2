import 'package:finan2/core/utils/swatch_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('up to as many ids as colors never share one', () {
    final ids = ['a1', 'b2', 'c3', 'd4', 'e5', 'f6'];
    expect(assignSwatches(ids, 6).values.toSet(), hasLength(6));
  });

  test('the order of the list does not change the colors', () {
    final ids = ['x9', 'k2', 'm7', 'q1'];
    expect(assignSwatches(ids, 6), assignSwatches(ids.reversed, 6));
  });

  test('past the number of colors they start to repeat, without hanging', () {
    final slots = assignSwatches([for (var i = 0; i < 9; i++) 'id$i'], 6);
    expect(slots, hasLength(9));
    expect(slots.values.every((s) => s >= 0 && s < 6), isTrue);
  });
}
