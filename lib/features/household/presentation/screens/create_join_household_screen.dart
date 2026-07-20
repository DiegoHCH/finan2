import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_centered_form.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_logo_tile.dart';
import '../../../../core/widgets/finan2_option_card.dart';
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
        householdName: toTitleCase(_householdNameController.text),
      );
      // ref.read must come after the mounted check - reading it first (as in
      // `ref.read(...) && mounted`) still evaluates ref.read() even when the
      // widget was unmounted during the await above, which throws.
      if (!mounted) return;
      final state = ref.read(householdControllerProvider);
      final household = state.value;
      final shareCode = controller.lastShareCode ?? household?.inviteCode;
      if (household != null && shareCode != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InviteHouseholdScreen(shareCode: shareCode),
          ),
        );
      }
    } else {
      await controller.joinHousehold(code: _codeController.text.trim());
      if (controller.joinedWithoutKey && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Te uniste al hogar, pero este código no traía la llave para '
              'ver montos. Pide a tu pareja el código completo que copió al '
              'crear el hogar.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdControllerProvider);
    ref.listen<AsyncValue<dynamic>>(householdControllerProvider,
        (previous, next) {
      if (next.hasError && !next.isLoading) {
        showFinan2ErrorSheet(context, message: friendlyErrorMessage(next.error));
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
                const Finan2LogoTile(),
                const SizedBox(height: Finan2Space.lg),
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
                    label: 'Código del hogar (pega el código completo)',
                    controller: _codeController,
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
