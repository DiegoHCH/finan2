import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import 'household_providers.dart';

/// How a member shows up next to a movement: their name and their place in
/// the household, which fixes their color (R5).
class MemberLabel {
  const MemberLabel({required this.name, required this.index});

  /// Full name, or «?» when the household doesn't know it.
  final String name;

  /// 0 for the first member, 1 for the second.
  final int index;

  String get firstName => name.trim().split(' ').first;
}

/// uid -> [MemberLabel]. The signed-in member falls back to their account
/// name while the household has none stored for them.
final memberLabelProvider = Provider<MemberLabel Function(String uid)>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  final user = ref.watch(authStateChangesProvider).value;
  return (uid) {
    final stored = household?.memberInfo[uid]?.name.trim() ?? '';
    final own = uid == user?.uid ? (user?.displayName?.trim() ?? '') : '';
    final name = stored.isNotEmpty ? stored : (own.isNotEmpty ? own : '?');
    final index = household?.members.indexOf(uid) ?? 0;
    return MemberLabel(name: name, index: index < 0 ? 0 : index);
  };
});
