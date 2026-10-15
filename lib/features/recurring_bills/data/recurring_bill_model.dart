import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import '../../categories/data/category_model.dart';

enum RecurringFrequency { weekly, biweekly, semimonthly, monthly, yearly }

/// Its UI label is frequencyLabel, in recurring_schedule_label.dart.
extension RecurringFrequencyLabel on RecurringFrequency {
  /// How many times it happens in an average month.
  double get perMonth => switch (this) {
    RecurringFrequency.weekly => 52 / 12,
    RecurringFrequency.biweekly => 26 / 12,
    RecurringFrequency.semimonthly => 2,
    RecurringFrequency.monthly => 1,
    RecurringFrequency.yearly => 1 / 12,
  };

  static RecurringFrequency fromName(String? name) => RecurringFrequency.values.firstWhere(
    (f) => f.name == name,
    orElse: () => RecurringFrequency.monthly,
  );
}

/// A fixed income or bill (salary, rent, utilities...) that generates its
/// own Movement each time it comes due - see recurring_bill_scanner.dart.
/// Only ingreso/factura make sense here (the mockup only ever shows those
/// 2), unlike ad-hoc gasto/ahorro spending.
class RecurringBill {
  const RecurringBill({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.amount,
    required this.dayOfMonth,
    this.frequency = RecurringFrequency.monthly,
    this.startDate,
    this.endDate,
    this.paused = false,
    this.resumedOn,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final CategoryType type;
  final String categoryId;
  final String accountId;
  final int amount;

  /// Monthly and quincenal: the day it falls on (quincenal adds a second
  /// one 15 days later). Always [startDate]'s day when there is one.
  final int dayOfMonth;
  final RecurringFrequency frequency;

  /// The first occurrence - nothing is generated before it. Weekly and
  /// every-2-weeks count from it, yearly repeats its month and day. Bills
  /// saved before frequencies existed have none.
  final DateTime? startDate;

  /// The last day an occurrence can fall on.
  final DateTime? endDate;
  final bool paused;

  /// Set when a pause ends: the dates it skipped stay skipped.
  final DateTime? resumedOn;
  final String createdBy;

  bool hasEndedBy(DateTime day) => endDate != null && _dateOnly(day).isAfter(endDate!);

  /// Neither paused nor past its end date.
  bool isActiveOn(DateTime day) => !paused && !hasEndedBy(day);

  /// The average amount per month, for the "al mes" total.
  int get monthlyAmount => (amount * frequency.perMonth).round();

  /// Every date it comes due between [from] and [to], both inclusive,
  /// ignoring [paused].
  List<DateTime> occurrencesBetween(DateTime from, DateTime to) {
    var lower = _dateOnly(from);
    var upper = _dateOnly(to);
    for (final floor in [startDate, resumedOn]) {
      if (floor != null && floor.isAfter(lower)) lower = _dateOnly(floor);
    }
    if (endDate != null && endDate!.isBefore(upper)) {
      upper = _dateOnly(endDate!);
    }
    if (upper.isBefore(lower)) return const [];

    final dates = <DateTime>[];
    switch (frequency) {
      case RecurringFrequency.weekly:
      case RecurringFrequency.biweekly:
        final step = frequency == RecurringFrequency.weekly ? 7 : 14;
        final anchor = _dateOnly(startDate ?? lower);
        // Calendar days, not Durations, so a DST change can't shift the day.
        final skipped = lower.difference(anchor).inDays ~/ step;
        for (var k = skipped < 0 ? 0 : skipped; ; k++) {
          final date = DateTime(anchor.year, anchor.month, anchor.day + k * step);
          if (date.isAfter(upper)) break;
          if (!date.isBefore(lower)) dates.add(date);
        }
      case RecurringFrequency.semimonthly:
      case RecurringFrequency.monthly:
        for (
          var month = DateTime(lower.year, lower.month);
          !month.isAfter(upper);
          month = DateTime(month.year, month.month + 1)
        ) {
          final days = {
            dayOfMonth,
            if (frequency == RecurringFrequency.semimonthly) dayOfMonth + 15,
          };
          for (final day in days) {
            dates.add(DateTime(month.year, month.month, _clampDay(month.year, month.month, day)));
          }
        }
      case RecurringFrequency.yearly:
        final anchorMonth = startDate?.month ?? 1;
        for (var year = lower.year; year <= upper.year; year++) {
          dates.add(DateTime(year, anchorMonth, _clampDay(year, anchorMonth, dayOfMonth)));
        }
    }
    return [
      for (final date in dates)
        if (!date.isBefore(lower) && !date.isAfter(upper)) date,
    ]..sort();
  }

  static Future<RecurringBill> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    return RecurringBill(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: CategoryTypeLabel.fromName(data['type'] as String? ?? 'factura'),
      categoryId: data['categoryId'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      amount: await crypto.decryptAmount(householdId, data['amount'] as String),
      dayOfMonth: (data['dayOfMonth'] as num?)?.toInt() ?? 1,
      frequency: RecurringFrequencyLabel.fromName(data['frequency'] as String?),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      paused: data['paused'] as bool? ?? false,
      resumedOn: (data['resumedOn'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'name': name,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'amount': await crypto.encryptAmount(householdId, amount),
      'dayOfMonth': dayOfMonth,
      'frequency': frequency.name,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'paused': paused,
      'resumedOn': resumedOn == null ? null : Timestamp.fromDate(resumedOn!),
      'createdBy': createdBy,
    };
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int _clampDay(int year, int month, int day) {
  final last = DateTime(year, month + 1, 0).day;
  return day.clamp(1, last);
}
