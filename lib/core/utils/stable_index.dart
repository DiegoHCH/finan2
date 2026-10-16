/// A small non-negative number derived from [id] that is the same on every
/// run and platform (unlike `String.hashCode`), for picking a color.
int stableIndex(String id) {
  var hash = 0;
  for (final unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}
