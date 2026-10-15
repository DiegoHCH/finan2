import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es')];

  /// App name, shown by the OS in the task switcher.
  ///
  /// In es, this message translates to:
  /// **'Finan2'**
  String get appTitle;

  /// Shared labels (common*) are reused by every feature: buttons, field labels.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get commonSkip;

  /// No description provided for @commonUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get commonUndo;

  /// No description provided for @commonCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get commonCopy;

  /// No description provided for @commonGotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get commonGotIt;

  /// No description provided for @commonNotNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get commonNotNow;

  /// No description provided for @commonName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get commonName;

  /// No description provided for @commonAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get commonAmount;

  /// No description provided for @commonDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get commonDate;

  /// No description provided for @commonDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get commonDescription;

  /// No description provided for @commonCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get commonCategory;

  /// No description provided for @commonAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get commonAccount;

  /// No description provided for @budgetTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto · {month}'**
  String budgetTitle(String month);

  /// Header title: total amount budgeted for the month, already formatted.
  ///
  /// In es, this message translates to:
  /// **'{amount} planeado'**
  String budgetPlannedTotal(String amount);

  /// Badge: share of the month's income already budgeted.
  ///
  /// In es, this message translates to:
  /// **'{pct}% asignado'**
  String budgetAssignedPct(int pct);

  /// No description provided for @budgetPreviousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get budgetPreviousMonth;

  /// No description provided for @budgetNextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get budgetNextMonth;

  /// No description provided for @budgetLeftToBudget.
  ///
  /// In es, this message translates to:
  /// **'Falta por presupuestar'**
  String get budgetLeftToBudget;

  /// Shown instead of an amount when the month has no income to budget yet.
  ///
  /// In es, this message translates to:
  /// **'Registra ingresos este mes'**
  String get budgetNoIncomeYet;

  /// No description provided for @budgetOverBudgeted.
  ///
  /// In es, this message translates to:
  /// **'Presupuestado de más'**
  String get budgetOverBudgeted;

  /// No description provided for @budgetVsActual.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto vs. real'**
  String get budgetVsActual;

  /// No description provided for @budgetEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has presupuestado ninguna categoría.'**
  String get budgetEmpty;

  /// No description provided for @budgetAddCategory.
  ///
  /// In es, this message translates to:
  /// **'+ Presupuestar otra categoría'**
  String get budgetAddCategory;

  /// No description provided for @budgetForCategory.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto para {category}'**
  String budgetForCategory(String category);

  /// No description provided for @budgetCopyTitle.
  ///
  /// In es, this message translates to:
  /// **'Este mes aún no tiene presupuesto'**
  String get budgetCopyTitle;

  /// No description provided for @budgetCopyMessage.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Copia la categoría que planeaste en {month}.} other{Copia las {count} categorías que planeaste en {month}.}}'**
  String budgetCopyMessage(int count, String month);

  /// No description provided for @budgetCopying.
  ///
  /// In es, this message translates to:
  /// **'Copiando…'**
  String get budgetCopying;

  /// Budget carried over from earlier months that went underspent.
  ///
  /// In es, this message translates to:
  /// **'Incluye {amount} que sobró antes'**
  String budgetCarryIncluded(String amount);

  /// Overspending from earlier months taken off this month's limit.
  ///
  /// In es, this message translates to:
  /// **'Descuenta {amount} que te pasaste antes'**
  String budgetCarryDeducted(String amount);

  /// No description provided for @annualSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen anual'**
  String get annualSummaryTitle;

  /// No description provided for @annualSummaryPreviousYear.
  ///
  /// In es, this message translates to:
  /// **'Año anterior'**
  String get annualSummaryPreviousYear;

  /// No description provided for @annualSummaryNextYear.
  ///
  /// In es, this message translates to:
  /// **'Año siguiente'**
  String get annualSummaryNextYear;

  /// No description provided for @annualSummaryEarned.
  ///
  /// In es, this message translates to:
  /// **'Ganado'**
  String get annualSummaryEarned;

  /// No description provided for @annualSummarySpent.
  ///
  /// In es, this message translates to:
  /// **'Gastado'**
  String get annualSummarySpent;

  /// No description provided for @annualSummarySaved.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado'**
  String get annualSummarySaved;

  /// No description provided for @annualSummarySpendByMonth.
  ///
  /// In es, this message translates to:
  /// **'Gasto por mes'**
  String get annualSummarySpendByMonth;

  /// No description provided for @dashboardHousehold.
  ///
  /// In es, this message translates to:
  /// **'Hogar'**
  String get dashboardHousehold;

  /// No description provided for @dashboardNetWorth.
  ///
  /// In es, this message translates to:
  /// **'Patrimonio neto'**
  String get dashboardNetWorth;

  /// No description provided for @dashboardNetWorthFormula.
  ///
  /// In es, this message translates to:
  /// **'Cuentas + ahorros + inversiones − deudas'**
  String get dashboardNetWorthFormula;

  /// No description provided for @dashboardIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get dashboardIncome;

  /// No description provided for @dashboardExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get dashboardExpenses;

  /// No description provided for @dashboardWhereMoneyGoes.
  ///
  /// In es, this message translates to:
  /// **'A dónde va el dinero'**
  String get dashboardWhereMoneyGoes;

  /// No description provided for @dashboardNoCategorizedSpending.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos categorizados este mes.'**
  String get dashboardNoCategorizedSpending;

  /// Screen title, and the default name of a new challenge.
  ///
  /// In es, this message translates to:
  /// **'Reto de ahorro'**
  String get savingsChallengeTitle;

  /// No description provided for @savingsChallengeDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar reto de ahorro'**
  String get savingsChallengeDeleteTitle;

  /// No description provided for @savingsChallengeDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\" y el progreso marcado. Esta acción no se puede deshacer.'**
  String savingsChallengeDeleteMessage(String name);

  /// No description provided for @savingsChallengeIntro.
  ///
  /// In es, this message translates to:
  /// **'Crea el reto de ahorro del hogar: casillas con montos fijos que van marcando a medida que las ahorran.'**
  String get savingsChallengeIntro;

  /// No description provided for @savingsChallengeSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get savingsChallengeSize;

  /// No description provided for @savingsChallengeSizeSmall.
  ///
  /// In es, this message translates to:
  /// **'Chico'**
  String get savingsChallengeSizeSmall;

  /// No description provided for @savingsChallengeSizeMedium.
  ///
  /// In es, this message translates to:
  /// **'Mediano'**
  String get savingsChallengeSizeMedium;

  /// No description provided for @savingsChallengeSizeLarge.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get savingsChallengeSizeLarge;

  /// Size chip: size name and how many boxes the challenge will have.
  ///
  /// In es, this message translates to:
  /// **'{size} ({count, plural, =1{1 casilla} other{{count} casillas}})'**
  String savingsChallengeSizeOption(String size, int count);

  /// No description provided for @savingsChallengeCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear reto'**
  String get savingsChallengeCreate;

  /// No description provided for @savingsChallengeGoal.
  ///
  /// In es, this message translates to:
  /// **'¡Tú puedes! Meta del reto'**
  String get savingsChallengeGoal;

  /// No description provided for @savingsChallengeProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get savingsChallengeProgress;

  /// No description provided for @savingsChallengeMarkHint.
  ///
  /// In es, this message translates to:
  /// **'Marca cada casilla al ahorrar'**
  String get savingsChallengeMarkHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
