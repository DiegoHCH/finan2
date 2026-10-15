import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_challenge_model.dart';
import '../viewmodels/savings_challenge_providers.dart';

const _basePattern = [2000, 5000, 10000, 20000, 30000, 50000];

/// How many rows of [_basePattern] a new challenge gets.
enum _ChallengeSize {
  small(3),
  medium(5),
  large(8);

  const _ChallengeSize(this.rows);

  final int rows;

  String label(AppLocalizations l10n) => switch (this) {
    small => l10n.savingsChallengeSizeSmall,
    medium => l10n.savingsChallengeSizeMedium,
    large => l10n.savingsChallengeSizeLarge,
  };
}

class SavingsChallengeScreen extends ConsumerStatefulWidget {
  const SavingsChallengeScreen({super.key});

  @override
  ConsumerState<SavingsChallengeScreen> createState() => _SavingsChallengeScreenState();
}

class _SavingsChallengeScreenState extends ConsumerState<SavingsChallengeScreen> {
  final _nameController = TextEditingController();
  var _nameSeeded = false;
  var _size = _ChallengeSize.medium;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The default name needs the locale, which initState can't read yet.
    if (!_nameSeeded) {
      _nameController.text = context.l10n.savingsChallengeTitle;
      _nameSeeded = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final cells = List<int>.generate(
      _basePattern.length * _size.rows,
      (i) => _basePattern[i % _basePattern.length],
    );
    final name = toTitleCase(_nameController.text);
    await ref
        .read(savingsChallengeControllerProvider.notifier)
        .create(name.isEmpty ? context.l10n.savingsChallengeTitle : name, cells);
  }

  Future<void> _delete(SavingsChallenge challenge) async {
    final confirmed = await showFinan2ConfirmSheet(
      context,
      title: context.l10n.savingsChallengeDeleteTitle,
      message: context.l10n.savingsChallengeDeleteMessage(
        challenge.name.isEmpty ? context.l10n.savingsChallengeTitle : challenge.name,
      ),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(savingsChallengeControllerProvider.notifier).delete(challenge.id);
  }

  Future<void> _toggleCell(SavingsChallenge challenge, int index) async {
    final newDone = [...challenge.done];
    while (newDone.length <= index) {
      newDone.add(false);
    }
    newDone[index] = !newDone[index];
    await ref.read(savingsChallengeControllerProvider.notifier).toggleCell(challenge.id, newDone);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final challengeAsync = ref.watch(savingsChallengeProvider);
    final formatMoney = ref.watch(moneyFormatterProvider);
    final creating = ref.watch(savingsChallengeControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2BackHead(
              title: context.l10n.savingsChallengeTitle,
              trailing: challengeAsync.value == null
                  ? null
                  : IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: colors.inkSoft),
                      tooltip: context.l10n.savingsChallengeDeleteTitle,
                      onPressed: () => _delete(challengeAsync.value!),
                    ),
            ),
            Expanded(
              child: challengeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Finan2AsyncErrorView(error: error),
                data: (challenge) {
                  if (challenge == null) {
                    return _buildCreateForm(context, colors, creating);
                  }
                  return _buildChallenge(context, colors, challenge, formatMoney);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm(BuildContext context, Finan2Colors colors, bool creating) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Finan2Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.savingsChallengeIntro,
            style: TextStyle(fontSize: 12.5, color: colors.inkSoft),
          ),
          const SizedBox(height: Finan2Space.lg),
          Finan2Field(label: context.l10n.commonName, controller: _nameController),
          const SizedBox(height: Finan2Space.lg),
          Text(context.l10n.savingsChallengeSize, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: Finan2Space.sm),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final size in _ChallengeSize.values)
                Finan2Chip(
                  label: context.l10n.savingsChallengeSizeOption(
                    size.label(context.l10n),
                    size.rows * _basePattern.length,
                  ),
                  selected: _size == size,
                  onTap: () => setState(() => _size = size),
                ),
            ],
          ),
          const SizedBox(height: Finan2Space.lg),
          FilledButton(
            onPressed: creating ? null : _create,
            child: creating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.savingsChallengeCreate),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenge(
    BuildContext context,
    Finan2Colors colors,
    SavingsChallenge challenge,
    String Function(num) formatMoney,
  ) {
    return ListView(
      padding: const EdgeInsets.all(Finan2Space.xl),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.goalStart, colors.goalEnd],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.savingsChallengeGoal,
                style: TextStyle(color: colors.onHero, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                formatMoney(challenge.target),
                style: TextStyle(
                  color: colors.onHero,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Finan2Space.lg),
        Container(
          padding: const EdgeInsets.all(Finan2Space.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(Finan2Radius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.savingsChallengeProgress,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: formatMoney(challenge.saved),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: ' / ${formatMoney(challenge.target)}',
                              style: TextStyle(fontWeight: FontWeight.w600, color: colors.inkFaint),
                            ),
                          ],
                        ),
                        style: TextStyle(fontSize: 12.5, color: colors.ink),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: challenge.fraction,
                  minHeight: 9,
                  backgroundColor: colors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation(colors.saving),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Finan2Space.lg),
        Text(
          context.l10n.savingsChallengeMarkHint,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: colors.inkFaint,
          ),
        ),
        const SizedBox(height: Finan2Space.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 1,
          ),
          itemCount: challenge.cellAmounts.length,
          itemBuilder: (context, index) {
            final done = index < challenge.done.length && challenge.done[index];
            final brand = Theme.of(context).colorScheme.primary;
            return GestureDetector(
              onTap: () => _toggleCell(challenge, index),
              child: Container(
                decoration: BoxDecoration(
                  color: done ? brand : Theme.of(context).colorScheme.surface,
                  border: Border.all(color: done ? brand : colors.line),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  _compactAmount(challenge.cellAmounts[index]),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: done ? colors.onAccent : colors.inkSoft,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

String _compactAmount(int amount) {
  if (amount >= 1000) return '${(amount / 1000).round()}k';
  return '$amount';
}
