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

  /// No description provided for @debtsTitle.
  ///
  /// In es, this message translates to:
  /// **'Deudas'**
  String get debtsTitle;

  /// Badge naming the payoff strategy: highest interest rate first.
  ///
  /// In es, this message translates to:
  /// **'Estrategia Avalancha'**
  String get debtsAvalancheStrategy;

  /// No description provided for @debtsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Libres de deudas!'**
  String get debtsEmptyTitle;

  /// No description provided for @debtsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'No tienes deudas registradas. Si adquieres una, agrégala para seguir su pago con la estrategia Avalancha.'**
  String get debtsEmptyDescription;

  /// No description provided for @debtsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Agregar una deuda'**
  String get debtsEmptyAction;

  /// Banner caption; the projected month is shown below it.
  ///
  /// In es, this message translates to:
  /// **'¡Libre de deudas en!'**
  String get debtsFreeDateLabel;

  /// Banner caption when the projection never reaches zero.
  ///
  /// In es, this message translates to:
  /// **'Con los pagos actuales'**
  String get debtsCurrentPaymentsLabel;

  /// No description provided for @debtsCannotPayOff.
  ///
  /// In es, this message translates to:
  /// **'No alcanza a pagar'**
  String get debtsCannotPayOff;

  /// Debt list row. rate is a pre-formatted number, minPayment a formatted amount.
  ///
  /// In es, this message translates to:
  /// **'Tasa {rate}% · mín. {minPayment}/mes'**
  String debtsCardSubtitle(String rate, String minPayment);

  /// No description provided for @debtsPaidAmount.
  ///
  /// In es, this message translates to:
  /// **'Pagado {amount}'**
  String debtsPaidAmount(String amount);

  /// No description provided for @debtsBalanceAmount.
  ///
  /// In es, this message translates to:
  /// **'Saldo {amount}'**
  String debtsBalanceAmount(String amount);

  /// Debt type: credit card.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get debtsTypeCard;

  /// Debt type: consumer loan.
  ///
  /// In es, this message translates to:
  /// **'Crédito'**
  String get debtsTypeLoan;

  /// Debt type.
  ///
  /// In es, this message translates to:
  /// **'Hipoteca'**
  String get debtsTypeMortgage;

  /// Debt type: vehicle loan.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get debtsTypeVehicle;

  /// Lower-case: follows "Tasa X% E.A. · ".
  ///
  /// In es, this message translates to:
  /// **'deuda pagada'**
  String get debtsStatusPaidOff;

  /// Lower-case: follows "Tasa X% E.A. · ". date is a formatted month and year.
  ///
  /// In es, this message translates to:
  /// **'libre en {date}'**
  String debtsStatusFreeBy(String date);

  /// Lower-case: follows "Tasa X% E.A. · ".
  ///
  /// In es, this message translates to:
  /// **'no alcanza a pagar con los abonos actuales'**
  String get debtsStatusCannotPayOff;

  /// E.A. = effective annual rate. status is one of the debtsStatus* texts.
  ///
  /// In es, this message translates to:
  /// **'Tasa {rate}% E.A. · {status}'**
  String debtsRateWithStatus(String rate, String status);

  /// No description provided for @debtsCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get debtsCurrentBalance;

  /// No description provided for @debtsMinPaymentShort.
  ///
  /// In es, this message translates to:
  /// **'Pago mín.'**
  String get debtsMinPaymentShort;

  /// Amount paid on top of the minimum or the installment each month.
  ///
  /// In es, this message translates to:
  /// **'Abono extra'**
  String get debtsExtraPayment;

  /// No description provided for @debtsPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get debtsPaid;

  /// No description provided for @debtsMonthlyInstallment.
  ///
  /// In es, this message translates to:
  /// **'Cuota mensual'**
  String get debtsMonthlyInstallment;

  /// No description provided for @debtsInstallmentsLeft.
  ///
  /// In es, this message translates to:
  /// **'Cuotas restantes'**
  String get debtsInstallmentsLeft;

  /// No description provided for @debtsPaymentSchedule.
  ///
  /// In es, this message translates to:
  /// **'Calendario de pagos'**
  String get debtsPaymentSchedule;

  /// No description provided for @debtsAlreadyPaidOff.
  ///
  /// In es, this message translates to:
  /// **'Esta deuda ya está pagada.'**
  String get debtsAlreadyPaidOff;

  /// No description provided for @debtsNoProjection.
  ///
  /// In es, this message translates to:
  /// **'No hay una proyección disponible.'**
  String get debtsNoProjection;

  /// No description provided for @debtsNextPayment.
  ///
  /// In es, this message translates to:
  /// **'Próximo pago'**
  String get debtsNextPayment;

  /// No description provided for @debtsScheduledPayment.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get debtsScheduledPayment;

  /// Balance left after this scheduled payment.
  ///
  /// In es, this message translates to:
  /// **'Saldo → {amount}'**
  String debtsScheduleBalance(String amount);

  /// No description provided for @debtsNeedAccountFirst.
  ///
  /// In es, this message translates to:
  /// **'Crea una cuenta primero para poder registrar el pago.'**
  String get debtsNeedAccountFirst;

  /// No description provided for @debtsRecordPayment.
  ///
  /// In es, this message translates to:
  /// **'Registrar pago'**
  String get debtsRecordPayment;

  /// Label above the account the card payment comes from.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get debtsPaymentFrom;

  /// No description provided for @debtsRecordedPayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos registrados'**
  String get debtsRecordedPayments;

  /// No description provided for @debtsNoCardPayments.
  ///
  /// In es, this message translates to:
  /// **'Aún no registras pagos a esta tarjeta.'**
  String get debtsNoCardPayments;

  /// No description provided for @debtsDeletedAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta eliminada'**
  String get debtsDeletedAccount;

  /// No description provided for @debtsDeletePayment.
  ///
  /// In es, this message translates to:
  /// **'Eliminar pago'**
  String get debtsDeletePayment;

  /// No description provided for @debtsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva deuda'**
  String get debtsNewTitle;

  /// No description provided for @debtsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar deuda'**
  String get debtsEditTitle;

  /// No description provided for @debtsDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar deuda'**
  String get debtsDelete;

  /// No description provided for @debtsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Los pagos y compras ya registrados se quedan en el historial. Esta acción no se puede deshacer.'**
  String debtsDeleteMessage(String name);

  /// No description provided for @debtsTypeField.
  ///
  /// In es, this message translates to:
  /// **'Tipo de deuda'**
  String get debtsTypeField;

  /// No description provided for @debtsCreditLimit.
  ///
  /// In es, this message translates to:
  /// **'Cupo total'**
  String get debtsCreditLimit;

  /// Effective annual interest rate, in percent.
  ///
  /// In es, this message translates to:
  /// **'Tasa E.A. %'**
  String get debtsRatePercent;

  /// No description provided for @debtsMinPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago mínimo'**
  String get debtsMinPayment;

  /// Day of the month the card statement closes.
  ///
  /// In es, this message translates to:
  /// **'Día de corte'**
  String get debtsCutoffDay;

  /// Day of the month the payment is due.
  ///
  /// In es, this message translates to:
  /// **'Día de pago'**
  String get debtsPaymentDay;

  /// No description provided for @debtsOriginalAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto original'**
  String get debtsOriginalAmount;

  /// Loan term, as a number of monthly installments.
  ///
  /// In es, this message translates to:
  /// **'Plazo (cuotas)'**
  String get debtsTermInstallments;

  /// No description provided for @debtsPaidInstallments.
  ///
  /// In es, this message translates to:
  /// **'Cuotas pagadas'**
  String get debtsPaidInstallments;

  /// No description provided for @savingsGoalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Metas de ahorro'**
  String get savingsGoalsTitle;

  /// No description provided for @savingsGoalsTotalSaved.
  ///
  /// In es, this message translates to:
  /// **'Total ahorrado'**
  String get savingsGoalsTotalSaved;

  /// No description provided for @savingsGoalsTotalSavedRemaining.
  ///
  /// In es, this message translates to:
  /// **'Total ahorrado · falta {amount}'**
  String savingsGoalsTotalSavedRemaining(String amount);

  /// No description provided for @savingsGoalsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes metas'**
  String get savingsGoalsEmptyTitle;

  /// No description provided for @savingsGoalsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea una meta de ahorro para llevarle el pulso con tu pareja.'**
  String get savingsGoalsEmptyDescription;

  /// No description provided for @savingsGoalsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Nueva meta'**
  String get savingsGoalsEmptyAction;

  /// Link to the savings challenge screen.
  ///
  /// In es, this message translates to:
  /// **'Reto de ahorro'**
  String get savingsGoalsChallengeLink;

  /// Lower-case: shown inline when a goal has no target date.
  ///
  /// In es, this message translates to:
  /// **'sin fecha'**
  String get savingsGoalsNoDate;

  /// date is a formatted month and year, or savingsGoalsNoDate.
  ///
  /// In es, this message translates to:
  /// **'Meta {amount} · {date}'**
  String savingsGoalsCardSubtitle(String amount, String date);

  /// No description provided for @savingsGoalsPerMonth.
  ///
  /// In es, this message translates to:
  /// **'{amount}/mes'**
  String savingsGoalsPerMonth(String amount);

  /// No description provided for @savingsGoalsSavedAmount.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado {amount}'**
  String savingsGoalsSavedAmount(String amount);

  /// No description provided for @savingsGoalsSavedRemaining.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado · falta {amount}'**
  String savingsGoalsSavedRemaining(String amount);

  /// No description provided for @savingsGoalsSavedReached.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado · meta cumplida'**
  String get savingsGoalsSavedReached;

  /// One deposit toward a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Aporte'**
  String get savingsGoalsContribution;

  /// No description provided for @savingsGoalsInterestEarned.
  ///
  /// In es, this message translates to:
  /// **'Interés ganado'**
  String get savingsGoalsInterestEarned;

  /// Amount still missing to reach the goal.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get savingsGoalsRemaining;

  /// No description provided for @savingsGoalsProgressOf.
  ///
  /// In es, this message translates to:
  /// **'{percent}% de {amount}'**
  String savingsGoalsProgressOf(int percent, String amount);

  /// Lower-case. date is a formatted month and year.
  ///
  /// In es, this message translates to:
  /// **'meta {date}'**
  String savingsGoalsTargetBy(String date);

  /// No description provided for @savingsGoalsOnTrack.
  ///
  /// In es, this message translates to:
  /// **'a tiempo ✓'**
  String get savingsGoalsOnTrack;

  /// No description provided for @savingsGoalsBehind.
  ///
  /// In es, this message translates to:
  /// **'atrasado'**
  String get savingsGoalsBehind;

  /// No description provided for @savingsGoalsContributions.
  ///
  /// In es, this message translates to:
  /// **'Aportes'**
  String get savingsGoalsContributions;

  /// No description provided for @savingsGoalsNoContributions.
  ///
  /// In es, this message translates to:
  /// **'Aún no registras aportes.'**
  String get savingsGoalsNoContributions;

  /// No description provided for @savingsGoalsNewContribution.
  ///
  /// In es, this message translates to:
  /// **'Nuevo aporte'**
  String get savingsGoalsNewContribution;

  /// Goal total after this contribution.
  ///
  /// In es, this message translates to:
  /// **'Total → {amount}'**
  String savingsGoalsRunningTotal(String amount);

  /// No description provided for @savingsGoalsIconTrip.
  ///
  /// In es, this message translates to:
  /// **'Viaje'**
  String get savingsGoalsIconTrip;

  /// No description provided for @savingsGoalsIconEmergency.
  ///
  /// In es, this message translates to:
  /// **'Emergencia'**
  String get savingsGoalsIconEmergency;

  /// No description provided for @savingsGoalsIconHome.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get savingsGoalsIconHome;

  /// No description provided for @savingsGoalsIconStudy.
  ///
  /// In es, this message translates to:
  /// **'Estudio'**
  String get savingsGoalsIconStudy;

  /// No description provided for @savingsGoalsIconOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get savingsGoalsIconOther;

  /// No description provided for @savingsGoalsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva meta'**
  String get savingsGoalsNewTitle;

  /// No description provided for @savingsGoalsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar meta'**
  String get savingsGoalsEditTitle;

  /// No description provided for @savingsGoalsDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar meta'**
  String get savingsGoalsDelete;

  /// No description provided for @savingsGoalsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\" con todos sus aportes. Esta acción no se puede deshacer.'**
  String savingsGoalsDeleteMessage(String name);

  /// No description provided for @savingsGoalsIconField.
  ///
  /// In es, this message translates to:
  /// **'Ícono'**
  String get savingsGoalsIconField;

  /// Label above the goal amount.
  ///
  /// In es, this message translates to:
  /// **'Meta'**
  String get savingsGoalsTarget;

  /// No description provided for @savingsGoalsMonthlyContribution.
  ///
  /// In es, this message translates to:
  /// **'Aporte mensual'**
  String get savingsGoalsMonthlyContribution;

  /// No description provided for @savingsGoalsTargetDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha meta'**
  String get savingsGoalsTargetDate;

  /// No description provided for @savingsGoalsNoDateValue.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get savingsGoalsNoDateValue;

  /// No description provided for @savingsGoalsClearDate.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha'**
  String get savingsGoalsClearDate;

  /// Amount saved before creating the goal.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo ahorrado'**
  String get savingsGoalsAlreadySaved;

  /// Effective annual interest rate.
  ///
  /// In es, this message translates to:
  /// **'Interés E.A. (opcional)'**
  String get savingsGoalsInterestOptional;

  /// No description provided for @investmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Inversiones'**
  String get investmentsTitle;

  /// No description provided for @investmentsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay inversiones'**
  String get investmentsEmptyTitle;

  /// CDT = certificado de depósito a término (a CD).
  ///
  /// In es, this message translates to:
  /// **'Agrega tu CDT, fondo o cripto para llevarle el pulso a tu portafolio.'**
  String get investmentsEmptyDescription;

  /// No description provided for @investmentsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Nueva inversión'**
  String get investmentsEmptyAction;

  /// No description provided for @investmentsPortfolioValue.
  ///
  /// In es, this message translates to:
  /// **'Valor del portafolio'**
  String get investmentsPortfolioValue;

  /// Follows the bold total return amount; keep the leading space.
  ///
  /// In es, this message translates to:
  /// **' de rendimiento total'**
  String get investmentsTotalReturnSuffix;

  /// No description provided for @investmentsKindFixedIncome.
  ///
  /// In es, this message translates to:
  /// **'Renta fija'**
  String get investmentsKindFixedIncome;

  /// No description provided for @investmentsKindVariableIncome.
  ///
  /// In es, this message translates to:
  /// **'Renta variable'**
  String get investmentsKindVariableIncome;

  /// Investment kind stored as cripto.
  ///
  /// In es, this message translates to:
  /// **'Alto riesgo'**
  String get investmentsKindHighRisk;

  /// E.A. = effective annual rate.
  ///
  /// In es, this message translates to:
  /// **'{kind} · {rate}% E.A.'**
  String investmentsKindWithRate(String kind, String rate);

  /// No description provided for @investmentsCurrentValue.
  ///
  /// In es, this message translates to:
  /// **'Valor actual'**
  String get investmentsCurrentValue;

  /// No description provided for @investmentsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva inversión'**
  String get investmentsNewTitle;

  /// No description provided for @investmentsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar inversión'**
  String get investmentsEditTitle;

  /// No description provided for @investmentsDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar inversión'**
  String get investmentsDelete;

  /// No description provided for @investmentsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Esta acción no se puede deshacer.'**
  String investmentsDeleteMessage(String name);

  /// No description provided for @investmentsKindField.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get investmentsKindField;

  /// No description provided for @investmentsInvested.
  ///
  /// In es, this message translates to:
  /// **'Invertido'**
  String get investmentsInvested;

  /// Effective annual interest rate.
  ///
  /// In es, this message translates to:
  /// **'Tasa E.A.'**
  String get investmentsRate;
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
