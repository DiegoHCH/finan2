import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/finan2_centered_form.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_option_card.dart';
import '../../data/household_repository.dart';
import '../viewmodels/household_providers.dart';
import 'invite_household_screen.dart';

enum _HouseholdChoice { create, join }

/// The step right after signing up/in for the first time: create a new
/// household, or join the one your partner already created.
class CreateJoinHouseholdScreen extends ConsumerStatefulWidget {
  const CreateJoinHouseholdScreen({super.key});

  @override
  ConsumerState<CreateJoinHouseholdScreen> createState() =>
      _CreateJoinHouseholdScreenState();
}

class _CreateJoinHouseholdScreenState
    extends ConsumerState<CreateJoinHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _householdNameController = TextEditingController(text: 'Nuestro hogar');
  final _codeController = TextEditingController();
  var _choice = _HouseholdChoice.create;

  @override
  void dispose() {
    _householdNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(householdControllerProvider.notifier);
    if (_choice == _HouseholdChoice.create) {
      await controller.createHousehold(
        householdName: _householdNameController.text.trim(),
      );
      final state = ref.read(householdControllerProvider);
      final household = state.value;
      if (household != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InviteHouseholdScreen(
              inviteCode: household.inviteCode,
            ),
          ),
        );
      }
    } else {
      await controller.joinHousehold(code: _codeController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdControllerProvider);
    ref.listen<AsyncValue<dynamic>>(householdControllerProvider,
        (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_householdErrorMessage(next.error))),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl),
          child: Form(
            key: _formKey,
            child: Finan2CenteredForm(
              children: [
                Text(
                  'Un último paso',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: Finan2Space.xs),
                Text(
                  'Crea el hogar desde cero o únete al que ya tiene tu pareja.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Finan2Space.lg),
                Finan2OptionCard(
                  icon: Icons.home_work_outlined,
                  title: 'Crear un hogar nuevo',
                  subtitle: 'Empiezas de cero e invitas a tu pareja.',
                  selected: _choice == _HouseholdChoice.create,
                  onTap: () =>
                      setState(() => _choice = _HouseholdChoice.create),
                ),
                const SizedBox(height: Finan2Space.sm),
                Finan2OptionCard(
                  icon: Icons.vpn_key_outlined,
                  title: 'Unirme con un código',
                  subtitle: 'Tu pareja ya creó el hogar.',
                  selected: _choice == _HouseholdChoice.join,
                  onTap: () =>
                      setState(() => _choice = _HouseholdChoice.join),
                ),
                const SizedBox(height: Finan2Space.lg),
                if (_choice == _HouseholdChoice.create)
                  Finan2Field(
                    label: 'Nombre del hogar',
                    controller: _householdNameController,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Ponle un nombre a tu hogar'
                            : null,
                  )
                else
                  Finan2Field(
                    label: 'Código del hogar',
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Ingresa el código que te compartieron'
                        : null,
                  ),
                const SizedBox(height: Finan2Space.lg),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _choice == _HouseholdChoice.create
                              ? 'Crear hogar'
                              : 'Entrar al hogar',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _householdErrorMessage(Object? error) {
  if (error is HouseholdNotFoundException) {
    return 'No encontramos un hogar con ese código.';
  }
  if (error is HouseholdFullException) {
    return 'Ese hogar ya tiene 2 miembros.';
  }
  return 'Algo salió mal, intenta de nuevo.';
}
