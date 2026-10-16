/// What the investments add up to: what was put in, what they're worth
/// today (the value the household types in), and the difference in money -
/// positive a gain, negative a loss.
({int invested, int value, int gain}) portfolioTotals(
  Iterable<({int invested, int value})> holdings,
) {
  var invested = 0;
  var value = 0;
  for (final holding in holdings) {
    invested += holding.invested;
    value += holding.value;
  }
  return (invested: invested, value: value, gain: value - invested);
}
