import 'package:cloud_firestore/cloud_firestore.dart';

/// Free-form notes shared by the household for a given month - "Notas de
/// este mes" and "Para el siguiente mes" from the Excel. Just two text
/// blobs, not a structured list of individual notes (the mockup has no
/// add/delete affordance, just editable text).
class MonthlyNotes {
  const MonthlyNotes({required this.thisMonth, required this.nextMonth});

  final String thisMonth;
  final String nextMonth;

  static const empty = MonthlyNotes(thisMonth: '', nextMonth: '');

  factory MonthlyNotes.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return empty;
    return MonthlyNotes(
      thisMonth: data['thisMonth'] as String? ?? '',
      nextMonth: data['nextMonth'] as String? ?? '',
    );
  }
}
