import 'package:finan2/core/utils/stable_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the same id always gives the same index', () {
    expect(stableIndex('debt-abc'), stableIndex('debt-abc'));
    expect(stableIndex('debt-abc'), isNot(stableIndex('debt-abd')));
    expect(stableIndex(''), 0);
    // Pinned: a change here would recolor every goal and debt.
    expect(stableIndex('abc'), 96354);
  });
}
