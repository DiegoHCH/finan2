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
