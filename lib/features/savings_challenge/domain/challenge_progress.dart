/// How far along a savings challenge is: the grid's cells and which are
/// marked, read as what's done and which one comes next.
class ChallengeProgress {
  const ChallengeProgress({
    required this.saved,
    required this.target,
    required this.doneCount,
    required this.cellCount,
    required this.nextIndex,
  });

  final int saved;
  final int target;
  final int doneCount;
  final int cellCount;

  /// The first cell not marked yet - the one that's due; null when every
  /// cell is done.
  final int? nextIndex;

  bool get complete => nextIndex == null;
}

/// [amounts] is each cell's amount; [done] which are marked (it may be
/// shorter than [amounts]: the rest aren't).
ChallengeProgress challengeProgress(List<int> amounts, List<bool> done) {
  var saved = 0;
  var target = 0;
  var doneCount = 0;
  int? nextIndex;
  for (var i = 0; i < amounts.length; i++) {
    target += amounts[i];
    if (i < done.length && done[i]) {
      saved += amounts[i];
      doneCount++;
    } else {
      nextIndex ??= i;
    }
  }
  return ChallengeProgress(
    saved: saved,
    target: target,
    doneCount: doneCount,
    cellCount: amounts.length,
    nextIndex: nextIndex,
  );
}
