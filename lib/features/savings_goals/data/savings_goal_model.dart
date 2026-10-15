import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

const _daysPerMonth = 30.436875;

/// A single contribution toward a goal - who added it, when, and how much.
class Contribution {
  const Contribution({required this.date, required this.amount, required this.createdBy});

  final DateTime date;
  final int amount;
  final String createdBy;

  static Future<Contribution> fromMap(
    Map<String, dynamic> map,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    return Contribution(
      date: (map['date'] as Timestamp).toDate(),
      amount: await crypto.decryptAmount(householdId, map['amount'] as String),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toMap(HouseholdCrypto crypto, String householdId) async {
    return {
      'date': Timestamp.fromDate(date),
      'amount': await crypto.encryptAmount(householdId, amount),
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

  int get totalContributed => contributions.fold(0, (total, c) => total + c.amount);

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

  int currentAmountAsOf(DateTime now) => totalContributed + interestEarnedAsOf(now).round();

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

  static Future<SavingsGoal> fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    HouseholdCrypto crypto,
    String householdId,
  ) async {
    final data = doc.data()!;
    final rawContributions = (data['contributions'] as List?) ?? const [];
    return SavingsGoal(
      id: doc.id,
      name: data['name'] as String? ?? '',
      iconSlug: data['iconSlug'] as String? ?? 'otro',
      targetAmount: await crypto.decryptAmount(householdId, data['targetAmount'] as String),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      monthlyContribution: await crypto.decryptAmount(
        householdId,
        data['monthlyContribution'] as String,
      ),
      interestRate: (data['interestRate'] as num?)?.toDouble() ?? 0,
      contributions: await Future.wait(
        rawContributions.map(
          (c) => Contribution.fromMap((c as Map).cast<String, dynamic>(), crypto, householdId),
        ),
      ),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> toFirestore(HouseholdCrypto crypto, String householdId) async {
    return {
      'name': name,
      'iconSlug': iconSlug,
      'targetAmount': await crypto.encryptAmount(householdId, targetAmount),
      'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate!),
      'monthlyContribution': await crypto.encryptAmount(householdId, monthlyContribution),
      'interestRate': interestRate,
      'contributions': await Future.wait(contributions.map((c) => c.toMap(crypto, householdId))),
      'createdBy': createdBy,
    };
  }
}
