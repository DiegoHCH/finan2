import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_async_error_view.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_figure.dart';
import '../../../../core/widgets/finan2_head.dart';
import '../../../../core/widgets/finan2_notice.dart';
import '../../../../core/widgets/finan2_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_challenge_model.dart';
import '../../domain/challenge_progress.dart';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Finan2Head(
              overLabel: context.l10n.coreHomeTabPlan,
              title: switch (challengeAsync.value?.name) {
                final name? when name.isNotEmpty => name,
                _ => context.l10n.savingsChallengeTitle,
              },
              onBack: () => Navigator.of(context).pop(),
              action: challengeAsync.value == null
                  ? null
                  : Finan2HeadAction(
                      icon: Icons.delete_outline,
                      tooltip: context.l10n.savingsChallengeDeleteTitle,
                      onTap: () => _delete(challengeAsync.value!),
                    ),
            ),
            Expanded(
              child: challengeAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Finan2SkeletonList(rows: 3),
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
    final l10n = context.l10n;
    final progress = challengeProgress(challenge.cellAmounts, challenge.done);
    final next = progress.nextIndex;
    final accent = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Finan2Space.lg,
        Finan2Space.xs,
        Finan2Space.lg,
        Finan2Space.xl,
      ),
      children: [
        Finan2Figure(
          label: l10n.challengeSavedIn,
          amountText: formatMoney(progress.saved),
          fontSize: 36,
          subtitle: Text(
            l10n.challengeCells(
              progress.doneCount,
              progress.cellCount,
              formatMoney(progress.target),
            ),
          ),
        ),
        const SizedBox(height: Finan2Space.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: challenge.cellAmounts.length,
          itemBuilder: (context, index) {
            final done = index < challenge.done.length && challenge.done[index];
            final isNext = index == next;
            return Semantics(
              button: true,
              checked: done,
              child: GestureDetector(
                onTap: () => _toggleCell(challenge, index),
                child: Container(
                  decoration: BoxDecoration(
                    color: done ? colors.saving : surface,
                    border: isNext ? Border.all(color: accent, width: 2) : null,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _compactAmount(challenge.cellAmounts[index]),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: done ? surface : (isNext ? accent : colors.inkFaint),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: Finan2Space.lg),
        if (next != null)
          Finan2Notice(
            icon: Icons.savings_outlined,
            title: l10n.challengeNextTitle(formatMoney(challenge.cellAmounts[next])),
            message: l10n.challengeNextMessage,
            actionLabel: l10n.challengeMark,
            onTap: () => _toggleCell(challenge, next),
          )
        else
          Finan2Notice(
            kind: Finan2NoticeKind.calm,
            icon: Icons.savings_outlined,
            title: l10n.challengeDoneTitle,
            message: l10n.challengeDoneMessage(formatMoney(progress.saved)),
          ),
      ],
    );
  }
}

String _compactAmount(int amount) {
  if (amount >= 1000) return '${(amount / 1000).round()}k';
  return '$amount';
}
