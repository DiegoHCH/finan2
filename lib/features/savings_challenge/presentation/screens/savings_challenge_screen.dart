import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_back_head.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/savings_challenge_model.dart';
import '../viewmodels/savings_challenge_providers.dart';

const _basePattern = [2000, 5000, 10000, 20000, 30000, 50000];

const _sizeOptions = {'Chico': 3, 'Mediano': 5, 'Grande': 8};

class SavingsChallengeScreen extends ConsumerStatefulWidget {
  const SavingsChallengeScreen({super.key});

  @override
  ConsumerState<SavingsChallengeScreen> createState() => _SavingsChallengeScreenState();
}

class _SavingsChallengeScreenState extends ConsumerState<SavingsChallengeScreen> {
  final _nameController = TextEditingController(text: 'Reto de ahorro');
  var _rows = 5;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final cells = List<int>.generate(
      _basePattern.length * _rows,
      (i) => _basePattern[i % _basePattern.length],
    );
    final name = _nameController.text.trim();
    await ref
        .read(savingsChallengeControllerProvider.notifier)
        .create(name.isEmpty ? 'Reto de ahorro' : name, cells);
  }

  Future<void> _delete(SavingsChallenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reto de ahorro'),
        content: Text(
          'Se eliminará "${challenge.name}" y el progreso marcado. Esta acción '
          'no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Eliminar',
              style: TextStyle(
                color: Theme.of(context).extension<Finan2Colors>()!.expense,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(savingsChallengeControllerProvider.notifier).delete(challenge.id);
  }

  Future<void> _toggleCell(SavingsChallenge challenge, int index) async {
    final newDone = [...challenge.done];
    while (newDone.length <= index) {
      newDone.add(false);
    }
    newDone[index] = !newDone[index];
    await ref
        .read(savingsChallengeControllerProvider.notifier)
        .toggleCell(challenge.id, newDone);
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
              title: 'Reto de ahorro',
              trailing: challengeAsync.value == null
                  ? null
                  : IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: colors.inkSoft),
                      onPressed: () => _delete(challengeAsync.value!),
                    ),
            ),
            Expanded(
              child: challengeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
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
            'Crea el reto de ahorro del hogar: casillas con montos fijos que van '
            'marcando a medida que las ahorran.',
            style: TextStyle(fontSize: 12.5, color: colors.inkSoft),
          ),
          const SizedBox(height: Finan2Space.lg),
          Finan2Field(label: 'Nombre', controller: _nameController),
          const SizedBox(height: Finan2Space.lg),
          Text('Tamaño', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: Finan2Space.sm),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final entry in _sizeOptions.entries)
                Finan2Chip(
                  label: '${entry.key} (${entry.value * _basePattern.length} casillas)',
                  selected: _rows == entry.value,
                  onTap: () => setState(() => _rows = entry.value),
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
                : const Text('Crear reto'),
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
              colors: [const Color(0xFF9A6817), colors.saving],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Tú puedes! Meta del reto',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                formatMoney(challenge.target),
                style: const TextStyle(
                  color: Colors.white,
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
                  const Text(
                    'Progreso',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
          'Marca cada casilla al ahorrar',
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
                    color: done ? Colors.white : colors.inkSoft,
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
