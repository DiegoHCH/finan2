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

  /// Login heading; a highlighted "2" follows it, completing the app name Finan2.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Finan'**
  String get authLoginWelcome;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entra con tu cuenta. Cada quien tiene la suya; las finanzas del hogar son compartidas.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get authEmailLabel;

  /// No description provided for @authEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get authPasswordRequired;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authSignIn;

  /// Separator between email sign-in and Google sign-in.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get authOr;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authContinueWithGoogle;

  /// Followed by the authCreateAccountHere link; keep the trailing space.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccountHere.
  ///
  /// In es, this message translates to:
  /// **'Créala aquí'**
  String get authCreateAccountHere;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordMessage.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un enlace a tu correo para elegir una contraseña nueva.'**
  String get authResetPasswordMessage;

  /// No description provided for @authResetPasswordSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get authResetPasswordSend;

  /// No description provided for @authResetPasswordSentTitle.
  ///
  /// In es, this message translates to:
  /// **'Correo enviado'**
  String get authResetPasswordSentTitle;

  /// No description provided for @authResetPasswordSentMessage.
  ///
  /// In es, this message translates to:
  /// **'Si {email} tiene una cuenta, te llegará un correo para recuperarla.'**
  String authResetPasswordSentMessage(String email);

  /// No description provided for @authSignupTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Regístrate para empezar a organizar las finanzas del hogar.'**
  String get authSignupSubtitle;

  /// No description provided for @authNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get authNameRequired;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordsDontMatch;

  /// Sign-up button: creates the user's login account.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// Followed by the authSignInLink link; keep the trailing space.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get authHaveAccount;

  /// No description provided for @authSignInLink.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get authSignInLink;

  /// Prefilled, editable name when creating a household.
  ///
  /// In es, this message translates to:
  /// **'Nuestro hogar'**
  String get householdDefaultName;

  /// No description provided for @householdCreateJoinTitle.
  ///
  /// In es, this message translates to:
  /// **'Un último paso'**
  String get householdCreateJoinTitle;

  /// No description provided for @householdCreateJoinSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea el hogar desde cero o únete al que ya tiene tu pareja.'**
  String get householdCreateJoinSubtitle;

  /// No description provided for @householdCreateOptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear un hogar nuevo'**
  String get householdCreateOptionTitle;

  /// No description provided for @householdCreateOptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Empiezas de cero e invitas a tu pareja.'**
  String get householdCreateOptionSubtitle;

  /// No description provided for @householdJoinOptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Unirme con un código'**
  String get householdJoinOptionTitle;

  /// No description provided for @householdJoinOptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja ya creó el hogar.'**
  String get householdJoinOptionSubtitle;

  /// No description provided for @householdNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del hogar'**
  String get householdNameLabel;

  /// No description provided for @householdNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre a tu hogar'**
  String get householdNameRequired;

  /// No description provided for @householdCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código del hogar (pega el código completo)'**
  String get householdCodeLabel;

  /// No description provided for @householdCodeRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código que te compartieron'**
  String get householdCodeRequired;

  /// No description provided for @householdCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear hogar'**
  String get householdCreateButton;

  /// No description provided for @householdJoinButton.
  ///
  /// In es, this message translates to:
  /// **'Entrar al hogar'**
  String get householdJoinButton;

  /// No description provided for @householdJoinedWithoutKeyTitle.
  ///
  /// In es, this message translates to:
  /// **'Te uniste al hogar'**
  String get householdJoinedWithoutKeyTitle;

  /// No description provided for @householdJoinedWithoutKeyMessage.
  ///
  /// In es, this message translates to:
  /// **'Este código no traía la llave para ver montos. Pide a tu pareja que te comparta el código completo desde la tarjeta del hogar en Ajustes.'**
  String get householdJoinedWithoutKeyMessage;

  /// No description provided for @householdSetupStep.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de {total}'**
  String householdSetupStep(int step, int total);

  /// No description provided for @householdSetupCurrencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Moneda del hogar'**
  String get householdSetupCurrencyTitle;

  /// No description provided for @householdSetupCurrencyDescription.
  ///
  /// In es, this message translates to:
  /// **'En la que llevan las cuentas. Se puede cambiar en Ajustes.'**
  String get householdSetupCurrencyDescription;

  /// No description provided for @householdCurrencyCop.
  ///
  /// In es, this message translates to:
  /// **'Peso colombiano'**
  String get householdCurrencyCop;

  /// No description provided for @householdCurrencyUsd.
  ///
  /// In es, this message translates to:
  /// **'Dólar estadounidense'**
  String get householdCurrencyUsd;

  /// A money account (bank, wallet, cash), not a login.
  ///
  /// In es, this message translates to:
  /// **'Tu primera cuenta'**
  String get householdSetupAccountTitle;

  /// No description provided for @householdSetupAccountDescription.
  ///
  /// In es, this message translates to:
  /// **'De donde sale y a donde llega la plata: el banco, una billetera o el efectivo. Pon lo que tiene hoy para empezar con el saldo real.'**
  String get householdSetupAccountDescription;

  /// No description provided for @householdSetupAccountNameMissingTitle.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre'**
  String get householdSetupAccountNameMissingTitle;

  /// No description provided for @householdSetupAccountNameMissingMessage.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo el banco o «Efectivo». Si prefieres, omite este paso.'**
  String get householdSetupAccountNameMissingMessage;

  /// No description provided for @householdSetupBalanceToday.
  ///
  /// In es, this message translates to:
  /// **'Saldo de hoy'**
  String get householdSetupBalanceToday;

  /// Creates a money account (bank, wallet, cash), not a login.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get householdSetupCreateAccount;

  /// No description provided for @householdRecoveryPhraseTitle.
  ///
  /// In es, this message translates to:
  /// **'Frase de recuperación'**
  String get householdRecoveryPhraseTitle;

  /// No description provided for @householdSetupRecoveryDescription.
  ///
  /// In es, this message translates to:
  /// **'Los montos se cifran con una llave que vive solo en sus teléfonos. Si los dos la pierden, estas 12 palabras la recuperan. Se muestran una sola vez: anótalas en papel y guárdalas con tu pareja.'**
  String get householdSetupRecoveryDescription;

  /// No description provided for @householdGeneratePhrase.
  ///
  /// In es, this message translates to:
  /// **'Generar frase'**
  String get householdGeneratePhrase;

  /// No description provided for @householdSetupLater.
  ///
  /// In es, this message translates to:
  /// **'Más tarde, desde Ajustes'**
  String get householdSetupLater;

  /// No description provided for @householdInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Invita a tu pareja'**
  String get householdInviteTitle;

  /// No description provided for @householdInviteMessage.
  ///
  /// In es, this message translates to:
  /// **'Comparte este código para que entre con su propia cuenta al mismo hogar. Sirve una sola vez y vence en 7 días.'**
  String get householdInviteMessage;

  /// No description provided for @householdInviteWarning.
  ///
  /// In es, this message translates to:
  /// **'Usa el botón de compartir y envíalo por WhatsApp o mensaje - no lo dictes de viva voz, lleva pegada una llave más larga que no se ve aquí. Sin el código completo, tu pareja no podrá ver los montos.'**
  String get householdInviteWarning;

  /// Title/subject of the OS share sheet when sharing the invite.
  ///
  /// In es, this message translates to:
  /// **'Invitación a nuestro hogar en Finan2'**
  String get householdInviteShareSubject;

  /// No description provided for @householdInviteShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir invitación'**
  String get householdInviteShare;

  /// No description provided for @householdInviteSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir por ahora'**
  String get householdInviteSkip;

  /// No description provided for @householdRecoveryConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Si algún día ninguno de los dos tiene la llave del hogar en su dispositivo, estas 12 palabras permiten recuperar los montos. Vas a verlas una sola vez: anótalas en papel y guárdalas con tu pareja. Si ya había una frase o un PIN, dejarán de servir.'**
  String get householdRecoveryConfirmMessage;

  /// No description provided for @householdRecoverySavedTitle.
  ///
  /// In es, this message translates to:
  /// **'Frase guardada'**
  String get householdRecoverySavedTitle;

  /// No description provided for @householdRecoverySavedMessage.
  ///
  /// In es, this message translates to:
  /// **'Desde ahora esta frase permite recuperar los montos del hogar en cualquier dispositivo.'**
  String get householdRecoverySavedMessage;

  /// {error} is an already-translated error message.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la frase nueva, así que no sirve: la anterior sigue siendo la válida. {error}'**
  String householdRecoverySaveFailed(String error);

  /// No description provided for @householdRecoveryShowTitle.
  ///
  /// In es, this message translates to:
  /// **'Anota estas 12 palabras'**
  String get householdRecoveryShowTitle;

  /// No description provided for @householdRecoveryShowMessage.
  ///
  /// In es, this message translates to:
  /// **'En este orden. No se vuelven a mostrar y Finan2 no las guarda.'**
  String get householdRecoveryShowMessage;

  /// No description provided for @householdRecoveryShowDone.
  ///
  /// In es, this message translates to:
  /// **'Ya las anoté'**
  String get householdRecoveryShowDone;

  /// No description provided for @householdKeyIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Ese código no trae la llave completa. Pide a tu pareja que lo comparta de nuevo desde la tarjeta del hogar en Ajustes.'**
  String get householdKeyIncomplete;

  /// No description provided for @householdKeyWrongHousehold.
  ///
  /// In es, this message translates to:
  /// **'Esa llave no es de este hogar. Revisa que el código sea el que tu pareja compartió desde este mismo hogar.'**
  String get householdKeyWrongHousehold;

  /// No description provided for @householdRecoveryNotSet.
  ///
  /// In es, this message translates to:
  /// **'Este hogar no tiene una frase de recuperación configurada.'**
  String get householdRecoveryNotSet;

  /// No description provided for @householdRecoveryPhraseMismatch.
  ///
  /// In es, this message translates to:
  /// **'Esa frase no corresponde a este hogar. Si tu pareja generó una nueva, la anterior dejó de servir.'**
  String get householdRecoveryPhraseMismatch;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// Large title under the small settingsTitle label.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsHeading;

  /// No description provided for @settingsMissingKeyBanner.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no tiene la llave para ver los montos de este hogar. Pega el código que tu pareja compartió desde su tarjeta del hogar, o escribe la frase de recuperación.'**
  String get settingsMissingKeyBanner;

  /// No description provided for @settingsPasteCodeToUnlock.
  ///
  /// In es, this message translates to:
  /// **'Pegar código para desbloquear montos'**
  String get settingsPasteCodeToUnlock;

  /// No description provided for @settingsUseRecoveryPhrase.
  ///
  /// In es, this message translates to:
  /// **'Usar frase de recuperación'**
  String get settingsUseRecoveryPhrase;

  /// No description provided for @settingsStorageWarning.
  ///
  /// In es, this message translates to:
  /// **'Tu navegador no garantizó que los datos de Finan2 se conserven. Si no abres la app por varios días, podrías perder el acceso a los montos cifrados de este dispositivo. Asegúrate de tener una frase de recuperación en Ajustes de la cuenta.'**
  String get settingsStorageWarning;

  /// No description provided for @settingsMemberCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 miembro} other{{count} miembros}}'**
  String settingsMemberCount(int count);

  /// No description provided for @settingsTapToInvite.
  ///
  /// In es, this message translates to:
  /// **'toca para invitar'**
  String get settingsTapToInvite;

  /// No description provided for @settingsTapToShareKey.
  ///
  /// In es, this message translates to:
  /// **'toca para compartir la llave'**
  String get settingsTapToShareKey;

  /// No description provided for @settingsFinancialSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes financieros'**
  String get settingsFinancialSettings;

  /// No description provided for @settingsFinancialSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Moneda, año y categorías'**
  String get settingsFinancialSettingsSubtitle;

  /// No description provided for @settingsAccountSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de la cuenta'**
  String get settingsAccountSettings;

  /// No description provided for @settingsAccountSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Hogar y notificaciones'**
  String get settingsAccountSettingsSubtitle;

  /// No description provided for @settingsExportReport.
  ///
  /// In es, this message translates to:
  /// **'Exportar reporte'**
  String get settingsExportReport;

  /// No description provided for @settingsBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get settingsBackup;

  /// No description provided for @settingsBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get settingsBudget;

  /// {amount} is an already-formatted money amount.
  ///
  /// In es, this message translates to:
  /// **'{amount} planeado'**
  String settingsBudgetPlanned(String amount);

  /// No description provided for @settingsAnnualSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen anual'**
  String get settingsAnnualSummary;

  /// No description provided for @settingsInvestments.
  ///
  /// In es, this message translates to:
  /// **'Inversiones'**
  String get settingsInvestments;

  /// No description provided for @settingsNotificationCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de notificaciones'**
  String get settingsNotificationCenter;

  /// No description provided for @settingsSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsSignOut;

  /// No description provided for @settingsUnlockAmountsTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear montos'**
  String get settingsUnlockAmountsTitle;

  /// No description provided for @settingsUnlockAmountsMessage.
  ///
  /// In es, this message translates to:
  /// **'Pega el código completo (con la llave después del punto) que tu pareja copió desde su tarjeta del hogar en Ajustes.'**
  String get settingsUnlockAmountsMessage;

  /// No description provided for @settingsUnlockCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código completo (CODIGO.llave)'**
  String get settingsUnlockCodeLabel;

  /// No description provided for @settingsUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get settingsUnlock;

  /// No description provided for @settingsAmountsUnlockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Montos desbloqueados'**
  String get settingsAmountsUnlockedTitle;

  /// No description provided for @settingsAmountsUnlockedMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya puedes ver los montos de este hogar.'**
  String get settingsAmountsUnlockedMessage;

  /// No description provided for @settingsRecoveryPhraseMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe las 12 palabras en orden, separadas por espacios. Las tildes y las mayúsculas no importan.'**
  String get settingsRecoveryPhraseMessage;

  /// No description provided for @settingsRecoveryPhraseLabel.
  ///
  /// In es, this message translates to:
  /// **'Frase (12 palabras)'**
  String get settingsRecoveryPhraseLabel;

  /// No description provided for @settingsNoKeyToInvite.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no tiene la llave del hogar, así que no puede invitar a nadie que vea los montos.'**
  String get settingsNoKeyToInvite;

  /// No description provided for @settingsNoKeyToShare.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo tampoco tiene la llave del hogar.'**
  String get settingsNoKeyToShare;

  /// Title/subject of the OS share sheet when sharing the key.
  ///
  /// In es, this message translates to:
  /// **'Llave de nuestro hogar en Finan2'**
  String get settingsKeyShareSubject;

  /// Theme mode.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// Theme mode.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// Theme mode: follow the device.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLightSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Siempre fondo claro.'**
  String get settingsThemeLightSubtitle;

  /// No description provided for @settingsThemeDarkSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Siempre fondo oscuro.'**
  String get settingsThemeDarkSubtitle;

  /// No description provided for @settingsThemeSystemSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sigue el ajuste de tu dispositivo.'**
  String get settingsThemeSystemSubtitle;

  /// No description provided for @settingsLeaveHousehold.
  ///
  /// In es, this message translates to:
  /// **'Salir del hogar'**
  String get settingsLeaveHousehold;

  /// {name} is the household's name.
  ///
  /// In es, this message translates to:
  /// **'Eres el único miembro de \"{name}\". Si sales, se borrarán para siempre todos sus datos: cuentas, movimientos, presupuestos, deudas y metas.'**
  String settingsLeaveHouseholdSoloMessage(String name);

  /// {name} is the household's name.
  ///
  /// In es, this message translates to:
  /// **'Vas a salir de \"{name}\". Tus cuentas, movimientos y demás datos seguirán disponibles para el resto del hogar. Podrás crear o unirte a otro hogar después.'**
  String settingsLeaveHouseholdMessage(String name);

  /// No description provided for @settingsLeaveAndDelete.
  ///
  /// In es, this message translates to:
  /// **'Salir y borrar'**
  String get settingsLeaveAndDelete;

  /// No description provided for @settingsLeave.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get settingsLeave;

  /// No description provided for @settingsMyName.
  ///
  /// In es, this message translates to:
  /// **'Mi nombre'**
  String get settingsMyName;

  /// No description provided for @settingsHouseholdMembers.
  ///
  /// In es, this message translates to:
  /// **'Miembros del hogar'**
  String get settingsHouseholdMembers;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsRecoveryPhraseHint.
  ///
  /// In es, this message translates to:
  /// **'Recuperar montos si pierden la llave'**
  String get settingsRecoveryPhraseHint;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get settingsDeleteAccount;

  /// {name} is the household's name.
  ///
  /// In es, this message translates to:
  /// **'Perderás el acceso a Finan2 de forma permanente y no se puede deshacer. Como eres el único miembro, también se borrarán todos los datos de \"{name}\".'**
  String settingsDeleteAccountSoloMessage(String name);

  /// No description provided for @settingsDeleteAccountMessage.
  ///
  /// In es, this message translates to:
  /// **'Perderás el acceso a Finan2 de forma permanente y no se puede deshacer. También saldrás de tu hogar - sus datos seguirán disponibles para el otro miembro.'**
  String get settingsDeleteAccountMessage;

  /// No description provided for @settingsCurrencyCop.
  ///
  /// In es, this message translates to:
  /// **'Peso COP · \$'**
  String get settingsCurrencyCop;

  /// No description provided for @settingsCurrencyUsd.
  ///
  /// In es, this message translates to:
  /// **'Dólar USD · US\$'**
  String get settingsCurrencyUsd;

  /// No description provided for @settingsWeekMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get settingsWeekMonday;

  /// No description provided for @settingsWeekSunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get settingsWeekSunday;

  /// No description provided for @settingsPickActiveYear.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el año activo'**
  String get settingsPickActiveYear;

  /// No description provided for @settingsCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get settingsCurrency;

  /// No description provided for @settingsActiveYear.
  ///
  /// In es, this message translates to:
  /// **'Año activo'**
  String get settingsActiveYear;

  /// No description provided for @settingsWeekStartsOn.
  ///
  /// In es, this message translates to:
  /// **'La semana inicia en'**
  String get settingsWeekStartsOn;

  /// No description provided for @settingsCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get settingsCategories;

  /// No description provided for @settingsAccounts.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get settingsAccounts;

  /// No description provided for @coreSheetErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get coreSheetErrorTitle;

  /// No description provided for @coreReauthTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get coreReauthTitle;

  /// No description provided for @corePassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get corePassword;

  /// Default tooltip of the period picker's back arrow.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get corePeriodPrevious;

  /// Shown under the period label when browsing another period; tapping jumps back to the current one.
  ///
  /// In es, this message translates to:
  /// **'Volver a hoy'**
  String get corePeriodBackToToday;

  /// No description provided for @coreGoToSettings.
  ///
  /// In es, this message translates to:
  /// **'Ir a Ajustes'**
  String get coreGoToSettings;

  /// The device lacks the household's encryption key.
  ///
  /// In es, this message translates to:
  /// **'Falta la llave de este hogar para ver estos montos.'**
  String get coreMissingKeyInline;

  /// No description provided for @coreMissingKeyTitle.
  ///
  /// In es, this message translates to:
  /// **'Falta la llave de este hogar'**
  String get coreMissingKeyTitle;

  /// No description provided for @coreMissingKeyBody.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no puede ver ni registrar montos todavía. Pide a tu pareja el código completo (con la llave después del punto) o usa la frase de recuperación del hogar en Ajustes para desbloquearlos.'**
  String get coreMissingKeyBody;

  /// No description provided for @coreNotificationPrimerTitle.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones'**
  String get coreNotificationPrimerTitle;

  /// No description provided for @coreNotificationPrimerBody.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos cuando tu pareja registre algo, se acerque una fecha de pago, o se pasen del presupuesto. Puedes ajustar esto después en Ajustes.'**
  String get coreNotificationPrimerBody;

  /// No description provided for @coreNotificationPrimerEnable.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get coreNotificationPrimerEnable;

  /// iOS Safari banner; the quoted text is the Safari menu item, in the device's language.
  ///
  /// In es, this message translates to:
  /// **'Para recibir notificaciones y que tus datos no se borren solos, instala Finan2: toca Compartir y luego \"Agregar a inicio\".'**
  String get coreInstallBanner;

  /// No description provided for @coreHomeTabHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get coreHomeTabHome;

  /// Bottom nav tab with the list of income and expenses.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get coreHomeTabMovements;

  /// No description provided for @coreHomeTabDebts.
  ///
  /// In es, this message translates to:
  /// **'Deudas'**
  String get coreHomeTabDebts;

  /// Bottom nav tab for savings goals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get coreHomeTabGoals;

  /// No description provided for @coreHomeTabSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get coreHomeTabSettings;

  /// No description provided for @coreSplashTagline.
  ///
  /// In es, this message translates to:
  /// **'Finanzas del hogar - para dos'**
  String get coreSplashTagline;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'El correo no es válido.'**
  String get errorInvalidEmail;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get errorWrongCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese correo.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es muy débil.'**
  String get errorWeakPassword;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Problema de conexión, intenta de nuevo.'**
  String get errorNetwork;

  /// code is a Firebase Auth error code.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal ({code}).'**
  String errorUnknownWithCode(String code);

  /// No description provided for @errorInviteNotFound.
  ///
  /// In es, this message translates to:
  /// **'Esa invitación no existe o ya venció. Pide a tu pareja una nueva desde Ajustes.'**
  String get errorInviteNotFound;

  /// No description provided for @errorHouseholdFull.
  ///
  /// In es, this message translates to:
  /// **'No pudimos unirte: el hogar ya tiene 2 miembros o la invitación dejó de ser válida.'**
  String get errorHouseholdFull;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal, intenta de nuevo.'**
  String get errorGeneric;

  /// No description provided for @errorMissingKey.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no tiene la llave para ver los montos de este hogar. Pide a tu pareja el código de invitación completo.'**
  String get errorMissingKey;

  /// No description provided for @errorRecoveryPhraseWordCount.
  ///
  /// In es, this message translates to:
  /// **'La frase debe tener {expected} palabras (escribiste {typed}).'**
  String errorRecoveryPhraseWordCount(int expected, int typed);

  /// No description provided for @errorRecoveryPhraseUnknownWord.
  ///
  /// In es, this message translates to:
  /// **'\"{word}\" no es una palabra de la frase. Revisa que esté bien escrita.'**
  String errorRecoveryPhraseUnknownWord(String word);

  /// No description provided for @errorRecoveryPhraseInvalid.
  ///
  /// In es, this message translates to:
  /// **'La frase no es válida. Revisa que las palabras estén en el orden correcto y bien escritas.'**
  String get errorRecoveryPhraseInvalid;

  /// No description provided for @validationPasswordPolicy.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres, con una mayúscula y una minúscula'**
  String get validationPasswordPolicy;

  /// Android notification channel name, shown in the OS settings.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio diario'**
  String get reminderDailyChannel;

  /// No description provided for @reminderDailyTitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tus gastos de hoy'**
  String get reminderDailyTitle;

  /// No description provided for @reminderDailyBody.
  ///
  /// In es, this message translates to:
  /// **'No olvides anotar lo que ingresó o gastó el hogar hoy.'**
  String get reminderDailyBody;

  /// No description provided for @reminderWeeklyChannel.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get reminderWeeklyChannel;

  /// No description provided for @reminderWeeklyTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal listo'**
  String get reminderWeeklyTitle;

  /// No description provided for @reminderWeeklyBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa cómo le fue al hogar esta semana en Finan2.'**
  String get reminderWeeklyBody;

  /// No description provided for @reminderDebtChannel.
  ///
  /// In es, this message translates to:
  /// **'Pagos de deudas'**
  String get reminderDebtChannel;

  /// No description provided for @reminderDebtTodayTitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy pagas {debt}'**
  String reminderDebtTodayTitle(String debt);

  /// No description provided for @reminderDebtTodayBody.
  ///
  /// In es, this message translates to:
  /// **'Hoy es el día de pago de tu deuda {debt}.'**
  String reminderDebtTodayBody(String debt);

  /// No description provided for @reminderDebtSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago de {debt} pronto'**
  String reminderDebtSoonTitle(String debt);

  /// No description provided for @reminderDebtSoonBody.
  ///
  /// In es, this message translates to:
  /// **'La cuota de {debt} vence en {days, plural, =1{1 día} other{{days} días}}.'**
  String reminderDebtSoonBody(String debt, int days);

  /// No description provided for @reminderActivityChannel.
  ///
  /// In es, this message translates to:
  /// **'Actividad del hogar'**
  String get reminderActivityChannel;

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
