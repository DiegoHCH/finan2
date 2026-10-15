// What counts as new partner activity for the hourly cron. Kept apart from
// worker.js (no fetch, no env) so it can be tested in Node.

// The cron runs every hour; three hours of slack covers a missed run or two.
// The sentReminders markers stop anything inside the window from repeating.
export const ACTIVITY_WINDOW_MS = 3 * 60 * 60 * 1000;

/// Whether a Firestore REST timestamp (`createTime`, `updateTime` or a
/// timestampValue) falls inside the window ending at [nowMs]. Older records
/// are never announced - which is also what keeps turning "actividad de la
/// pareja" on from sending a push for everything already in the household.
export function isRecent(timestamp, nowMs) {
  if (!timestamp) return false;
  const ms = Date.parse(timestamp);
  return Number.isFinite(ms) && ms > nowMs - ACTIVITY_WINDOW_MS;
}

/// Contributions to a savings goal that someone other than [uid] added
/// inside the window. A contribution is an entry of the goal's array, so the
/// goal's `updateTime` gates the scan and the entry's own date filters it.
export function recentContributions(goalDoc, uid, nowMs) {
  if (!isRecent(goalDoc.updateTime, nowMs)) return [];
  return (goalDoc.fields?.contributions?.arrayValue?.values ?? [])
    .map((v) => v.mapValue?.fields)
    .filter(Boolean)
    .map((c) => ({ createdBy: c.createdBy?.stringValue, date: c.date?.timestampValue }))
    .filter((c) => c.createdBy && c.createdBy !== uid && c.date)
    // Contributions can be dated a day or two back; anything older is
    // history, not activity.
    .filter((c) => Date.parse(c.date) > nowMs - 3 * 24 * 60 * 60 * 1000);
}
