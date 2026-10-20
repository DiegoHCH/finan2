import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_code_box.dart';
import '../../../../core/widgets/finan2_prompt_page.dart';
import '../../../../core/widgets/finan2_steps.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../viewmodels/member_providers.dart';
import '../widgets/partner_circles.dart';

/// Shown after creating a household (or from its card in Ajustes): the invite
/// a member shares with their partner so they can join. Invites expire after
/// 7 days and only work once.
///
/// [shareCode] is `<code>.<key>` - the short human-readable invite code the
/// UI displays, plus the household's data encryption key riding along after
/// the dot (never sent to Firestore). Sharing always sends the full string;
/// only the code half is shown in the big code box.
class InviteHouseholdScreen extends ConsumerStatefulWidget {
  const InviteHouseholdScreen({
    required this.shareCode,
    this.expiresAt,
    this.onNewCode,
    this.setupSteps,
    super.key,
  });

  final String shareCode;

  /// When the invite stops working; shown as a date when known.
  final DateTime? expiresAt;

  /// Replaces the invite with a new one - from Ajustes, for a code sent to
  /// the wrong person or lost. Null hides the option.
  final Future<({String shareCode, DateTime expiresAt})?> Function()? onNewCode;

  /// The steps of the setup this closes, all lit; null from Ajustes.
  final int? setupSteps;

  @override
  ConsumerState<InviteHouseholdScreen> createState() => _InviteHouseholdScreenState();
}

class _InviteHouseholdScreenState extends ConsumerState<InviteHouseholdScreen> {
  late String _shareCode = widget.shareCode;
  late DateTime? _expiresAt = widget.expiresAt;

  String get _displayCode => _shareCode.split('.').first;

  Future<void> _newCode() async {
    final l10n = context.l10n;
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: l10n.householdInviteNewCodeTitle,
      message: l10n.householdInviteNewCodeMessage,
      confirmLabel: l10n.householdInviteNewCode,
    );
    if (!confirmed || !mounted) return;
    final invite = await widget.onNewCode!();
    if (invite == null || !mounted) return;
    setState(() {
      _shareCode = invite.shareCode;
      _expiresAt = invite.expiresAt;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final uid = ref.watch(authStateChangesProvider).value?.uid ?? '';
    final me = ref.watch(memberLabelProvider)(uid);
    final name = me.name.trim();
    final initial = name.isEmpty || name == '?' ? '?' : name.substring(0, 1).toUpperCase();
    final expiresAt = _expiresAt;
    final footnote = expiresAt == null
        ? l10n.householdInviteFootnote
        : l10n.householdInviteValidUntil(
            DateFormat.MMMMd(Localizations.localeOf(context).toLanguageTag()).format(expiresAt),
          );

    return Scaffold(
      body: Finan2PromptPage(
        top: widget.setupSteps == null
            ? null
            : Finan2Steps(reached: widget.setupSteps!, total: widget.setupSteps!),
        title: l10n.householdInviteTitle,
        // The code carries the key: said here so it isn't posted anywhere.
        message: l10n.householdInviteMessage,
        actions: [
          FilledButton.icon(
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text: _shareCode,
                title: l10n.householdInviteShareSubject,
                subject: l10n.householdInviteShareSubject,
              ),
            ),
            icon: const Icon(Icons.ios_share_outlined, size: Finan2Sizes.iconSm),
            label: Text(l10n.householdInviteShare),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colors.inkSoft,
              textStyle: const TextStyle(
                fontFamily: Finan2Type.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(l10n.householdInviteSkip),
          ),
        ],
        children: [
          // The partner's circle is dashed: someone is missing.
          PartnerCircles(
            initial: initial,
            memberIndex: me.index,
            missingLabel: l10n.householdInviteMissingPartner,
          ),
          const SizedBox(height: Finan2Space.lg),
          Finan2CodeBox(code: _displayCode),
          const SizedBox(height: Finan2Space.sm),
          Text(
            footnote,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.4, color: colors.inkFaint),
          ),
          if (widget.onNewCode != null)
            Center(
              child: TextButton(onPressed: _newCode, child: Text(l10n.householdInviteNewCode)),
            ),
        ],
      ),
    );
  }
}
