import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';
import 'investment_model.dart';

class InvestmentRepository {
  InvestmentRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  CollectionReference<Map<String, dynamic>> _investments(String householdId) => _db
      .collection('households')
      .doc(householdId)
      .collection('investments');

  Stream<List<Investment>> watchInvestments(String householdId) {
    return _investments(householdId).orderBy('name').snapshots().asyncMap(
          (snap) => Future.wait(
            snap.docs.map(
              (doc) => Investment.fromFirestore(doc, _crypto, householdId),
            ),
          ),
        );
  }

  Future<String> createInvestment(String householdId, Investment investment) async {
    final doc = await _investments(householdId).add(
      await investment.toFirestore(_crypto, householdId),
    );
    return doc.id;
  }

  Future<void> updateInvestment(String householdId, Investment investment) async {
    await _investments(householdId).doc(investment.id).update(
          await investment.toFirestore(_crypto, householdId),
        );
  }

  Future<void> deleteInvestment(String householdId, String investmentId) {
    return _investments(householdId).doc(investmentId).delete();
  }
}
