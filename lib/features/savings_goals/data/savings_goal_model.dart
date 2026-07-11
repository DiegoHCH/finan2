import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

const _daysPerMonth = 30.436875;

/// A single contribution toward a goal - who added it, when, and how much.
class Contribution {
  const Contribution({
    required this.date,
    required this.amount,
    required this.createdBy,
  });

  final DateTime date;
  final int amount;
  final String createdBy;

  factory Contribution.fromMap(Map<String, dynamic> map) {
    return Contribution(
      date: (map['date'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toInt(),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'createdBy': createdBy,
    };
  }
}

/// A household savings goal - a trip, an emergency fund, etc. Progress and
/// (optional) interest are always computed client-side from [contributions],
/// never stored redundantly.
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.iconSlug,
    required this.targetAmount,
    required this.targetDate,
    required this.monthlyContribution,
    required this.interestRate,
    required this.contributions,
    this.createdBy = '',
  });

  final String id;
  final String name;
  final String iconSlug;
  final int targetAmount;
  final DateTime? targetDate;
  final int monthlyContribution;
  final double interestRate; // % E.A., 0 = sin interés
  final List<Contribution> contributions;
  final String createdBy;

  int get totalContributed =>
      contributions.fold(0, (total, c) => total + c.amount);

  /// Compounds each contribution monthly from its date to now at the
  /// E.A.-derived monthly rate. 0 if no rate was set for this goal.
  double interestEarnedAsOf(DateTime now) {
    if (interestRate <= 0) return 0;
    final monthlyRate = math.pow(1 + interestRate / 100, 1 / 12) - 1;
    var earned = 0.0;
    for (final c in contributions) {
      final months = now.difference(c.date).inDays / _daysPerMonth;
      if (months <= 0) continue;
      final grown = c.amount * math.pow(1 + monthlyRate, months);
      earned += grown - c.amount;
    }
    return earned;
  }

  int currentAmountAsOf(DateTime now) =>
      totalContributed + interestEarnedAsOf(now).round();

  double progressFractionAsOf(DateTime now) {
    if (targetAmount <= 0) return 0;
    return (currentAmountAsOf(now) / targetAmount).clamp(0.0, 1.0);
  }

  /// null if there's no target date to be on time for.
  bool? onTrackAsOf(DateTime now) {
    final date = targetDate;
    if (date == null) return null;
    final remaining = targetAmount - currentAmountAsOf(now);
    if (remaining <= 0) return true;
    final monthsRemaining = (date.difference(now).inDays / _daysPerMonth).ceil();
    if (monthsRemaining <= 0) return false;
    final neededMonthly = remaining / monthsRemaining;
    return monthlyContribution >= neededMonthly;
  }

  factory SavingsGoal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawContributions = (data['contributions'] as List?) ?? const [];
    return SavingsGoal(
      id: doc.id,
      name: data['name'] as String? ?? '',
      iconSlug: data['iconSlug'] as String? ?? 'otro',
      targetAmount: (data['targetAmount'] as num?)?.toInt() ?? 0,
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      monthlyContribution: (data['monthlyContribution'] as num?)?.toInt() ?? 0,
      interestRate: (data['interestRate'] as num?)?.toDouble() ?? 0,
      contributions: rawContributions
          .map((c) => Contribution.fromMap((c as Map).cast<String, dynamic>()))
          .toList(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconSlug': iconSlug,
      'targetAmount': targetAmount,
      'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate!),
      'monthlyContribution': monthlyContribution,
      'interestRate': interestRate,
      'contributions': contributions.map((c) => c.toMap()).toList(),
      'createdBy': createdBy,
    };
  }
}
