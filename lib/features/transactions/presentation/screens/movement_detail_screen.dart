import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/year_month.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../accounts/presentation/viewmodels/account_providers.dart';
import '../../../categories/data/category_model.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../debts/presentation/viewmodels/debt_providers.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../household/presentation/viewmodels/member_providers.dart';
import '../../domain/entities/movement.dart';
import '../viewmodels/transaction_providers.dart';
import 'edit_transaction_screen.dart';

/// «Quién pagó y quién lo anotó»: a movement read back, with both people
/// named. Popping with the movement as the result means "delete it" - the
/// list that opened it offers «Deshacer» (see openMovement).
class MovementDetailScreen extends ConsumerWidget {
  const MovementDetailScreen({required this.movement, super.key});

  final Movement movement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The live copy, so an edit shows up on return.
    final live = ref
        .watch(transactionsOfMonthProvider(yearMonthOf(movement.date)))
        .value
        ?.where((tx) => tx.id == movement.id)
        .firstOrNull;
    final tx = live ?? movement;
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final l10n = context.l10n;
    final formatMoney = ref.watch(moneyFormatterProvider);
    final memberLabel = ref.watch(memberLabelProvider);
    final category = (ref.watch(categoriesProvider).value ?? const <Category>[])
        .where((c) => c.id == tx.categoryId)
        .firstOrNull;
    final account = (ref.watch(accountsProvider).value ?? const [])
        .where((a) => a.id == tx.accountId)
        .firstOrNull;
    final card = (ref.watch(debtsProvider).value ?? const [])
        .where((d) => d.id == tx.cardDebtId)
        .firstOrNull;
    final payer = memberLabel(tx.payer);
    final creator = memberLabel(tx.createdBy);
    final payerTone = Finan2Tone.member(context, payer.index);
    final neutral = Finan2Tone(colors.inkSoft, colors.surfaceAlt);
    final title = tx.description.isNotEmpty ? tx.description : (category?.name ?? '');
    final date = DateFormat.MMMMEEEEd().format(tx.date);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: l10n.transactionsDetailOver,
              title: title,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Finan2Space.xl,
                  Finan2Space.sm,
                  Finan2Space.xl,
                  Finan2Space.xl,
                ),
                children: [
                  Finan2Figure(
                    amountText: formatMoney(tx.amount),
                    amountColor: tx.isIncome ? colors.income : null,
                    subtitle: Text('${tx.type.label} · $date'),
                  ),
                  const SizedBox(height: Finan2Space.lg),
                  Finan2Sheet(
                    children: [
                      _DetailRow(
                        icon: category == null
                            ? Icons.label_outline
                            : Finan2Icons.categoria(category.iconSlug),
                        tone: category == null
                            ? neutral
                            : Finan2Tone.of(context, Color(category.color)),
                        label: l10n.commonCategory,
                        value: category?.name ?? '?',
                      ),
                      _DetailRow(
                        icon: card != null
                            ? Icons.credit_card_outlined
                            : Finan2Icons.cuenta(account?.type.name ?? 'banco'),
                        tone: neutral,
                        label: card != null ? l10n.transactionsCreditCard : l10n.commonAccount,
                        value: card?.name ?? account?.name ?? '?',
                      ),
                      _DetailRow(
                        icon: Icons.person_outline,
                        tone: payerTone,
                        label: tx.isIncome ? l10n.transactionsReceivedBy : l10n.transactionsPaidBy,
                        value: payer.name,
                        valueColor: payerTone.color,
                      ),
                      if (tx.tags.isNotEmpty)
                        _DetailRow(
                          icon: Icons.sell_outlined,
                          tone: neutral,
                          label: l10n.transactionsTags,
                          value: tx.tags.map((t) => '#$t').join(' '),
                        ),
                      _DetailRow(
                        icon: Icons.edit_outlined,
                        tone: neutral,
                        label: l10n.transactionsLoggedBy,
                        value: creator.name,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Finan2Space.xl, 0, Finan2Space.xl, Finan2Space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EditTransactionScreen(transaction: tx),
                      ),
                    ),
                    child: Text(l10n.transactionsEdit),
                  ),
                  const SizedBox(height: Finan2Space.xs),
                  // Far from the thumb, and «Deshacer» is offered after.
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(tx),
                    style: TextButton.styleFrom(foregroundColor: colors.expense),
                    child: Text(l10n.transactionsDelete),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The `.set` row: a tile on its tone, the field's name, its value at the end.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.tone,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final Finan2Tone tone;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: tone.color),
          ),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colors.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
