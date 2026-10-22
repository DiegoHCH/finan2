/// The first day a movement (or a fijo's start) can be dated: the 1st of
/// the month the account was created. Anything earlier was already behind
/// the balances typed in when setting up, so logging it would take it out
/// twice. Without a creation date, three years back, as before.
///
/// [current] keeps an existing record's own date reachable when editing.
DateTime earliestDate({DateTime? accountCreatedAt, required DateTime today, DateTime? current}) {
  final floor = accountCreatedAt == null
      ? DateTime(today.year - 3)
      : DateTime(accountCreatedAt.year, accountCreatedAt.month);
  if (current != null && current.isBefore(floor)) {
    return DateTime(current.year, current.month, current.day);
  }
  return floor;
}
