import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_option_card.dart';
import '../../../../core/widgets/finan2_prompt_page.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/household_providers.dart';

enum _HouseholdChoice { create, join }

/// The step right after signing up/in for the first time: create a new
/// household, or join the one your partner already created.
class CreateJoinHouseholdScreen extends ConsumerStatefulWidget {
  const CreateJoinHouseholdScreen({super.key});

  @override
  ConsumerState<CreateJoinHouseholdScreen> createState() => _CreateJoinHouseholdScreenState();
}

class _CreateJoinHouseholdScreenState extends ConsumerState<CreateJoinHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  // Prefilled in didChangeDependencies, once there's a context to localize
  // the suggested name with.
  final _householdNameController = TextEditingController();
  var _prefilled = false;
  final _codeController = TextEditingController();
  var _choice = _HouseholdChoice.create;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    _householdNameController.text = context.l10n.householdDefaultName;
  }

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
      // The home screen takes over from here - see householdSetupProvider.
      await controller.createHousehold(householdName: toTitleCase(_householdNameController.text));
    } else {
      await controller.joinHousehold(code: _codeController.text.trim());
      if (controller.joinedWithoutKey && mounted) {
        await showFinan2InfoSheet(
          context,
          title: context.l10n.householdJoinedWithoutKeyTitle,
          message: context.l10n.householdJoinedWithoutKeyMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdControllerProvider);
    ref.listen<AsyncValue<dynamic>>(householdControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        showFinan2ErrorSheet(context, message: friendlyErrorMessage(next.error));
      }
    });

    final l10n = context.l10n;
    final creating = _choice == _HouseholdChoice.create;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Finan2PromptPage(
          title: l10n.householdCreateJoinTitle,
          message: l10n.householdCreateJoinSubtitle,
          actions: [
            FilledButton(
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(creating ? l10n.householdCreateButton : l10n.householdJoinButton),
            ),
          ],
          children: [
            Finan2OptionCard(
              icon: Finan2Icons.hogar,
              title: l10n.householdCreateOptionTitle,
              subtitle: l10n.householdCreateOptionSubtitle,
              selected: creating,
              onTap: () => setState(() => _choice = _HouseholdChoice.create),
            ),
            const SizedBox(height: Finan2Space.sm),
            Finan2OptionCard(
              icon: Finan2Icons.codigo,
              title: l10n.householdJoinOptionTitle,
              subtitle: l10n.householdJoinOptionSubtitle,
              selected: !creating,
              onTap: () => setState(() => _choice = _HouseholdChoice.join),
            ),
            const SizedBox(height: Finan2Space.lg),
            if (creating)
              Finan2Field(
                key: const ValueKey('householdName'),
                label: l10n.householdNameLabel,
                controller: _householdNameController,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.householdNameRequired : null,
              )
            else
              // Monospaced: it has to be copied exactly, and that way the O
              // doesn't pass for a 0.
              Finan2Field(
                key: const ValueKey('householdCode'),
                label: l10n.householdCodeLabel,
                controller: _codeController,
                monospace: true,
                hint: l10n.householdCodeHint,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.householdCodeRequired : null,
              ),
          ],
        ),
      ),
    );
  }
}
