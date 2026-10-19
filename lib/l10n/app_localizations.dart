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

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'{month} todavía no tiene plan.'**
  String budgetEmptyTitle(String month);

  /// No description provided for @budgetEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Pongan cuánto quieren gastar en cada categoría y aquí verán lo que les queda de cada una.'**
  String get budgetEmptyDescription;

  /// No description provided for @budgetEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Planear una categoría'**
  String get budgetEmptyAction;

  /// No description provided for @budgetEmptyCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar el plan de {month}'**
  String budgetEmptyCopy(String month);

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

  /// No description provided for @annualSummaryEarned.
  ///
  /// In es, this message translates to:
  /// **'Entró'**
  String get annualSummaryEarned;

  /// No description provided for @annualSummarySpent.
  ///
  /// In es, this message translates to:
  /// **'Salió'**
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

  /// No description provided for @dashboardNoCategorizedSpending.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos categorizados este mes.'**
  String get dashboardNoCategorizedSpending;

  /// No description provided for @dashboardDecrypting.
  ///
  /// In es, this message translates to:
  /// **'Descifrando los montos en este teléfono…'**
  String get dashboardDecrypting;

  /// Inicio's title: greets the signed-in member by first name.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String dashboardGreeting(String name);

  /// Label over Inicio's big figure: what's left of the month's budget. {month} is the month name as DateFormat gives it (lowercase in Spanish).
  ///
  /// In es, this message translates to:
  /// **'Les queda del plan de {month}'**
  String dashboardLeftOfPlan(String month);

  /// Label over Inicio's big figure when the month's spending went past the budget; the figure is by how much.
  ///
  /// In es, this message translates to:
  /// **'Se pasaron del plan de {month}'**
  String dashboardOverPlan(String month);

  /// Label over Inicio's big figure when the month has no budget: what went out.
  ///
  /// In es, this message translates to:
  /// **'Gastado en {month}'**
  String dashboardSpentIn(String month);

  /// Under Inicio's figure: the month's whole plan, already formatted as money.
  ///
  /// In es, this message translates to:
  /// **'de {amount}'**
  String dashboardOfPlan(String amount);

  /// Under Inicio's figure: whole days after today until the month ends.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{último día} =1{falta 1 día} other{faltan {count} días}}'**
  String dashboardDaysLeft(int count);

  /// Under Inicio's figure: what's left divided by the days left, already formatted as money.
  ///
  /// In es, this message translates to:
  /// **'unos {amount} al día'**
  String dashboardPerDay(String amount);

  /// Under Inicio's figure when the month has no budget.
  ///
  /// In es, this message translates to:
  /// **'Sin plan este mes'**
  String get dashboardNoPlan;

  /// Under Inicio's figure when there's no plan: the month's income, already formatted as money.
  ///
  /// In es, this message translates to:
  /// **'entraron {amount}'**
  String dashboardIncomeIn(String amount);

  /// Legend of Inicio's stacked bar: the part of the plan not spent yet.
  ///
  /// In es, this message translates to:
  /// **'Queda'**
  String get dashboardLegendLeft;

  /// Legend of Inicio's stacked bar: every category past the four biggest.
  ///
  /// In es, this message translates to:
  /// **'Otras'**
  String get dashboardLegendOther;

  /// Action word at the end of Inicio's notice; opens the notifications.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get dashboardNoticeSee;

  /// No description provided for @dashboardWhoPaid.
  ///
  /// In es, this message translates to:
  /// **'Quién pagó este mes'**
  String get dashboardWhoPaid;

  /// No description provided for @dashboardMovementCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 movimiento} other{{count} movimientos}}'**
  String dashboardMovementCount(int count);

  /// No description provided for @dashboardRecent.
  ///
  /// In es, this message translates to:
  /// **'Últimos movimientos'**
  String get dashboardRecent;

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

  /// No description provided for @authLoginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cada quien entra con su cuenta; lo que anotan es de los dos.'**
  String get authLoginSubtitle;

  /// Login heading: says what the app is. The line break is intended.
  ///
  /// In es, this message translates to:
  /// **'La libreta de la casa,\npara los dos.'**
  String get authLoginHeadline;

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
  /// **'Entrar'**
  String get authSignIn;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Seguir con Google'**
  String get authContinueWithGoogle;

  /// Followed by the authCreateAccountHere link; keep the trailing space.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccountHere.
  ///
  /// In es, this message translates to:
  /// **'Créala'**
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
  /// **'Tu cuenta'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Es solo tuya. La casa la armas o te unes en el paso siguiente.'**
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

  /// No description provided for @authHaveAccountLink.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo cuenta'**
  String get authHaveAccountLink;

  /// Prefilled, editable name when creating a household.
  ///
  /// In es, this message translates to:
  /// **'Nuestro hogar'**
  String get householdDefaultName;

  /// No description provided for @householdCreateJoinTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Arman la casa o ya existe?'**
  String get householdCreateJoinTitle;

  /// No description provided for @householdCreateJoinSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Uno de los dos la crea; el otro entra con un código.'**
  String get householdCreateJoinSubtitle;

  /// No description provided for @householdCreateOptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear la casa'**
  String get householdCreateOptionTitle;

  /// No description provided for @householdCreateOptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Empiezo yo e invito a mi pareja.'**
  String get householdCreateOptionSubtitle;

  /// No description provided for @householdJoinOptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Tengo un código'**
  String get householdJoinOptionTitle;

  /// No description provided for @householdJoinOptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mi pareja ya la creó.'**
  String get householdJoinOptionSubtitle;

  /// No description provided for @householdNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la casa'**
  String get householdNameLabel;

  /// No description provided for @householdNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre a la casa'**
  String get householdNameRequired;

  /// No description provided for @householdCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get householdCodeLabel;

  /// No description provided for @householdCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Pégalo completo, tal como te llegó: lleva la llave de la casa.'**
  String get householdCodeHint;

  /// No description provided for @householdCodeRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código que te compartieron'**
  String get householdCodeRequired;

  /// No description provided for @householdCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Armar la casa'**
  String get householdCreateButton;

  /// No description provided for @householdJoinButton.
  ///
  /// In es, this message translates to:
  /// **'Entrar a la casa'**
  String get householdJoinButton;

  /// No description provided for @householdJoinedWithoutKeyTitle.
  ///
  /// In es, this message translates to:
  /// **'Te uniste al hogar'**
  String get householdJoinedWithoutKeyTitle;

  /// No description provided for @householdJoinedWithoutKeyMessage.
  ///
  /// In es, this message translates to:
  /// **'Este código no traía la llave para ver montos. Pide a tu pareja que te la comparta desde Ajustes, en «Compartir la llave».'**
  String get householdJoinedWithoutKeyMessage;

  /// No description provided for @householdSetupStep.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de {total}'**
  String householdSetupStep(int step, int total);

  /// No description provided for @householdSetupCurrencyTitle.
  ///
  /// In es, this message translates to:
  /// **'¿En qué moneda llevan las cuentas?'**
  String get householdSetupCurrencyTitle;

  /// No description provided for @householdSetupCurrencyDescription.
  ///
  /// In es, this message translates to:
  /// **'La de todos los montos de la casa. Se puede cambiar después en Ajustes.'**
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
  /// **'¿Dónde está la plata hoy?'**
  String get householdSetupAccountTitle;

  /// No description provided for @householdSetupAccountDescription.
  ///
  /// In es, this message translates to:
  /// **'Una cuenta para empezar: el banco, una billetera o el efectivo. Con el saldo real, lo que anotes cuadra desde el primer día.'**
  String get householdSetupAccountDescription;

  /// No description provided for @householdSetupAccountNameMissingTitle.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre'**
  String get householdSetupAccountNameMissingTitle;

  /// No description provided for @householdSetupAccountNameMissingMessage.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo el banco o «Efectivo». Si prefieres, déjala para después con «Ahora no».'**
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
  /// **'Los montos se cifran con una llave que vive solo en sus teléfonos. Si los dos la pierden, 12 palabras la recuperan. Se muestran una sola vez: anótalas en papel y guárdalas con tu pareja. También se puede hacer después, desde Ajustes.'**
  String get householdSetupRecoveryDescription;

  /// No description provided for @householdSetupRecoveryTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Y si pierden la llave?'**
  String get householdSetupRecoveryTitle;

  /// No description provided for @householdGeneratePhrase.
  ///
  /// In es, this message translates to:
  /// **'Generar frase'**
  String get householdGeneratePhrase;

  /// No description provided for @householdSetupLater.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get householdSetupLater;

  /// No description provided for @householdInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Ahora tu pareja.'**
  String get householdInviteTitle;

  /// No description provided for @householdInviteMessage.
  ///
  /// In es, this message translates to:
  /// **'Mándale este código con el botón de compartir. Lleva pegada la llave de la casa, que no se ve aquí: compártelo solo con tu pareja y no lo publiques en ningún lado.'**
  String get householdInviteMessage;

  /// No description provided for @householdInviteFootnote.
  ///
  /// In es, this message translates to:
  /// **'Sirve una vez y vence en 7 días · se puede generar otro en Ajustes'**
  String get householdInviteFootnote;

  /// Screen-reader label of the empty, dashed circle where the partner will be.
  ///
  /// In es, this message translates to:
  /// **'Falta tu pareja'**
  String get householdInviteMissingPartner;

  /// Title/subject of the OS share sheet when sharing the invite.
  ///
  /// In es, this message translates to:
  /// **'Invitación a nuestro hogar en Finan2'**
  String get householdInviteShareSubject;

  /// No description provided for @householdInviteShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get householdInviteShare;

  /// No description provided for @householdInviteSkip.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
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
  /// **'Ese código no trae la llave completa. Pide a tu pareja que la comparta de nuevo desde Ajustes, en «Compartir la llave».'**
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

  /// No description provided for @settingsAccountsAndCards.
  ///
  /// In es, this message translates to:
  /// **'Cuentas y tarjetas'**
  String get settingsAccountsAndCards;

  /// Under the signed-in member's name in Ajustes.
  ///
  /// In es, this message translates to:
  /// **'tú'**
  String get settingsMemberYou;

  /// Under the other member's name in Ajustes.
  ///
  /// In es, this message translates to:
  /// **'en la casa'**
  String get settingsMemberPartner;

  /// No description provided for @settingsInvite.
  ///
  /// In es, this message translates to:
  /// **'Invitar a la casa'**
  String get settingsInvite;

  /// The empty second place in Ajustes while the household has one member.
  ///
  /// In es, this message translates to:
  /// **'Invitar'**
  String get settingsInviteSomeone;

  /// No description provided for @settingsShareKey.
  ///
  /// In es, this message translates to:
  /// **'Compartir la llave'**
  String get settingsShareKey;

  /// No description provided for @settingsMissingKeyBanner.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no tiene la llave para ver los montos de este hogar. Pega el código que tu pareja compartió desde Ajustes, en «Compartir la llave», o escribe la frase de recuperación.'**
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
  /// **'Tu navegador no garantizó que los datos de Finan2 se conserven. Si no abres la app por varios días, podrías perder el acceso a los montos cifrados de este dispositivo. Asegúrate de tener una frase de recuperación en Ajustes, en «Tu cuenta».'**
  String get settingsStorageWarning;

  /// No description provided for @settingsFinancialSettings.
  ///
  /// In es, this message translates to:
  /// **'Moneda y año'**
  String get settingsFinancialSettings;

  /// No description provided for @settingsAccountSettings.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get settingsAccountSettings;

  /// No description provided for @settingsExportReport.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get settingsExportReport;

  /// No description provided for @settingsBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia y llave'**
  String get settingsBackup;

  /// No description provided for @settingsInvestments.
  ///
  /// In es, this message translates to:
  /// **'Inversiones'**
  String get settingsInvestments;

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
  /// **'Pega el código completo (con la llave después del punto) que tu pareja compartió desde Ajustes, en «Compartir la llave».'**
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

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In es, this message translates to:
  /// **'Como el teléfono'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sigue el idioma de tu teléfono.'**
  String get settingsLanguageSystemSubtitle;

  /// Under «Español» / «English» in the language sheet; those two names are never translated.
  ///
  /// In es, this message translates to:
  /// **'Siempre en este idioma, aunque el teléfono esté en otro.'**
  String get settingsLanguageFixedSubtitle;

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

  /// Shown under the period label when browsing another period; tapping jumps back to the current one.
  ///
  /// In es, this message translates to:
  /// **'Volver a hoy'**
  String get corePeriodBackToToday;

  /// No description provided for @coreMissingKeyTitle.
  ///
  /// In es, this message translates to:
  /// **'Este teléfono no tiene la llave de la casa.'**
  String get coreMissingKeyTitle;

  /// No description provided for @coreMissingKeyBody.
  ///
  /// In es, this message translates to:
  /// **'Los montos se cifran con una llave que solo vive en sus teléfonos. Sin ella, este no puede abrir los movimientos ni anotar nuevos.'**
  String get coreMissingKeyBody;

  /// No description provided for @coreMissingKeyUsePhrase.
  ///
  /// In es, this message translates to:
  /// **'Usar la frase de 12 palabras'**
  String get coreMissingKeyUsePhrase;

  /// No description provided for @coreMissingKeyAskPartner.
  ///
  /// In es, this message translates to:
  /// **'Pedirle el código a {name}'**
  String coreMissingKeyAskPartner(String name);

  /// No description provided for @coreMissingKeyPasteCode.
  ///
  /// In es, this message translates to:
  /// **'Pegar el código de la llave'**
  String get coreMissingKeyPasteCode;

  /// No description provided for @coreOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Lo que anotes se guarda aquí y se envía solo cuando vuelva la señal.'**
  String get coreOffline;

  /// No description provided for @coreUnsynced.
  ///
  /// In es, this message translates to:
  /// **'por enviar'**
  String get coreUnsynced;

  /// No description provided for @coreLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get coreLoading;

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

  /// Bottom nav tab that holds savings goals and debts.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get coreHomeTabPlan;

  /// The center button of the bottom nav: record a new movement.
  ///
  /// In es, this message translates to:
  /// **'Anotar'**
  String get coreHomeAdd;

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

  /// No description provided for @debtsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No deben nada.'**
  String get debtsEmptyTitle;

  /// No description provided for @debtsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Si llega una tarjeta o un crédito, agréguenlo aquí y la app les dice cuándo terminan.'**
  String get debtsEmptyDescription;

  /// No description provided for @debtsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar una deuda'**
  String get debtsEmptyAction;

  /// Banner caption; the projected month is shown below it.
  ///
  /// In es, this message translates to:
  /// **'Libres de deudas en'**
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

  /// No description provided for @debtsCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo pendiente'**
  String get debtsCurrentBalance;

  /// Amount paid on top of the minimum or the installment each month.
  ///
  /// In es, this message translates to:
  /// **'Abono extra'**
  String get debtsExtraPayment;

  /// No description provided for @debtsMonthlyInstallment.
  ///
  /// In es, this message translates to:
  /// **'Cuota mensual'**
  String get debtsMonthlyInstallment;

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

  /// No description provided for @debtsScheduledPayment.
  ///
  /// In es, this message translates to:
  /// **'Previsto'**
  String get debtsScheduledPayment;

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

  /// No description provided for @debtsCreditLimit.
  ///
  /// In es, this message translates to:
  /// **'Cupo'**
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

  /// No description provided for @savingsGoalsTotalSaved.
  ///
  /// In es, this message translates to:
  /// **'Total ahorrado'**
  String get savingsGoalsTotalSaved;

  /// No description provided for @savingsGoalsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay metas.'**
  String get savingsGoalsEmptyTitle;

  /// No description provided for @savingsGoalsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Un viaje, un colchón, un carro: pónganle cifra y fecha, y aquí verán cuánto les falta y cuánto apartar cada mes.'**
  String get savingsGoalsEmptyDescription;

  /// No description provided for @savingsGoalsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Crear una meta'**
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

  /// No description provided for @savingsGoalsPerMonth.
  ///
  /// In es, this message translates to:
  /// **'{amount}/mes'**
  String savingsGoalsPerMonth(String amount);

  /// No description provided for @savingsGoalsBehind.
  ///
  /// In es, this message translates to:
  /// **'va atrasada'**
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
  /// **'Cuánto necesitan'**
  String get savingsGoalsTarget;

  /// No description provided for @savingsGoalsMonthlyContribution.
  ///
  /// In es, this message translates to:
  /// **'Aporte mensual'**
  String get savingsGoalsMonthlyContribution;

  /// No description provided for @savingsGoalsTargetDate.
  ///
  /// In es, this message translates to:
  /// **'Para cuándo'**
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
  /// **'Ya tienen'**
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
  /// **'Todavía no hay inversiones.'**
  String get investmentsEmptyTitle;

  /// CDT = certificado de depósito a término (a CD).
  ///
  /// In es, this message translates to:
  /// **'Agrega tu CDT, fondo o cripto para llevarle el pulso a tu portafolio.'**
  String get investmentsEmptyDescription;

  /// No description provided for @investmentsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar una inversión'**
  String get investmentsEmptyAction;

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

  /// No description provided for @transactionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get transactionsTitle;

  /// No description provided for @transactionsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Anotar'**
  String get transactionsNewTitle;

  /// No description provided for @transactionsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar movimiento'**
  String get transactionsEditTitle;

  /// Small line over a movement's detail title.
  ///
  /// In es, this message translates to:
  /// **'Movimiento'**
  String get transactionsDetailOver;

  /// No description provided for @transactionsEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get transactionsEdit;

  /// No description provided for @transactionsDelete.
  ///
  /// In es, this message translates to:
  /// **'Borrar movimiento'**
  String get transactionsDelete;

  /// No description provided for @transactionsDeleted.
  ///
  /// In es, this message translates to:
  /// **'Movimiento borrado'**
  String get transactionsDeleted;

  /// No description provided for @transactionsDeleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo borrar'**
  String get transactionsDeleteFailed;

  /// No description provided for @transactionsMaxTagsTitle.
  ///
  /// In es, this message translates to:
  /// **'Máximo {max} etiquetas'**
  String transactionsMaxTagsTitle(int max);

  /// No description provided for @transactionsMaxTagsMessage.
  ///
  /// In es, this message translates to:
  /// **'Quita una antes de añadir otra.'**
  String get transactionsMaxTagsMessage;

  /// No description provided for @transactionsCreditCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de crédito'**
  String get transactionsCreditCard;

  /// Anotar's fourth type: moving money between two of the household's own accounts.
  ///
  /// In es, this message translates to:
  /// **'Pasar'**
  String get transactionsTypeTransfer;

  /// No description provided for @transactionsTransferNeedsTwoAccounts.
  ///
  /// In es, this message translates to:
  /// **'Para pasar plata hacen falta dos cuentas. Créalas en Ajustes.'**
  String get transactionsTransferNeedsTwoAccounts;

  /// No description provided for @transactionsIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Completa el monto, la categoría y la cuenta.'**
  String get transactionsIncomplete;

  /// Title of the sheet shown when Anotar can't save yet.
  ///
  /// In es, this message translates to:
  /// **'Falta un dato'**
  String get transactionsIncompleteTitle;

  /// Under Anotar's amount when the date is today; {date} is the weekday and day, e.g. «martes 14».
  ///
  /// In es, this message translates to:
  /// **'Hoy, {date}'**
  String transactionsDateToday(String date);

  /// No description provided for @transactionsNoCategoriesOfType.
  ///
  /// In es, this message translates to:
  /// **'No hay categorías de este tipo todavía. Créalas en Ajustes.'**
  String get transactionsNoCategoriesOfType;

  /// No description provided for @transactionsNoAccounts.
  ///
  /// In es, this message translates to:
  /// **'No hay cuentas todavía. Créalas en Ajustes.'**
  String get transactionsNoAccounts;

  /// No description provided for @transactionsSelectAccount.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una cuenta'**
  String get transactionsSelectAccount;

  /// No description provided for @transactionsTags.
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get transactionsTags;

  /// Tags are lowercase words joined by hyphens.
  ///
  /// In es, this message translates to:
  /// **'Añadir etiqueta, por ejemplo viaje-cartagena'**
  String get transactionsAddTagHint;

  /// No description provided for @transactionsAddTag.
  ///
  /// In es, this message translates to:
  /// **'Añadir etiqueta'**
  String get transactionsAddTag;

  /// Label above the member chips on an income: who received it.
  ///
  /// In es, this message translates to:
  /// **'Lo recibió'**
  String get transactionsReceivedBy;

  /// Label above the member chips: who paid the movement.
  ///
  /// In es, this message translates to:
  /// **'Pagó'**
  String get transactionsPaidBy;

  /// No description provided for @transactionsLoggedBy.
  ///
  /// In es, this message translates to:
  /// **'Lo anotó'**
  String get transactionsLoggedBy;

  /// No description provided for @transactionsPreviousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get transactionsPreviousMonth;

  /// No description provided for @transactionsNextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get transactionsNextMonth;

  /// Movimientos' day heading for today; {day} is the weekday and day, e.g. «martes 14». Shown in capitals.
  ///
  /// In es, this message translates to:
  /// **'Hoy · {day}'**
  String transactionsDayToday(String day);

  /// Movimientos' day heading for yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer · {day}'**
  String transactionsDayYesterday(String day);

  /// At the end of a search or filter: how many movements matched and their net, already formatted with its sign.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 movimiento} other{{count} movimientos}} · {amount}'**
  String transactionsResultsTotal(int count, String amount);

  /// No description provided for @transactionsSearchWholeYear.
  ///
  /// In es, this message translates to:
  /// **'Todo {year}'**
  String transactionsSearchWholeYear(int year);

  /// No description provided for @transactionsNoMatchTitle.
  ///
  /// In es, this message translates to:
  /// **'Nada coincide'**
  String get transactionsNoMatchTitle;

  /// No description provided for @transactionsNoMatchYear.
  ///
  /// In es, this message translates to:
  /// **'Ningún movimiento de {year} coincide con la búsqueda.'**
  String transactionsNoMatchYear(int year);

  /// month is a month and year, e.g. Julio 2026.
  ///
  /// In es, this message translates to:
  /// **'Ningún movimiento de {month} coincide con la búsqueda o los filtros.'**
  String transactionsNoMatchMonth(String month);

  /// No description provided for @transactionsClearSearch.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get transactionsClearSearch;

  /// No description provided for @transactionsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'{month} está en blanco.'**
  String transactionsEmptyTitle(String month);

  /// No description provided for @transactionsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Lo primero que anoten aparece aquí, con quién lo pagó. Los fijos del mes se anotan solos el día que toca.'**
  String get transactionsEmptyDescription;

  /// No description provided for @transactionsEmptyDescriptionMonth.
  ///
  /// In es, this message translates to:
  /// **'Ese mes no se anotó nada. Si algo quedó por fuera, todavía se puede anotar con su fecha.'**
  String get transactionsEmptyDescriptionMonth;

  /// No description provided for @transactionsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Anotar el primero'**
  String get transactionsEmptyAction;

  /// No description provided for @transactionsSeeMonth.
  ///
  /// In es, this message translates to:
  /// **'Ver {month}'**
  String transactionsSeeMonth(String month);

  /// No description provided for @transactionsRecurringBills.
  ///
  /// In es, this message translates to:
  /// **'Fijos'**
  String get transactionsRecurringBills;

  /// No description provided for @transactionsNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get transactionsNotes;

  /// No description provided for @transactionsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar descripción, categoría, monto o #etiqueta'**
  String get transactionsSearchHint;

  /// No description provided for @transactionsFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get transactionsFilters;

  /// No description provided for @transactionsFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get transactionsFilterTitle;

  /// No description provided for @transactionsFilterType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get transactionsFilterType;

  /// No description provided for @transactionsFilterNoCategories.
  ///
  /// In es, this message translates to:
  /// **'No hay categorías de este tipo.'**
  String get transactionsFilterNoCategories;

  /// No description provided for @transactionsFilterTag.
  ///
  /// In es, this message translates to:
  /// **'Etiqueta'**
  String get transactionsFilterTag;

  /// Active filter chip: only what this member paid.
  ///
  /// In es, this message translates to:
  /// **'Pagó {name}'**
  String transactionsPaidByChip(String name);

  /// Filter sheet, who paid: no filter.
  ///
  /// In es, this message translates to:
  /// **'Los dos'**
  String get transactionsFilterBoth;

  /// No description provided for @transactionsFilterClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get transactionsFilterClear;

  /// Filter sheet's main button: how many movements the chosen filters show.
  ///
  /// In es, this message translates to:
  /// **'Ver {count}'**
  String transactionsFilterSee(int count);

  /// No description provided for @transfersInvalid.
  ///
  /// In es, this message translates to:
  /// **'Elige un monto y dos cuentas distintas.'**
  String get transfersInvalid;

  /// No description provided for @transfersFrom.
  ///
  /// In es, this message translates to:
  /// **'De'**
  String get transfersFrom;

  /// No description provided for @transfersTo.
  ///
  /// In es, this message translates to:
  /// **'A'**
  String get transfersTo;

  /// No description provided for @transfersSelectAccount.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una cuenta'**
  String get transfersSelectAccount;

  /// No description provided for @transfersHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Pasos entre cuentas'**
  String get transfersHistoryTitle;

  /// No description provided for @transfersDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar transferencia'**
  String get transfersDeleteTitle;

  /// No description provided for @transfersDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se revertirá el ajuste de saldo en ambas cuentas. Esta acción no se puede deshacer.'**
  String get transfersDeleteMessage;

  /// Shown in place of the name of an account that no longer exists.
  ///
  /// In es, this message translates to:
  /// **'Cuenta eliminada'**
  String get transfersDeletedAccount;

  /// No description provided for @transfersEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no han pasado plata.'**
  String get transfersEmptyTitle;

  /// No description provided for @transfersEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Cuando pasen plata de una cuenta a otra queda anotado aquí, sin contar como gasto.'**
  String get transfersEmptyDescription;

  /// No description provided for @transfersEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Pasar plata'**
  String get transfersEmptyAction;

  /// No description provided for @accountsTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get accountsTitle;

  /// No description provided for @accountsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cuentas.'**
  String get accountsEmptyTitle;

  /// No description provided for @accountsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Agreguen el efectivo, el banco o la billetera de donde sale la plata, y aquí verán cuánto tienen disponible.'**
  String get accountsEmptyDescription;

  /// No description provided for @accountsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar una cuenta'**
  String get accountsEmptyAction;

  /// No description provided for @accountsTransferBetween.
  ///
  /// In es, this message translates to:
  /// **'Pasar entre cuentas'**
  String get accountsTransferBetween;

  /// No description provided for @accountsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get accountsNewTitle;

  /// No description provided for @accountsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar cuenta'**
  String get accountsEditTitle;

  /// No description provided for @accountsTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get accountsTypeLabel;

  /// No description provided for @accountsCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo de hoy'**
  String get accountsCurrentBalance;

  /// No description provided for @accountsIncludeInAvailable.
  ///
  /// In es, this message translates to:
  /// **'Cuenta en «Disponible»'**
  String get accountsIncludeInAvailable;

  /// No description provided for @accountsDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get accountsDeleteTitle;

  /// No description provided for @accountsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Esta acción no se puede deshacer.'**
  String accountsDeleteMessage(String name);

  /// No description provided for @accountsCannotDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar'**
  String get accountsCannotDeleteTitle;

  /// No description provided for @accountsCannotDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" tiene {count, plural, =1{1 registro} other{{count} registros}} (movimientos, transferencias, pagos de tarjeta o facturas recurrentes). Bórralos o cámbialos de cuenta primero. Si solo quieres que no sume, apaga «Cuenta en Disponible».'**
  String accountsCannotDeleteMessage(String name, int count);

  /// Account types.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get accountsTypeCash;

  /// No description provided for @accountsTypeBank.
  ///
  /// In es, this message translates to:
  /// **'Banco'**
  String get accountsTypeBank;

  /// A digital wallet app, e.g. Nequi.
  ///
  /// In es, this message translates to:
  /// **'Billetera'**
  String get accountsTypeWallet;

  /// No description provided for @accountsTypeDebit.
  ///
  /// In es, this message translates to:
  /// **'Débito'**
  String get accountsTypeDebit;

  /// No description provided for @categoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categoriesTitle;

  /// Under a category in the list: how many of this year's transactions are filed under it.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin movimientos este año} =1{1 mov. este año} other{{count} mov. este año}}'**
  String categoriesRowUsage(int count);

  /// Under a category in the list when what's left of its budget carries into next month.
  ///
  /// In es, this message translates to:
  /// **'Acumula'**
  String get categoriesRowRollover;

  /// No description provided for @categoriesNoneOfType.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay categorías de este tipo. Créala con el +.'**
  String get categoriesNoneOfType;

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay categorías.'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Cada movimiento va en una categoría: creen la primera para empezar a anotar.'**
  String get categoriesEmptyDescription;

  /// No description provided for @categoriesEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Crear una categoría'**
  String get categoriesEmptyAction;

  /// No description provided for @categoriesNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get categoriesNewTitle;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar categoría'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesPreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get categoriesPreview;

  /// No description provided for @categoriesTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get categoriesTypeLabel;

  /// No description provided for @categoriesIcon.
  ///
  /// In es, this message translates to:
  /// **'Ícono'**
  String get categoriesIcon;

  /// No description provided for @categoriesColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get categoriesColor;

  /// No description provided for @categoriesRolloverTitle.
  ///
  /// In es, this message translates to:
  /// **'Acumular de un mes a otro'**
  String get categoriesRolloverTitle;

  /// No description provided for @categoriesRolloverSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que sobra o se pasa cuenta para el mes siguiente; se reinicia en enero.'**
  String get categoriesRolloverSubtitle;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Esta acción no se puede deshacer.'**
  String categoriesDeleteMessage(String name);

  /// No description provided for @categoriesCannotDeleteYetTitle.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar todavía'**
  String get categoriesCannotDeleteYetTitle;

  /// usage is categoriesUsage*, e.g. 2 movimientos y 1 factura recurrente; type is the category type in lowercase.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" tiene {usage}. Crea otra categoría de {type} para pasarlos ahí y luego elimina esta.'**
  String categoriesCannotDeleteYetMessage(String name, String usage, String type);

  /// No description provided for @categoriesReassignTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A dónde pasamos lo de {name}?'**
  String categoriesReassignTitle(String name);

  /// No description provided for @categoriesReassignMessage.
  ///
  /// In es, this message translates to:
  /// **'Tiene {usage}. Elige la categoría que se quedará con ellos; después \"{name}\" se elimina.'**
  String categoriesReassignMessage(String usage, String name);

  /// No description provided for @categoriesUsageMovements.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 movimiento} other{{count} movimientos}}'**
  String categoriesUsageMovements(int count);

  /// No description provided for @categoriesUsageRecurringBills.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 fijo} other{{count} fijos}}'**
  String categoriesUsageRecurringBills(int count);

  /// No description provided for @categoriesUsageBoth.
  ///
  /// In es, this message translates to:
  /// **'{movements} y {bills}'**
  String categoriesUsageBoth(String movements, String bills);

  /// Category types, singular.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get categoriesTypeIncome;

  /// No description provided for @categoriesTypeBill.
  ///
  /// In es, this message translates to:
  /// **'Factura'**
  String get categoriesTypeBill;

  /// No description provided for @categoriesTypeExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get categoriesTypeExpense;

  /// No description provided for @categoriesTypeSavings.
  ///
  /// In es, this message translates to:
  /// **'Ahorro'**
  String get categoriesTypeSavings;

  /// Category types, plural: section headers and filters.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get categoriesTypeIncomePlural;

  /// No description provided for @categoriesTypeBillPlural.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get categoriesTypeBillPlural;

  /// No description provided for @categoriesTypeExpensePlural.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get categoriesTypeExpensePlural;

  /// No description provided for @categoriesTypeSavingsPlural.
  ///
  /// In es, this message translates to:
  /// **'Ahorros'**
  String get categoriesTypeSavingsPlural;

  /// Default categories a new household starts with. Stored as data, in the language of the phone that created the household.
  ///
  /// In es, this message translates to:
  /// **'Salario'**
  String get categoriesDefaultSalary;

  /// No description provided for @categoriesDefaultFreelance.
  ///
  /// In es, this message translates to:
  /// **'Freelance'**
  String get categoriesDefaultFreelance;

  /// No description provided for @categoriesDefaultRent.
  ///
  /// In es, this message translates to:
  /// **'Arriendo'**
  String get categoriesDefaultRent;

  /// No description provided for @categoriesDefaultUtilities.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get categoriesDefaultUtilities;

  /// No description provided for @categoriesDefaultPhoneInternet.
  ///
  /// In es, this message translates to:
  /// **'Celular e internet'**
  String get categoriesDefaultPhoneInternet;

  /// No description provided for @categoriesDefaultStreaming.
  ///
  /// In es, this message translates to:
  /// **'Streaming'**
  String get categoriesDefaultStreaming;

  /// No description provided for @categoriesDefaultGroceries.
  ///
  /// In es, this message translates to:
  /// **'Mercado'**
  String get categoriesDefaultGroceries;

  /// No description provided for @categoriesDefaultTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get categoriesDefaultTransport;

  /// No description provided for @categoriesDefaultRestaurants.
  ///
  /// In es, this message translates to:
  /// **'Restaurantes'**
  String get categoriesDefaultRestaurants;

  /// No description provided for @categoriesDefaultLeisure.
  ///
  /// In es, this message translates to:
  /// **'Ocio'**
  String get categoriesDefaultLeisure;

  /// No description provided for @categoriesDefaultHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get categoriesDefaultHealth;

  /// No description provided for @categoriesDefaultHomeCleaning.
  ///
  /// In es, this message translates to:
  /// **'Hogar y aseo'**
  String get categoriesDefaultHomeCleaning;

  /// No description provided for @categoriesDefaultEmergencyFund.
  ///
  /// In es, this message translates to:
  /// **'Fondo de emergencia'**
  String get categoriesDefaultEmergencyFund;

  /// No description provided for @categoriesDefaultTravel.
  ///
  /// In es, this message translates to:
  /// **'Viaje'**
  String get categoriesDefaultTravel;

  /// No description provided for @recurringBillsTitle.
  ///
  /// In es, this message translates to:
  /// **'Fijos'**
  String get recurringBillsTitle;

  /// No description provided for @recurringBillsCommittedLabel.
  ///
  /// In es, this message translates to:
  /// **'Comprometido cada mes'**
  String get recurringBillsCommittedLabel;

  /// No description provided for @recurringBillsCommittedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Ningún fijo activo} =1{1 fijo} other{{count} fijos}}'**
  String recurringBillsCommittedCount(int count);

  /// Follows recurringBillsCommittedCount after ' · ', lowercase.
  ///
  /// In es, this message translates to:
  /// **'los no mensuales, en promedio'**
  String get recurringBillsAveragedNote;

  /// No description provided for @recurringBillsAutoNote.
  ///
  /// In es, this message translates to:
  /// **'Se anotan solos en Movimientos el día que les toca.'**
  String get recurringBillsAutoNote;

  /// No description provided for @recurringBillsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay fijos.'**
  String get recurringBillsEmptyTitle;

  /// No description provided for @recurringBillsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Programa el arriendo, los servicios o el sueldo para que se anoten solos el día que les toca.'**
  String get recurringBillsEmptyDescription;

  /// No description provided for @recurringBillsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar un fijo'**
  String get recurringBillsEmptyAction;

  /// Under a paused recurring item in the list, instead of its schedule.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get recurringBillsStatusPaused;

  /// Under a recurring item whose end date went by.
  ///
  /// In es, this message translates to:
  /// **'Ya terminó'**
  String get recurringBillsStatusEnded;

  /// No description provided for @recurringBillsTypeIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get recurringBillsTypeIncome;

  /// No description provided for @recurringBillsTypeBill.
  ///
  /// In es, this message translates to:
  /// **'Factura'**
  String get recurringBillsTypeBill;

  /// No description provided for @recurringBillsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo fijo'**
  String get recurringBillsNewTitle;

  /// No description provided for @recurringBillsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar fijo'**
  String get recurringBillsEditTitle;

  /// No description provided for @recurringBillsMissingFields.
  ///
  /// In es, this message translates to:
  /// **'Completa el nombre, monto, categoría y cuenta.'**
  String get recurringBillsMissingFields;

  /// No description provided for @recurringBillsSemimonthlyDayTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un día hasta el 15'**
  String get recurringBillsSemimonthlyDayTitle;

  /// No description provided for @recurringBillsSemimonthlyDayMessage.
  ///
  /// In es, this message translates to:
  /// **'Una quincenal se repite 15 días después de la primera fecha. Elige el primer pago entre el 1 y el 15 del mes - por ejemplo el 15 para cobrar el 15 y el 30.'**
  String get recurringBillsSemimonthlyDayMessage;

  /// No description provided for @recurringBillsDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar fijo'**
  String get recurringBillsDelete;

  /// No description provided for @recurringBillsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\" y dejará de anotarse. Los movimientos que ya creó se quedan. Esta acción no se puede deshacer. Si solo quieres detenerlo un tiempo, ponlo en pausa.'**
  String recurringBillsDeleteMessage(String name);

  /// No description provided for @recurringBillsNoCategories.
  ///
  /// In es, this message translates to:
  /// **'No hay categorías de este tipo todavía. Créalas en Ajustes.'**
  String get recurringBillsNoCategories;

  /// No description provided for @recurringBillsNoAccounts.
  ///
  /// In es, this message translates to:
  /// **'No hay cuentas todavía. Créalas en Ajustes.'**
  String get recurringBillsNoAccounts;

  /// No description provided for @recurringBillsSelectAccount.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una cuenta'**
  String get recurringBillsSelectAccount;

  /// No description provided for @recurringBillsRepeats.
  ///
  /// In es, this message translates to:
  /// **'Cada cuánto'**
  String get recurringBillsRepeats;

  /// Start date field label when editing an existing bill.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get recurringBillsFrom;

  /// End date field label.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get recurringBillsUntil;

  /// No description provided for @recurringBillsNoEndDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de fin'**
  String get recurringBillsNoEndDate;

  /// No description provided for @recurringBillsRemoveEndDate.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha de fin'**
  String get recurringBillsRemoveEndDate;

  /// No description provided for @recurringBillsPaused.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get recurringBillsPaused;

  /// No description provided for @recurringBillsPausedHint.
  ///
  /// In es, this message translates to:
  /// **'No se anota mientras esté en pausa. Al reanudarlo, las fechas que pasaron no se anotan.'**
  String get recurringBillsPausedHint;

  /// No description provided for @recurringBillsFrequencyWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get recurringBillsFrequencyWeekly;

  /// No description provided for @recurringBillsFrequencyBiweekly.
  ///
  /// In es, this message translates to:
  /// **'Cada 2 semanas'**
  String get recurringBillsFrequencyBiweekly;

  /// Twice a month: on a day and 15 days later.
  ///
  /// In es, this message translates to:
  /// **'Quincenal'**
  String get recurringBillsFrequencySemimonthly;

  /// No description provided for @recurringBillsFrequencyMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get recurringBillsFrequencyMonthly;

  /// No description provided for @recurringBillsFrequencyYearly.
  ///
  /// In es, this message translates to:
  /// **'Anual'**
  String get recurringBillsFrequencyYearly;

  /// A weekly item's schedule. {weekday} is monday, tuesday... sunday.
  ///
  /// In es, this message translates to:
  /// **'{weekday, select, monday{Cada lunes} tuesday{Cada martes} wednesday{Cada miércoles} thursday{Cada jueves} friday{Cada viernes} saturday{Cada sábado} other{Cada domingo}}'**
  String recurringBillsScheduleWeekly(String weekday);

  /// An every-2-weeks item's schedule. {weekday} is monday, tuesday... sunday.
  ///
  /// In es, this message translates to:
  /// **'{weekday, select, monday{Cada 2 semanas, los lunes} tuesday{Cada 2 semanas, los martes} wednesday{Cada 2 semanas, los miércoles} thursday{Cada 2 semanas, los jueves} friday{Cada 2 semanas, los viernes} saturday{Cada 2 semanas, los sábados} other{Cada 2 semanas, los domingos}}'**
  String recurringBillsScheduleBiweekly(String weekday);

  /// No description provided for @recurringBillsScheduleSemimonthly.
  ///
  /// In es, this message translates to:
  /// **'Días {day} y {secondDay}'**
  String recurringBillsScheduleSemimonthly(int day, int secondDay);

  /// No description provided for @recurringBillsScheduleMonthly.
  ///
  /// In es, this message translates to:
  /// **'Cada mes, día {day}'**
  String recurringBillsScheduleMonthly(int day);

  /// {date} is the localized month and day, e.g. '3 de marzo'.
  ///
  /// In es, this message translates to:
  /// **'Cada año, {date}'**
  String recurringBillsScheduleYearly(String date);

  /// {schedule} is a recurringBillsSchedule* text; {date} a short day and month, e.g. '15 dic'.
  ///
  /// In es, this message translates to:
  /// **'{schedule}, hasta el {date}'**
  String recurringBillsScheduleUntil(String schedule, String date);

  /// Under the schedule in the edit form. {kind} is 'average' when the amount is a monthly average (weekly, yearly...), 'exact' otherwise.
  ///
  /// In es, this message translates to:
  /// **'{kind, select, average{Unos {amount} al mes} other{{amount} al mes}}'**
  String recurringBillsMonthlyCost(String kind, String amount);

  /// No description provided for @monthlyNotesTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas del mes'**
  String get monthlyNotesTitle;

  /// No description provided for @monthlyNotesThisMonth.
  ///
  /// In es, this message translates to:
  /// **'Notas de este mes'**
  String get monthlyNotesThisMonth;

  /// No description provided for @monthlyNotesNextMonth.
  ///
  /// In es, this message translates to:
  /// **'Para el mes siguiente'**
  String get monthlyNotesNextMonth;

  /// No description provided for @monthlyNotesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nada escrito todavía. Toca para escribir.'**
  String get monthlyNotesEmpty;

  /// No description provided for @monthlyNotesWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get monthlyNotesWrite;

  /// No description provided for @monthlyNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Lo que no cabe en números.'**
  String get monthlyNotesHint;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar todo como leído'**
  String get notificationsMarkAllRead;

  /// Screen-reader label for the violet dot after an unread notification's title.
  ///
  /// In es, this message translates to:
  /// **'Sin leer'**
  String get notificationsUnread;

  /// No description provided for @notificationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aquí llegan los pagos que se acercan, las metas que van bien, lo que se pasa del presupuesto y lo que anota tu pareja.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todo tranquilo.'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Elegir qué avisar'**
  String get notificationsEmptyAction;

  /// No description provided for @notificationsMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {minutes} min'**
  String notificationsMinutesAgo(int minutes);

  /// No description provided for @notificationsHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {hours} h'**
  String notificationsHoursAgo(int hours);

  /// No description provided for @notificationsYesterday.
  ///
  /// In es, this message translates to:
  /// **'ayer'**
  String get notificationsYesterday;

  /// Stored in-app notification, written in the language of the device that detects it; {name} is the debt's name.
  ///
  /// In es, this message translates to:
  /// **'Hoy pagas {name}'**
  String notificationsDebtDueTodayTitle(String name);

  /// No description provided for @notificationsDebtDueTodayBody.
  ///
  /// In es, this message translates to:
  /// **'Hoy es el día de pago de tu deuda {name}.'**
  String notificationsDebtDueTodayBody(String name);

  /// No description provided for @notificationsDebtDueSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago de {name} pronto'**
  String notificationsDebtDueSoonTitle(String name);

  /// No description provided for @notificationsDebtDueSoonBody.
  ///
  /// In es, this message translates to:
  /// **'La cuota de {name} vence en {days, plural, =1{1 día} other{{days} días}}.'**
  String notificationsDebtDueSoonBody(String name, int days);

  /// No description provided for @notificationsGoalNearTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Casi logras tu meta!'**
  String get notificationsGoalNearTitle;

  /// No description provided for @notificationsGoalNearBody.
  ///
  /// In es, this message translates to:
  /// **'{name} va en {percent}%.'**
  String notificationsGoalNearBody(String name, int percent);

  /// No description provided for @notificationsBudgetExceededTitle.
  ///
  /// In es, this message translates to:
  /// **'Te pasaste del presupuesto'**
  String get notificationsBudgetExceededTitle;

  /// No description provided for @notificationsBudgetExceededBody.
  ///
  /// In es, this message translates to:
  /// **'{category} superó lo planeado este mes.'**
  String notificationsBudgetExceededBody(String category);

  /// Stands in for {category} in notificationsBudgetExceededBody when the category is gone.
  ///
  /// In es, this message translates to:
  /// **'una categoría'**
  String get notificationsUnknownCategory;

  /// No description provided for @notificationsContributionTitle.
  ///
  /// In es, this message translates to:
  /// **'Aporte registrado'**
  String get notificationsContributionTitle;

  /// No description provided for @notificationsContributionBody.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja agregó un aporte a {goal}.'**
  String notificationsContributionBody(String goal);

  /// No description provided for @notificationsPartnerMovementTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get notificationsPartnerMovementTitle;

  /// No description provided for @notificationsPartnerMovementBody.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja registró un movimiento.'**
  String get notificationsPartnerMovementBody;

  /// No description provided for @notificationsPartnerTransferTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva transferencia'**
  String get notificationsPartnerTransferTitle;

  /// No description provided for @notificationsPartnerTransferBody.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja registró una transferencia entre cuentas.'**
  String get notificationsPartnerTransferBody;

  /// No description provided for @notificationsPartnerDebtTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva deuda'**
  String get notificationsPartnerDebtTitle;

  /// No description provided for @notificationsPartnerAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get notificationsPartnerAccountTitle;

  /// No description provided for @notificationsPartnerInvestmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva inversión'**
  String get notificationsPartnerInvestmentTitle;

  /// No description provided for @notificationsPartnerBillTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo fijo'**
  String get notificationsPartnerBillTitle;

  /// No description provided for @notificationsPartnerCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get notificationsPartnerCategoryTitle;

  /// No description provided for @notificationsPartnerChallengeTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo reto de ahorro'**
  String get notificationsPartnerChallengeTitle;

  /// No description provided for @notificationsPartnerGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva meta de ahorro'**
  String get notificationsPartnerGoalTitle;

  /// No description provided for @notificationPrefsTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué avisar'**
  String get notificationPrefsTitle;

  /// No description provided for @notificationPrefsIntro.
  ///
  /// In es, this message translates to:
  /// **'Solo para ti: {name} elige los suyos.'**
  String notificationPrefsIntro(String name);

  /// No description provided for @notificationPrefsIntroSolo.
  ///
  /// In es, this message translates to:
  /// **'Solo para ti: cada quien elige los suyos.'**
  String get notificationPrefsIntroSolo;

  /// No description provided for @notificationPrefsDailyReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio para anotar'**
  String get notificationPrefsDailyReminder;

  /// No description provided for @notificationPrefsDailyReminderWhen.
  ///
  /// In es, this message translates to:
  /// **'Todos los días, a esta hora'**
  String get notificationPrefsDailyReminderWhen;

  /// No description provided for @notificationPrefsDailyReminderTimeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar la hora'**
  String get notificationPrefsDailyReminderTimeTooltip;

  /// No description provided for @notificationPrefsDebtPayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos que se acercan'**
  String get notificationPrefsDebtPayments;

  /// No description provided for @notificationPrefsDebtPaymentsWhen.
  ///
  /// In es, this message translates to:
  /// **'3, 2 y 1 día antes, y el mismo día'**
  String get notificationPrefsDebtPaymentsWhen;

  /// No description provided for @notificationPrefsGoalProgress.
  ///
  /// In es, this message translates to:
  /// **'Avance de metas'**
  String get notificationPrefsGoalProgress;

  /// No description provided for @notificationPrefsGoalProgressWhen.
  ///
  /// In es, this message translates to:
  /// **'Una vez, cuando una meta pasa el 90%'**
  String get notificationPrefsGoalProgressWhen;

  /// No description provided for @notificationPrefsBudgetExceeded.
  ///
  /// In es, this message translates to:
  /// **'Categoría que se pasa'**
  String get notificationPrefsBudgetExceeded;

  /// No description provided for @notificationPrefsBudgetExceededWhen.
  ///
  /// In es, this message translates to:
  /// **'Una vez por categoría y mes'**
  String get notificationPrefsBudgetExceededWhen;

  /// No description provided for @notificationPrefsPartnerActivity.
  ///
  /// In es, this message translates to:
  /// **'Lo que anota tu pareja'**
  String get notificationPrefsPartnerActivity;

  /// No description provided for @notificationPrefsPartnerActivityNamed.
  ///
  /// In es, this message translates to:
  /// **'Lo que anota {name}'**
  String notificationPrefsPartnerActivityNamed(String name);

  /// No description provided for @notificationPrefsPartnerActivityWhen.
  ///
  /// In es, this message translates to:
  /// **'Cada movimiento, cuenta o meta nueva'**
  String get notificationPrefsPartnerActivityWhen;

  /// No description provided for @notificationPrefsWeeklySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get notificationPrefsWeeklySummary;

  /// {time} is a localized time of day, e.g. '7:00 p. m.'.
  ///
  /// In es, this message translates to:
  /// **'Los domingos, {time}'**
  String notificationPrefsWeeklySummaryWhen(String time);

  /// No description provided for @exportTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get exportTitle;

  /// No description provided for @exportPeriod.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get exportPeriod;

  /// The months a report covers, e.g. 'Agosto – octubre 2026'.
  ///
  /// In es, this message translates to:
  /// **'{from} – {to}'**
  String exportPeriodRange(String from, String to);

  /// No description provided for @exportPeriodThisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get exportPeriodThisMonth;

  /// No description provided for @exportPeriodQuarter.
  ///
  /// In es, this message translates to:
  /// **'3 meses'**
  String get exportPeriodQuarter;

  /// No description provided for @exportPeriodYear.
  ///
  /// In es, this message translates to:
  /// **'12 meses'**
  String get exportPeriodYear;

  /// No description provided for @exportInclude.
  ///
  /// In es, this message translates to:
  /// **'Qué incluir'**
  String get exportInclude;

  /// Toggle and report section; also names its CSV file.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get exportTransactions;

  /// Toggle and report section; also names its CSV file.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get exportBudget;

  /// No description provided for @exportDebtsAndSavings.
  ///
  /// In es, this message translates to:
  /// **'Deudas y metas'**
  String get exportDebtsAndSavings;

  /// No description provided for @exportPdfTitle.
  ///
  /// In es, this message translates to:
  /// **'PDF'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfFor.
  ///
  /// In es, this message translates to:
  /// **'Para leer o imprimir, con los montos con formato.'**
  String get exportPdfFor;

  /// No description provided for @exportCsvTitle.
  ///
  /// In es, this message translates to:
  /// **'CSV para hoja de cálculo'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvFor.
  ///
  /// In es, this message translates to:
  /// **'Un archivo por sección, con números limpios y fechas AAAA-MM-DD.'**
  String get exportCsvFor;

  /// No description provided for @exportOnDevice.
  ///
  /// In es, this message translates to:
  /// **'El archivo se arma en este teléfono con los datos ya descifrados: nada sale de aquí hasta que lo compartes.'**
  String get exportOnDevice;

  /// No description provided for @exportAction.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get exportAction;

  /// Report section; also names its CSV file.
  ///
  /// In es, this message translates to:
  /// **'Deudas'**
  String get exportDebts;

  /// Report section; also names its CSV file.
  ///
  /// In es, this message translates to:
  /// **'Metas de ahorro'**
  String get exportSavingsGoals;

  /// File name of the shared PDF; keep it ASCII, no spaces.
  ///
  /// In es, this message translates to:
  /// **'finan2_reporte.pdf'**
  String get exportPdfFileName;

  /// No description provided for @exportNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos para este período.'**
  String get exportNoData;

  /// No description provided for @exportColumnType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get exportColumnType;

  /// CSV column: the member who paid.
  ///
  /// In es, this message translates to:
  /// **'Pagó'**
  String get exportColumnPaidBy;

  /// No description provided for @exportColumnTags.
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get exportColumnTags;

  /// No description provided for @exportColumnPlanned.
  ///
  /// In es, this message translates to:
  /// **'Planeado'**
  String get exportColumnPlanned;

  /// Budget column: what was actually spent.
  ///
  /// In es, this message translates to:
  /// **'Real'**
  String get exportColumnActual;

  /// No description provided for @exportColumnBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo'**
  String get exportColumnBalance;

  /// Effective annual interest rate (E.A.).
  ///
  /// In es, this message translates to:
  /// **'Tasa E.A.'**
  String get exportColumnRate;

  /// No description provided for @exportColumnRatePercent.
  ///
  /// In es, this message translates to:
  /// **'Tasa E.A. (%)'**
  String get exportColumnRatePercent;

  /// No description provided for @exportColumnSaved.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado'**
  String get exportColumnSaved;

  /// No description provided for @exportColumnTarget.
  ///
  /// In es, this message translates to:
  /// **'Meta'**
  String get exportColumnTarget;

  /// No description provided for @exportColumnCompleted.
  ///
  /// In es, this message translates to:
  /// **'% Completado'**
  String get exportColumnCompleted;

  /// No description provided for @exportColumnCompletedPercent.
  ///
  /// In es, this message translates to:
  /// **'Completado (%)'**
  String get exportColumnCompletedPercent;

  /// No description provided for @backupTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get backupTitle;

  /// No description provided for @backupDescription.
  ///
  /// In es, this message translates to:
  /// **'Todo el hogar en un archivo cifrado con la llave de la casa. Sin la llave no se puede leer: se puede guardar en el correo o en la nube.'**
  String get backupDescription;

  /// No description provided for @backupCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear copia ahora'**
  String get backupCreate;

  /// No description provided for @backupRestoreAction.
  ///
  /// In es, this message translates to:
  /// **'Restaurar una copia'**
  String get backupRestoreAction;

  /// No description provided for @backupRestoreLead.
  ///
  /// In es, this message translates to:
  /// **'Al restaurar'**
  String get backupRestoreLead;

  /// Follows backupRestoreLead, which is shown in bold; keep the leading comma.
  ///
  /// In es, this message translates to:
  /// **', el hogar vuelve a como estaba ese día para los dos: lo creado después se borra. Solo funciona en este mismo hogar.'**
  String get backupRestoreNote;

  /// No description provided for @backupErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar'**
  String get backupErrorTitle;

  /// File name of the shared backup; {date} is YYYY-MM-DD. Keep it ASCII and the .finan2 extension.
  ///
  /// In es, this message translates to:
  /// **'finan2-copia-{date}.finan2'**
  String backupFileName(String date);

  /// No description provided for @backupRestoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar la copia'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreMessage.
  ///
  /// In es, this message translates to:
  /// **'El hogar volverá a como estaba el {date}. Lo que se haya creado después se borra y lo que cambió vuelve a como estaba, también para tu pareja.'**
  String backupRestoreMessage(String date);

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get backupRestoreConfirm;

  /// No description provided for @backupRestoredTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia restaurada'**
  String get backupRestoredTitle;

  /// No description provided for @backupRestoredSummary.
  ///
  /// In es, this message translates to:
  /// **'{restored, plural, =1{1 registro restaurado} other{{restored} registros restaurados}}.'**
  String backupRestoredSummary(int restored);

  /// No description provided for @backupRestoredSummaryWithRemoved.
  ///
  /// In es, this message translates to:
  /// **'{restored, plural, =1{1 registro restaurado} other{{restored} registros restaurados}} y {removed, plural, =1{1 posterior borrado} other{{removed} posteriores borrados}}.'**
  String backupRestoredSummaryWithRemoved(int restored, int removed);

  /// No description provided for @backupReattributed.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 registro de tu pareja que se había borrado queda a tu nombre: solo puedes crear registros como tuyos. En los movimientos se conserva quién pagó.} other{{count} registros de tu pareja que se habían borrado quedan a tu nombre: solo puedes crear registros como tuyos. En los movimientos se conserva quién pagó.}}'**
  String backupReattributed(int count);

  /// No description provided for @backupErrorOtherHousehold.
  ///
  /// In es, this message translates to:
  /// **'Esta copia es de otro hogar. Solo se puede restaurar en el hogar donde se hizo.'**
  String get backupErrorOtherHousehold;

  /// No description provided for @backupErrorDamaged.
  ///
  /// In es, this message translates to:
  /// **'La copia está dañada o se modificó. No se puede abrir.'**
  String get backupErrorDamaged;

  /// No description provided for @backupErrorNewerVersion.
  ///
  /// In es, this message translates to:
  /// **'Esta copia se hizo con una versión más nueva de Finan2. Actualiza la app.'**
  String get backupErrorNewerVersion;

  /// No description provided for @backupErrorNotABackup.
  ///
  /// In es, this message translates to:
  /// **'Este archivo no es una copia de seguridad de Finan2.'**
  String get backupErrorNotABackup;

  /// No description provided for @backupErrorUnsupportedType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de dato no soportado en la copia: {type}'**
  String backupErrorUnsupportedType(String type);

  /// Plan tab: the segment with the month's budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get planBudget;

  /// Right of a budget line: what is still there to spend, already formatted.
  ///
  /// In es, this message translates to:
  /// **'quedan {amount}'**
  String budgetLeft(String amount);

  /// Right of a budget line spent exactly to its plan.
  ///
  /// In es, this message translates to:
  /// **'Completo'**
  String get budgetComplete;

  /// Right of a budget line with spending and nothing planned.
  ///
  /// In es, this message translates to:
  /// **'sin plan'**
  String get budgetUnplanned;

  /// Small line under a budget line: spent of the plan.
  ///
  /// In es, this message translates to:
  /// **'{spent} de {limit}'**
  String budgetSpentOf(String spent, String limit);

  /// No description provided for @budgetSpentNoPlan.
  ///
  /// In es, this message translates to:
  /// **'{spent} gastado'**
  String budgetSpentNoPlan(String spent);

  /// Notice on top of the budget when one category went over.
  ///
  /// In es, this message translates to:
  /// **'{category} se pasó {amount}'**
  String budgetOverTitle(String category, String amount);

  /// No description provided for @budgetOverManyTitle.
  ///
  /// In es, this message translates to:
  /// **'{count} categorías se pasaron'**
  String budgetOverManyTitle(int count);

  /// No description provided for @budgetOverMessage.
  ///
  /// In es, this message translates to:
  /// **'Sale de lo que queda del plan.'**
  String get budgetOverMessage;

  /// No description provided for @budgetOverManyMessage.
  ///
  /// In es, this message translates to:
  /// **'{category} es la que más: {amount}.'**
  String budgetOverManyMessage(String category, String amount);

  /// Line under the budget: total planned against what came in.
  ///
  /// In es, this message translates to:
  /// **'{planned} planeado · faltan {amount} por asignar'**
  String budgetPlannedRemaining(String planned, String amount);

  /// No description provided for @budgetPlannedOver.
  ///
  /// In es, this message translates to:
  /// **'{planned} planeado · {amount} más de lo que entró'**
  String budgetPlannedOver(String planned, String amount);

  /// No description provided for @budgetPlannedNoIncome.
  ///
  /// In es, this message translates to:
  /// **'{planned} planeado · aún no entra nada este mes'**
  String budgetPlannedNoIncome(String planned);

  /// Over the total of every goal, with two members.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado entre los dos'**
  String get goalsSavedTogether;

  /// Under the goals total: goals with a date that are on time.
  ///
  /// In es, this message translates to:
  /// **'van a tiempo en {onTime} de {dated} metas'**
  String goalsOnTime(int onTime, int dated);

  /// No description provided for @goalsToGo.
  ///
  /// In es, this message translates to:
  /// **'faltan {amount} para completarlas'**
  String goalsToGo(String amount);

  /// A goal's line: saved of target, then its date (or «sin fecha» / «va atrasada»).
  ///
  /// In es, this message translates to:
  /// **'{saved} de {target} · {when}'**
  String goalRowLine(String saved, String target, String when);

  /// No description provided for @goalFor.
  ///
  /// In es, this message translates to:
  /// **'para {date}'**
  String goalFor(String date);

  /// Notice under the goals summing up the debts.
  ///
  /// In es, this message translates to:
  /// **'Deudas: libres en {date}'**
  String goalsDebtsFree(String date);

  /// No description provided for @goalsDebtsStuck.
  ///
  /// In es, this message translates to:
  /// **'Deudas: con los pagos actuales no se terminan'**
  String get goalsDebtsStuck;

  /// No description provided for @goalsDebtsOrder.
  ///
  /// In es, this message translates to:
  /// **'Primero {first}, luego {second}.'**
  String goalsDebtsOrder(String first, String second);

  /// No description provided for @goalsDebtsOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo queda {name}.'**
  String goalsDebtsOnly(String name);

  /// Goal detail, in green: on time at this monthly pace.
  ///
  /// In es, this message translates to:
  /// **'Van a tiempo: {amount} al mes'**
  String goalOnTimePace(String amount);

  /// No description provided for @goalBehindPace.
  ///
  /// In es, this message translates to:
  /// **'Van atrasados: hacen falta {amount} al mes'**
  String goalBehindPace(String amount);

  /// No description provided for @goalReached.
  ///
  /// In es, this message translates to:
  /// **'¡Meta cumplida!'**
  String get goalReached;

  /// No description provided for @goalOfFor.
  ///
  /// In es, this message translates to:
  /// **'de {target} · {when}'**
  String goalOfFor(String target, String when);

  /// No description provided for @goalInterest.
  ///
  /// In es, this message translates to:
  /// **'Incluye {amount} de intereses'**
  String goalInterest(String amount);

  /// No description provided for @goalContributionOf.
  ///
  /// In es, this message translates to:
  /// **'Aporte de {month}'**
  String goalContributionOf(String month);

  /// Action of the new-goal form.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get goalCreate;

  /// New goal: what it takes each month to get there.
  ///
  /// In es, this message translates to:
  /// **'{amount} al mes'**
  String goalNeededTitle(String amount);

  /// No description provided for @goalNeededMessage.
  ///
  /// In es, this message translates to:
  /// **'Es lo que hace falta para llegar en {date}.'**
  String goalNeededMessage(String date);

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @debtsLeftAvalanche.
  ///
  /// In es, this message translates to:
  /// **'quedan {amount} · orden Avalancha (primero la tasa más alta)'**
  String debtsLeftAvalanche(String amount);

  /// A card in the debts list: rate, minimum payment, payment day.
  ///
  /// In es, this message translates to:
  /// **'{rate}% · mín. {amount} · día {day}'**
  String debtsRowCard(String rate, String amount, int day);

  /// No description provided for @debtsRowLoan.
  ///
  /// In es, this message translates to:
  /// **'{rate}% · cuota {amount} · día {day}'**
  String debtsRowLoan(String rate, String amount, int day);

  /// Badge on the first debt of the Avalanche order.
  ///
  /// In es, this message translates to:
  /// **'1.º'**
  String get debtsFirst;

  /// No description provided for @debtsNextTitle.
  ///
  /// In es, this message translates to:
  /// **'Próximo pago: {name}, {date}'**
  String debtsNextTitle(String name, String date);

  /// No description provided for @debtsNextMinSuggested.
  ///
  /// In es, this message translates to:
  /// **'{min} mínimo · sugerido {suggested}'**
  String debtsNextMinSuggested(String min, String suggested);

  /// No description provided for @debtsNextMin.
  ///
  /// In es, this message translates to:
  /// **'{min} mínimo'**
  String debtsNextMin(String min);

  /// No description provided for @debtsDetailSub.
  ///
  /// In es, this message translates to:
  /// **'de {reference} · {pct}% pagado · {status}'**
  String debtsDetailSub(String reference, int pct, String status);

  /// No description provided for @debtsRateOnly.
  ///
  /// In es, this message translates to:
  /// **'Tasa {rate}% E.A.'**
  String debtsRateOnly(String rate);

  /// No description provided for @debtsRateExtra.
  ///
  /// In es, this message translates to:
  /// **'Tasa {rate}% E.A. · abono extra {amount}'**
  String debtsRateExtra(String rate, String amount);

  /// No description provided for @debtsPaidBy.
  ///
  /// In es, this message translates to:
  /// **'Pagado por'**
  String get debtsPaidBy;

  /// Next debt payment: how soon it is due.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =0{hoy} =1{mañana} other{en {days} días}}'**
  String debtsInDays(int days);

  /// No description provided for @debtsDeletePaymentMessage.
  ///
  /// In es, this message translates to:
  /// **'Se quitará el pago de {amount} del {date}.'**
  String debtsDeletePaymentMessage(String amount, String date);

  /// No description provided for @challengeSavedIn.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado en el reto'**
  String get challengeSavedIn;

  /// No description provided for @challengeCells.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} casillas · meta {target}'**
  String challengeCells(int done, int total, String target);

  /// No description provided for @challengeNextTitle.
  ///
  /// In es, this message translates to:
  /// **'Siguiente: {amount}'**
  String challengeNextTitle(String amount);

  /// No description provided for @challengeNextMessage.
  ///
  /// In es, this message translates to:
  /// **'Márcala cuando la aporten.'**
  String get challengeNextMessage;

  /// No description provided for @challengeMark.
  ///
  /// In es, this message translates to:
  /// **'Marcar'**
  String get challengeMark;

  /// No description provided for @challengeDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Reto completo'**
  String get challengeDoneTitle;

  /// No description provided for @challengeDoneMessage.
  ///
  /// In es, this message translates to:
  /// **'Ahorraron {amount}.'**
  String challengeDoneMessage(String amount);

  /// No description provided for @annualTitleYear.
  ///
  /// In es, this message translates to:
  /// **'Resumen {year}'**
  String annualTitleYear(int year);

  /// No description provided for @annualAverage.
  ///
  /// In es, this message translates to:
  /// **'prom. {amount}'**
  String annualAverage(String amount);

  /// No description provided for @annualHighestTitle.
  ///
  /// In es, this message translates to:
  /// **'{month} fue el mes más alto'**
  String annualHighestTitle(String month);

  /// No description provided for @annualHighestReason.
  ///
  /// In es, this message translates to:
  /// **'{category}: {amount} más que en un mes normal.'**
  String annualHighestReason(String category, String amount);

  /// No description provided for @accountsAvailableLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponible entre las cuentas'**
  String get accountsAvailableLabel;

  /// No description provided for @accountsAvailableNote.
  ///
  /// In es, this message translates to:
  /// **'las tarjetas y créditos no suman aquí'**
  String get accountsAvailableNote;

  /// No description provided for @accountsCards.
  ///
  /// In es, this message translates to:
  /// **'Tarjetas'**
  String get accountsCards;

  /// No description provided for @accountsRowExcluded.
  ///
  /// In es, this message translates to:
  /// **'{type} · no suma en «Disponible»'**
  String accountsRowExcluded(String type);

  /// No description provided for @accountsIncludeHint.
  ///
  /// In es, this message translates to:
  /// **'Apágalo para cuentas que no se tocan, como un ahorro aparte.'**
  String get accountsIncludeHint;

  /// No description provided for @accountsAdd.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get accountsAdd;

  /// No description provided for @commonCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get commonCreate;

  /// No description provided for @debtsFormTitle.
  ///
  /// In es, this message translates to:
  /// **'{type, select, tarjeta{Tarjeta de crédito} credito{Crédito} hipoteca{Hipoteca} vehiculo{Crédito de vehículo} other{Deuda}}'**
  String debtsFormTitle(String type);

  /// No description provided for @debtsCardDays.
  ///
  /// In es, this message translates to:
  /// **'Corte día {cutoff} · paga día {day}'**
  String debtsCardDays(int cutoff, int day);

  /// No description provided for @debtsCardPayDay.
  ///
  /// In es, this message translates to:
  /// **'Paga día {day}'**
  String debtsCardPayDay(int day);

  /// No description provided for @debtsCardPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Tu tarjeta'**
  String get debtsCardPlaceholder;

  /// No description provided for @debtsOwedToday.
  ///
  /// In es, this message translates to:
  /// **'Cuánto deben hoy'**
  String get debtsOwedToday;

  /// No description provided for @debtsEndsIn.
  ///
  /// In es, this message translates to:
  /// **'Terminan en {date}'**
  String debtsEndsIn(String date);

  /// No description provided for @debtsEndsSooner.
  ///
  /// In es, this message translates to:
  /// **'Si abonan {amount} más al mes: {date}.'**
  String debtsEndsSooner(String amount, String date);

  /// No description provided for @debtsNeverEnds.
  ///
  /// In es, this message translates to:
  /// **'Con esa cuota no se termina de pagar'**
  String get debtsNeverEnds;

  /// No description provided for @debtsNeverEndsHint.
  ///
  /// In es, this message translates to:
  /// **'Los intereses se comen el pago: suban la cuota o abonen más.'**
  String get debtsNeverEndsHint;

  /// No description provided for @investmentsWorthToday.
  ///
  /// In es, this message translates to:
  /// **'Valen hoy'**
  String get investmentsWorthToday;

  /// No description provided for @investmentsPutIn.
  ///
  /// In es, this message translates to:
  /// **'pusieron {amount}'**
  String investmentsPutIn(String amount);

  /// No description provided for @investmentsGaining.
  ///
  /// In es, this message translates to:
  /// **'ganan'**
  String get investmentsGaining;

  /// No description provided for @investmentsLosing.
  ///
  /// In es, this message translates to:
  /// **'pierden'**
  String get investmentsLosing;

  /// No description provided for @investmentsManualNote.
  ///
  /// In es, this message translates to:
  /// **'Se actualizan a mano: la app no se conecta a ningún banco.'**
  String get investmentsManualNote;

  /// No description provided for @investmentsAdd.
  ///
  /// In es, this message translates to:
  /// **'Nueva inversión'**
  String get investmentsAdd;

  /// No description provided for @transfersRowTo.
  ///
  /// In es, this message translates to:
  /// **'A {name}'**
  String transfersRowTo(String name);

  /// No description provided for @transfersRowFrom.
  ///
  /// In es, this message translates to:
  /// **'de {name} · {date}'**
  String transfersRowFrom(String name, String date);

  /// No description provided for @transfersHas.
  ///
  /// In es, this message translates to:
  /// **'tiene {amount}'**
  String transfersHas(String amount);

  /// No description provided for @transfersLeaves.
  ///
  /// In es, this message translates to:
  /// **'queda {amount}'**
  String transfersLeaves(String amount);

  /// No description provided for @transfersNotExpense.
  ///
  /// In es, this message translates to:
  /// **'No es un gasto: no toca el presupuesto.'**
  String get transfersNotExpense;

  /// No description provided for @transfersSwap.
  ///
  /// In es, this message translates to:
  /// **'Invertir el sentido'**
  String get transfersSwap;

  /// No description provided for @demoSeed.
  ///
  /// In es, this message translates to:
  /// **'Llenar con datos de prueba'**
  String get demoSeed;

  /// No description provided for @demoRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar datos de prueba'**
  String get demoRemove;

  /// No description provided for @demoSeedTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Llenar con datos de prueba?'**
  String get demoSeedTitle;

  /// No description provided for @demoSeedMessage.
  ///
  /// In es, this message translates to:
  /// **'Se añaden tres meses de cuentas, una tarjeta, un crédito, metas, inversiones, fijos y movimientos inventados. Lo que ya tienen no se toca, y no avisan a nadie.'**
  String get demoSeedMessage;

  /// No description provided for @demoSeedConfirm.
  ///
  /// In es, this message translates to:
  /// **'Llenar'**
  String get demoSeedConfirm;

  /// No description provided for @demoSeedDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get demoSeedDoneTitle;

  /// No description provided for @demoSeedDone.
  ///
  /// In es, this message translates to:
  /// **'Se escribieron {count} registros de prueba.'**
  String demoSeedDone(int count);

  /// No description provided for @demoRemoveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar los datos de prueba?'**
  String get demoRemoveTitle;

  /// No description provided for @demoRemoveMessage.
  ///
  /// In es, this message translates to:
  /// **'Se borra solo lo inventado. Lo que anotaron ustedes se queda.'**
  String get demoRemoveMessage;

  /// No description provided for @demoRemoveConfirm.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get demoRemoveConfirm;

  /// No description provided for @demoRemoveDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Quitados'**
  String get demoRemoveDoneTitle;

  /// No description provided for @demoRemoveDone.
  ///
  /// In es, this message translates to:
  /// **'Se borraron {count} registros de prueba.'**
  String demoRemoveDone(int count);

  /// No description provided for @demoError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo terminar. Revisa la conexión y vuelve a intentarlo: se puede repetir sin duplicar nada.'**
  String get demoError;
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
