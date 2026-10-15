// Recurring bills' due dates - a port of RecurringBill.occurrencesBetween
// (lib/features/recurring_bills/data/recurring_bill_model.dart) and
// RecurringBillScanner.movementIdFor. Keep the three in step: a date or an
// ID computed differently here makes the app generate a second movement.
//
// Dates are UTC midnights standing for a calendar day in Colombia, the same
// day the phone sees.

const CO_UTC_OFFSET_HOURS = 5;

export function day(y, m, d) {
  // Date.UTC rolls overflow into the next month, like Dart's DateTime.
  return new Date(Date.UTC(y, m - 1, d));
}

export function isoDay(date) {
  return date.toISOString().slice(0, 10);
}

/// The Colombian calendar day of a Firestore timestamp ("2026-10-05T05:00:00Z").
export function coDayOf(timestamp) {
  const shifted = new Date(Date.parse(timestamp) - CO_UTC_OFFSET_HOURS * 3600 * 1000);
  return day(shifted.getUTCFullYear(), shifted.getUTCMonth() + 1, shifted.getUTCDate());
}

function clampDay(y, m, d) {
  const last = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return Math.min(Math.max(d, 1), last);
}

function addDays(date, n) {
  return day(date.getUTCFullYear(), date.getUTCMonth() + 1, date.getUTCDate() + n);
}

/// [bill]: { id, frequency, dayOfMonth, startDate?, endDate?, resumedOn? },
/// dates already as days. Every due date in [from, to], both inclusive.
export function occurrencesBetween(bill, from, to) {
  let lower = from;
  let upper = to;
  for (const floor of [bill.startDate, bill.resumedOn]) {
    if (floor && floor > lower) lower = floor;
  }
  if (bill.endDate && bill.endDate < upper) upper = bill.endDate;
  if (upper < lower) return [];

  const dates = [];
  switch (bill.frequency) {
    case 'weekly':
    case 'biweekly': {
      const step = bill.frequency === 'weekly' ? 7 : 14;
      const anchor = bill.startDate ?? lower;
      const skipped = Math.floor((lower - anchor) / 86400000 / step);
      for (let k = Math.max(skipped, 0); ; k++) {
        const date = addDays(anchor, k * step);
        if (date > upper) break;
        if (date >= lower) dates.push(date);
      }
      break;
    }
    case 'yearly': {
      const month = bill.startDate ? bill.startDate.getUTCMonth() + 1 : 1;
      for (let y = lower.getUTCFullYear(); y <= upper.getUTCFullYear(); y++) {
        dates.push(day(y, month, clampDay(y, month, bill.dayOfMonth)));
      }
      break;
    }
    default: {
      // monthly, semimonthly, and anything unknown read as monthly.
      const days = new Set([bill.dayOfMonth]);
      if (bill.frequency === 'semimonthly') days.add(bill.dayOfMonth + 15);
      for (
        let month = day(lower.getUTCFullYear(), lower.getUTCMonth() + 1, 1);
        month <= upper;
        month = day(month.getUTCFullYear(), month.getUTCMonth() + 2, 1)
      ) {
        const y = month.getUTCFullYear();
        const m = month.getUTCMonth() + 1;
        for (const d of days) dates.push(day(y, m, clampDay(y, m, d)));
      }
    }
  }
  return dates.filter((d) => d >= lower && d <= upper).sort((a, b) => a - b);
}

export function movementIdFor(bill, date) {
  const y = date.getUTCFullYear();
  const m = date.getUTCMonth() + 1;
  return (bill.frequency ?? 'monthly') === 'monthly'
    ? `recurring_${bill.id}_${y}_${m}`
    : `recurring_${bill.id}_${y}_${m}_${date.getUTCDate()}`;
}
