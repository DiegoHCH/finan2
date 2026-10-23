/// The first day a movement (or a fijo's start) can be dated: the 1st of
/// the month the household was created. Anything earlier was already behind
/// the balances typed in when setting it up, so logging it would take it out
/// twice. It's the household's date and not each account's, so a partner
/// who joins later can still log the months before they arrived.
///
/// Households from before that date was kept fall back to the account's;
/// with neither, three years back, as before.
///
/// [current] keeps an existing record's own date reachable when editing.
DateTime earliestDate({
  DateTime? householdCreatedAt,
  DateTime? accountCreatedAt,
  required DateTime today,
  DateTime? current,
}) {
  final since = householdCreatedAt ?? accountCreatedAt;
  final floor = since == null ? DateTime(today.year - 3) : DateTime(since.year, since.month);
  if (current != null && current.isBefore(floor)) {
    return DateTime(current.year, current.month, current.day);
  }
  return floor;
}
