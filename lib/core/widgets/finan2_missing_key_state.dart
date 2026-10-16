import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/household/presentation/key_recovery_actions.dart';
import '../../features/household/presentation/viewmodels/household_providers.dart';
import '../../features/household/presentation/viewmodels/member_providers.dart';
import '../../l10n/l10n.dart';
import 'finan2_empty_state.dart';

/// «Sin llave»: this device doesn't have the household's key yet
/// (reinstall, new phone, or it joined pasting only the short code), so
/// amounts can't open here. Says what's missing - not «error de cifrado» -
/// and the two real ways to get it back: the recovery phrase, or the code
/// the partner shares from Ajustes, naming them.
class Finan2MissingKeyState extends ConsumerWidget {
  const Finan2MissingKeyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final household = ref.watch(currentHouseholdProvider).value;
    final uid = ref.watch(authStateChangesProvider).value?.uid;
    final memberLabel = ref.watch(memberLabelProvider);
    final partner = household?.members.where((m) => m != uid).firstOrNull;
    final partnerName = partner == null ? null : memberLabel(partner).firstName;

    return Finan2EmptyState(
      icon: Icons.vpn_key_outlined,
      title: l10n.coreMissingKeyTitle,
      description: l10n.coreMissingKeyBody,
      actionLabel: household == null ? null : l10n.coreMissingKeyUsePhrase,
      onAction: household == null ? null : () => unlockWithPhrase(context, ref, household.id),
      secondaryLabel: household == null
          ? null
          : (partnerName == null || partnerName == '?')
          ? l10n.coreMissingKeyPasteCode
          : l10n.coreMissingKeyAskPartner(partnerName),
      onSecondary: household == null ? null : () => unlockWithCode(context, ref, household.id),
      secondaryAsButton: true,
    );
  }
}
