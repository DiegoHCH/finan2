import 'package:cloud_firestore/cloud_firestore.dart';

import 'investment_model.dart';

class InvestmentRepository {
  InvestmentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _investments(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('investments');

  Stream<List<Investment>> watchInvestments(String householdId) {
    return _investments(householdId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Investment.fromFirestore).toList(),
        );
  }

  Future<String> createInvestment(String householdId, Investment investment) async {
    final doc = await _investments(householdId).add(investment.toFirestore());
    return doc.id;
  }

  Future<void> updateInvestment(String householdId, Investment investment) {
    return _investments(householdId).doc(investment.id).update(investment.toFirestore());
  }

  Future<void> deleteInvestment(String householdId, String investmentId) {
    return _investments(householdId).doc(investmentId).delete();
  }
}
