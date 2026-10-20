import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/finan2_option_card.dart';
import '../../../l10n/l10n.dart';

/// «Como el teléfono», or the chosen language by its own name.
String appLanguageLabel(AppLocalizations l10n, AppLanguage language) =>
    language.nativeName ?? l10n.settingsLanguageSystem;

/// The sheet to choose the phone's language, Español or English.
Future<void> pickAppLanguage(BuildContext context, WidgetRef ref, AppLanguage current) async {
  await showModalBottomSheet<void>(
    context: context,
    // Three options with a subtitle don't fit the default 9/16 of a short
    // screen: size to the content and scroll if even that doesn't fit.
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Finan2Space.xl, 0, Finan2Space.xl, Finan2Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sheetContext.l10n.settingsLanguage,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: Finan2Space.md),
              for (final language in AppLanguage.values) ...[
                Finan2OptionCard(
                  icon: language == AppLanguage.system
                      ? Icons.smartphone_outlined
                      : Icons.translate_outlined,
                  title: appLanguageLabel(sheetContext.l10n, language),
                  subtitle: language == AppLanguage.system
                      ? sheetContext.l10n.settingsLanguageSystemSubtitle
                      : sheetContext.l10n.settingsLanguageFixedSubtitle,
                  selected: current == language,
                  onTap: () {
                    // Close first: the change rebuilds the whole app.
                    Navigator.of(sheetContext).pop();
                    ref.read(appLanguageControllerProvider.notifier).setLanguage(language);
                  },
                ),
                if (language != AppLanguage.values.last) const SizedBox(height: Finan2Space.sm),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
