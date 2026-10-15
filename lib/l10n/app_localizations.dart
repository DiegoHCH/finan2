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

  /// No description provided for @recurringBillsTitle.
  ///
  /// In es, this message translates to:
  /// **'Facturas recurrentes'**
  String get recurringBillsTitle;

  /// Header: the monthly total of active recurring bills, already formatted as money.
  ///
  /// In es, this message translates to:
  /// **'{amount} al mes'**
  String recurringBillsMonthlyTotal(String amount);

  /// Badge meaning the bills are logged automatically.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get recurringBillsAutoBadge;

  /// No description provided for @recurringBillsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay facturas recurrentes'**
  String get recurringBillsEmptyTitle;

  /// No description provided for @recurringBillsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Programa el arriendo, servicios o el sueldo para que se registren solos cada mes.'**
  String get recurringBillsEmptyDescription;

  /// No description provided for @recurringBillsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Nueva factura recurrente'**
  String get recurringBillsEmptyAction;

  /// No description provided for @recurringBillsAutoLogged.
  ///
  /// In es, this message translates to:
  /// **'Se registran solas'**
  String get recurringBillsAutoLogged;

  /// How many recurring bills are active (feminine: 'facturas').
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 activa} other{{count} activas}}'**
  String recurringBillsActiveCount(int count);

  /// Row status, lowercase, after the type: 'Factura · en pausa'.
  ///
  /// In es, this message translates to:
  /// **'en pausa'**
  String get recurringBillsStatusPaused;

  /// Row status, lowercase, after the type: 'Factura · terminada'.
  ///
  /// In es, this message translates to:
  /// **'terminada'**
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
  /// **'Nueva factura recurrente'**
  String get recurringBillsNewTitle;

  /// No description provided for @recurringBillsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar factura recurrente'**
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
  /// **'Eliminar factura recurrente'**
  String get recurringBillsDelete;

  /// No description provided for @recurringBillsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\" y dejará de generarse. Los movimientos que ya creó se quedan. Esta acción no se puede deshacer. Si solo quieres detenerla un tiempo, ponla en pausa.'**
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
  /// **'Se repite'**
  String get recurringBillsRepeats;

  /// Start date field label when editing an existing bill.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get recurringBillsFrom;

  /// Start date field label when creating a bill: its first occurrence.
  ///
  /// In es, this message translates to:
  /// **'Primera vez'**
  String get recurringBillsFirstTime;

  /// Hint under the start date; {schedule} is a recurringBillsSchedule* text, e.g. 'cada lunes'.
  ///
  /// In es, this message translates to:
  /// **'Se registra {schedule}.'**
  String recurringBillsLoggedOn(String schedule);

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
  /// **'No se registra mientras esté en pausa. Al reanudarla, las fechas que pasaron no se registran.'**
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

  /// Lowercase schedule fragment; {weekday} is the localized day name.
  ///
  /// In es, this message translates to:
  /// **'cada {weekday}'**
  String recurringBillsScheduleWeekly(String weekday);

  /// No description provided for @recurringBillsScheduleBiweekly.
  ///
  /// In es, this message translates to:
  /// **'cada 2 semanas, los {weekday}'**
  String recurringBillsScheduleBiweekly(String weekday);

  /// No description provided for @recurringBillsScheduleSemimonthly.
  ///
  /// In es, this message translates to:
  /// **'días {day} y {secondDay}'**
  String recurringBillsScheduleSemimonthly(int day, int secondDay);

  /// {day} is the day of the month, two digits.
  ///
  /// In es, this message translates to:
  /// **'cada mes, día {day}'**
  String recurringBillsScheduleMonthly(String day);

  /// {date} is the localized month and day, e.g. '3 de marzo'.
  ///
  /// In es, this message translates to:
  /// **'cada año, {date}'**
  String recurringBillsScheduleYearly(String date);

  /// No description provided for @monthlyNotesTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get monthlyNotesTitle;

  /// No description provided for @monthlyNotesThisMonth.
  ///
  /// In es, this message translates to:
  /// **'Notas de este mes'**
  String get monthlyNotesThisMonth;

  /// No description provided for @monthlyNotesNextMonth.
  ///
  /// In es, this message translates to:
  /// **'Para el siguiente mes'**
  String get monthlyNotesNextMonth;

  /// No description provided for @monthlyNotesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Toca para agregar notas.'**
  String get monthlyNotesEmpty;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// Unread notifications count (feminine: 'notificaciones').
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 nueva} other{{count} nuevas}}'**
  String notificationsNewCount(int count);

  /// Shown when there are no unread notifications.
  ///
  /// In es, this message translates to:
  /// **'Al día'**
  String get notificationsUpToDate;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar leídas'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay notificaciones. Aquí verás avisos de pagos, metas y presupuesto.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes} min'**
  String notificationsMinutesAgo(int minutes);

  /// No description provided for @notificationsHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours} h'**
  String notificationsHoursAgo(int hours);

  /// No description provided for @notificationsToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get notificationsYesterday;

  /// No description provided for @notificationsDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {days} d'**
  String notificationsDaysAgo(int days);

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
  /// **'Nueva factura recurrente'**
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
  /// **'Preferencias'**
  String get notificationPrefsTitle;

  /// No description provided for @notificationPrefsRemindersHeader.
  ///
  /// In es, this message translates to:
  /// **'RECORDATORIOS'**
  String get notificationPrefsRemindersHeader;

  /// No description provided for @notificationPrefsDailyReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio diario'**
  String get notificationPrefsDailyReminder;

  /// No description provided for @notificationPrefsDebtPayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos de deudas'**
  String get notificationPrefsDebtPayments;

  /// No description provided for @notificationPrefsGoalProgress.
  ///
  /// In es, this message translates to:
  /// **'Avance de metas'**
  String get notificationPrefsGoalProgress;

  /// No description provided for @notificationPrefsAlertsHeader.
  ///
  /// In es, this message translates to:
  /// **'ALERTAS'**
  String get notificationPrefsAlertsHeader;

  /// No description provided for @notificationPrefsBudgetExceeded.
  ///
  /// In es, this message translates to:
  /// **'Exceso de presupuesto'**
  String get notificationPrefsBudgetExceeded;

  /// No description provided for @notificationPrefsPartnerActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad de mi pareja'**
  String get notificationPrefsPartnerActivity;

  /// No description provided for @notificationPrefsWeeklySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get notificationPrefsWeeklySummary;

  /// No description provided for @exportTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar reporte'**
  String get exportTitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'PDF o CSV'**
  String get exportSubtitle;

  /// No description provided for @exportCsvHint.
  ///
  /// In es, this message translates to:
  /// **'Un archivo por sección, con montos sin formato y fechas AAAA-MM-DD, listo para una hoja de cálculo.'**
  String get exportCsvHint;

  /// No description provided for @exportPeriod.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get exportPeriod;

  /// No description provided for @exportPeriodThisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get exportPeriodThisMonth;

  /// No description provided for @exportPeriodQuarter.
  ///
  /// In es, this message translates to:
  /// **'Trimestre'**
  String get exportPeriodQuarter;

  /// No description provided for @exportPeriodYear.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get exportPeriodYear;

  /// No description provided for @exportInclude.
  ///
  /// In es, this message translates to:
  /// **'Incluir en el reporte'**
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
  /// **'Deudas y ahorros'**
  String get exportDebtsAndSavings;

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

  /// No description provided for @exportGeneratePdf.
  ///
  /// In es, this message translates to:
  /// **'Generar PDF'**
  String get exportGeneratePdf;

  /// No description provided for @exportGenerateCsv.
  ///
  /// In es, this message translates to:
  /// **'Generar CSV'**
  String get exportGenerateCsv;

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

  /// No description provided for @backupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Todo el hogar, cifrado'**
  String get backupSubtitle;

  /// No description provided for @backupDescription.
  ///
  /// In es, this message translates to:
  /// **'La copia guarda cuentas, movimientos, presupuestos, deudas, metas, facturas recurrentes y notas en un archivo cifrado con la llave del hogar. Sin esa llave no se puede leer, así que puedes guardarlo en tu correo o en la nube.'**
  String get backupDescription;

  /// No description provided for @backupSameHouseholdOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo se puede restaurar en este mismo hogar.'**
  String get backupSameHouseholdOnly;

  /// No description provided for @backupCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear copia'**
  String get backupCreate;

  /// No description provided for @backupRestoreAction.
  ///
  /// In es, this message translates to:
  /// **'Restaurar una copia'**
  String get backupRestoreAction;

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
