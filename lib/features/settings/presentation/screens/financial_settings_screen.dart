import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/finan2_app_top.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_list_row.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../categories/presentation/viewmodels/category_providers.dart';
import '../../../household/data/household_model.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../../../l10n/l10n.dart';

// Keys are what the household's settings store; values, their labels.
Map<String, String> _currencies(AppLocalizations l10n) => {
  'COP': l10n.settingsCurrencyCop,
  'USD': l10n.settingsCurrencyUsd,
};

Map<String, String> _weekStarts(AppLocalizations l10n) => {
  'monday': l10n.settingsWeekMonday,
  'sunday': l10n.settingsWeekSunday,
};

class FinancialSettingsScreen extends ConsumerWidget {
  const FinancialSettingsScreen({required this.household, super.key});

  final Household household;

  Future<void> _saveSettings(
    BuildContext context,
    WidgetRef ref, {
    String? currency,
    int? startYear,
    String? weekStartsOn,
  }) async {
    try {
      await ref
          .read(householdControllerProvider.notifier)
          .updateSettings(
            household.id,
            currency: currency,
            startYear: startYear,
            weekStartsOn: weekStartsOn,
          );
    } catch (error) {
      if (!context.mounted) return;
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(error));
    }
  }

  Future<void> _pickFromOptions(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, String> options,
    required String current,
    required void Function(String value) onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in options.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _pickYear(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(household.startYear),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
      helpText: context.l10n.settingsPickActiveYear,
    );
    if (picked != null && context.mounted) {
      await _saveSettings(context, ref, startYear: picked.year);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryCount = ref.watch(categoriesProvider).value?.length ?? 0;
    final l10n = context.l10n;
    final currencies = _currencies(l10n);
    final weekStarts = _weekStarts(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Finan2AppTop(
              label: l10n.settingsFinancialSettings,
              title: l10n.settingsFinancialSettingsSubtitle,
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Finan2Space.xl),
                children: [
                  Finan2ListCard(
                    children: [
                      Finan2ListRow(
                        icon: Finan2Icons.moneda,
                        label: l10n.settingsCurrency,
                        value: currencies[household.currency] ?? household.currency,
                        onTap: () => _pickFromOptions(
                          context,
                          ref,
                          options: currencies,
                          current: household.currency,
                          onSelected: (value) => _saveSettings(context, ref, currency: value),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.anio,
                        label: l10n.settingsActiveYear,
                        value: '${household.startYear}',
                        onTap: () => _pickYear(context, ref),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.semana,
                        label: l10n.settingsWeekStartsOn,
                        value: weekStarts[household.weekStartsOn] ?? household.weekStartsOn,
                        onTap: () => _pickFromOptions(
                          context,
                          ref,
                          options: weekStarts,
                          current: household.weekStartsOn,
                          onSelected: (value) => _saveSettings(context, ref, weekStartsOn: value),
                        ),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.categorias,
                        label: l10n.settingsCategories,
                        value: '$categoryCount',
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const CategoriesScreen())),
                      ),
                      Finan2ListRow(
                        icon: Finan2Icons.cuentas,
                        label: l10n.settingsAccounts,
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const AccountsScreen())),
                      ),
                    ],
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
