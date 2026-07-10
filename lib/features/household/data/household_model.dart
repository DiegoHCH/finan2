import 'package:cloud_firestore/cloud_firestore.dart';

/// Basic info about a household member, keyed by their auth uid in
/// [Household.memberInfo].
class HouseholdMemberInfo {
  const HouseholdMemberInfo({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  factory HouseholdMemberInfo.fromMap(Map<String, dynamic> map) {
    return HouseholdMemberInfo(
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}

/// A household shared by up to 2 members. The document [id] doubles as the
/// human-shareable invite code (see HouseholdRepository).
class Household {
  const Household({
    required this.id,
    required this.name,
    required this.members,
    required this.memberInfo,
    required this.currency,
    required this.startYear,
    required this.weekStartsOn,
  });

  final String id;
  final String name;
  final List<String> members;
  final Map<String, HouseholdMemberInfo> memberInfo;
  final String currency;
  final int startYear;
  final String weekStartsOn;

  String get inviteCode => id;

  factory Household.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final rawMemberInfo = (data['memberInfo'] as Map?)?.cast<String, dynamic>() ?? {};
    return Household(
      id: doc.id,
      name: data['name'] as String? ?? 'Nuestro hogar',
      members: List<String>.from(data['members'] as List? ?? const []),
      memberInfo: rawMemberInfo.map(
        (uid, info) => MapEntry(
          uid,
          HouseholdMemberInfo.fromMap((info as Map).cast<String, dynamic>()),
        ),
      ),
      currency: data['settings']?['currency'] as String? ?? 'COP',
      startYear: data['settings']?['startYear'] as int? ?? DateTime.now().year,
      weekStartsOn: data['settings']?['weekStartsOn'] as String? ?? 'monday',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members,
      'memberInfo': memberInfo.map((uid, info) => MapEntry(uid, info.toMap())),
      'settings': {
        'currency': currency,
        'startYear': startYear,
        'weekStartsOn': weekStartsOn,
      },
    };
  }
}
