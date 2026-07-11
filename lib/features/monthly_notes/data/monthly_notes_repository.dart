import 'package:cloud_firestore/cloud_firestore.dart';

import 'monthly_notes_model.dart';

class MonthlyNotesRepository {
  MonthlyNotesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String householdId, int year, int month) =>
      _db
          .collection('households')
          .doc(householdId)
          .collection('monthlyNotes')
          .doc('${year}_$month');

  Stream<MonthlyNotes> watchNotes(String householdId, {required int year, required int month}) {
    return _doc(householdId, year, month)
        .snapshots()
        .map(MonthlyNotes.fromFirestore);
  }

  Future<void> saveThisMonth(
    String householdId, {
    required int year,
    required int month,
    required String text,
  }) {
    return _doc(householdId, year, month).set({'thisMonth': text}, SetOptions(merge: true));
  }

  Future<void> saveNextMonth(
    String householdId, {
    required int year,
    required int month,
    required String text,
  }) {
    return _doc(householdId, year, month).set({'nextMonth': text}, SetOptions(merge: true));
  }
}
