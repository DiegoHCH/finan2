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
