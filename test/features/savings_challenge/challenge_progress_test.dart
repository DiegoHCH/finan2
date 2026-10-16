import 'package:finan2/features/savings_challenge/domain/challenge_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds the marked cells and points at the first one left', () {
    final progress = challengeProgress([2000, 5000, 10000, 20000], [true, false, true]);
    expect(progress.saved, 12000);
    expect(progress.target, 37000);
    expect(progress.doneCount, 2);
    expect(progress.cellCount, 4);
    expect(progress.nextIndex, 1);
    expect(progress.complete, isFalse);
  });

  test('every cell marked is complete', () {
    final progress = challengeProgress([2000, 5000], [true, true]);
    expect(progress.nextIndex, isNull);
    expect(progress.complete, isTrue);
  });
}
