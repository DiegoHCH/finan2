// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Finan2';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get commonUndo => 'Deshacer';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonGotIt => 'Entendido';

  @override
  String get commonNotNow => 'Ahora no';

  @override
  String get commonName => 'Nombre';

  @override
  String get commonAmount => 'Monto';

  @override
  String get commonDate => 'Fecha';

  @override
  String get commonDescription => 'Descripción';

  @override
  String get commonCategory => 'Categoría';

  @override
  String get commonAccount => 'Cuenta';

  @override
  String get recurringBillsTitle => 'Facturas recurrentes';

  @override
  String recurringBillsMonthlyTotal(String amount) {
    return '$amount al mes';
  }

  @override
  String get recurringBillsAutoBadge => 'Auto';

  @override
  String get recurringBillsEmptyTitle => 'Aún no hay facturas recurrentes';

  @override
  String get recurringBillsEmptyDescription =>
      'Programa el arriendo, servicios o el sueldo para que se registren solos cada mes.';

  @override
  String get recurringBillsEmptyAction => '+ Nueva factura recurrente';

  @override
  String get recurringBillsAutoLogged => 'Se registran solas';

  @override
  String recurringBillsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas',
      one: '1 activa',
    );
    return '$_temp0';
  }

  @override
  String get recurringBillsStatusPaused => 'en pausa';

  @override
  String get recurringBillsStatusEnded => 'terminada';

  @override
  String get recurringBillsTypeIncome => 'Ingreso';

  @override
  String get recurringBillsTypeBill => 'Factura';

  @override
  String get recurringBillsNewTitle => 'Nueva factura recurrente';

  @override
  String get recurringBillsEditTitle => 'Editar factura recurrente';

  @override
  String get recurringBillsMissingFields => 'Completa el nombre, monto, categoría y cuenta.';

  @override
  String get recurringBillsSemimonthlyDayTitle => 'Elige un día hasta el 15';

  @override
  String get recurringBillsSemimonthlyDayMessage =>
      'Una quincenal se repite 15 días después de la primera fecha. Elige el primer pago entre el 1 y el 15 del mes - por ejemplo el 15 para cobrar el 15 y el 30.';

  @override
  String get recurringBillsDelete => 'Eliminar factura recurrente';

  @override
  String recurringBillsDeleteMessage(String name) {
    return 'Se eliminará \"$name\" y dejará de generarse. Los movimientos que ya creó se quedan. Esta acción no se puede deshacer. Si solo quieres detenerla un tiempo, ponla en pausa.';
  }

  @override
  String get recurringBillsNoCategories =>
      'No hay categorías de este tipo todavía. Créalas en Ajustes.';

  @override
  String get recurringBillsNoAccounts => 'No hay cuentas todavía. Créalas en Ajustes.';

  @override
  String get recurringBillsSelectAccount => 'Selecciona una cuenta';

  @override
  String get recurringBillsRepeats => 'Se repite';

  @override
  String get recurringBillsFrom => 'Desde';

  @override
  String get recurringBillsFirstTime => 'Primera vez';

  @override
  String recurringBillsLoggedOn(String schedule) {
    return 'Se registra $schedule.';
  }

  @override
  String get recurringBillsUntil => 'Hasta';

  @override
  String get recurringBillsNoEndDate => 'Sin fecha de fin';

  @override
  String get recurringBillsRemoveEndDate => 'Quitar fecha de fin';

  @override
  String get recurringBillsPaused => 'En pausa';

  @override
  String get recurringBillsPausedHint =>
      'No se registra mientras esté en pausa. Al reanudarla, las fechas que pasaron no se registran.';

  @override
  String get recurringBillsFrequencyWeekly => 'Semanal';

  @override
  String get recurringBillsFrequencyBiweekly => 'Cada 2 semanas';

  @override
  String get recurringBillsFrequencySemimonthly => 'Quincenal';

  @override
  String get recurringBillsFrequencyMonthly => 'Mensual';

  @override
  String get recurringBillsFrequencyYearly => 'Anual';

  @override
  String recurringBillsScheduleWeekly(String weekday) {
    return 'cada $weekday';
  }

  @override
  String recurringBillsScheduleBiweekly(String weekday) {
    return 'cada 2 semanas, los $weekday';
  }

  @override
  String recurringBillsScheduleSemimonthly(int day, int secondDay) {
    return 'días $day y $secondDay';
  }

  @override
  String recurringBillsScheduleMonthly(String day) {
    return 'cada mes, día $day';
  }

  @override
  String recurringBillsScheduleYearly(String date) {
    return 'cada año, $date';
  }

  @override
  String get monthlyNotesTitle => 'Notas';

  @override
  String get monthlyNotesThisMonth => 'Notas de este mes';

  @override
  String get monthlyNotesNextMonth => 'Para el siguiente mes';

  @override
  String get monthlyNotesEmpty => 'Toca para agregar notas.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String notificationsNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevas',
      one: '1 nueva',
    );
    return '$_temp0';
  }

  @override
  String get notificationsUpToDate => 'Al día';

  @override
  String get notificationsMarkAllRead => 'Marcar leídas';

  @override
  String get notificationsEmpty =>
      'Aún no hay notificaciones. Aquí verás avisos de pagos, metas y presupuesto.';

  @override
  String notificationsMinutesAgo(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String notificationsHoursAgo(int hours) {
    return 'Hace $hours h';
  }

  @override
  String get notificationsToday => 'Hoy';

  @override
  String get notificationsYesterday => 'Ayer';

  @override
  String notificationsDaysAgo(int days) {
    return 'Hace $days d';
  }

  @override
  String notificationsDebtDueTodayTitle(String name) {
    return 'Hoy pagas $name';
  }

  @override
  String notificationsDebtDueTodayBody(String name) {
    return 'Hoy es el día de pago de tu deuda $name.';
  }

  @override
  String notificationsDebtDueSoonTitle(String name) {
    return 'Pago de $name pronto';
  }

  @override
  String notificationsDebtDueSoonBody(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'La cuota de $name vence en $_temp0.';
  }

  @override
  String get notificationsGoalNearTitle => '¡Casi logras tu meta!';

  @override
  String notificationsGoalNearBody(String name, int percent) {
    return '$name va en $percent%.';
  }

  @override
  String get notificationsBudgetExceededTitle => 'Te pasaste del presupuesto';

  @override
  String notificationsBudgetExceededBody(String category) {
    return '$category superó lo planeado este mes.';
  }

  @override
  String get notificationsUnknownCategory => 'una categoría';

  @override
  String get notificationsContributionTitle => 'Aporte registrado';

  @override
  String notificationsContributionBody(String goal) {
    return 'Tu pareja agregó un aporte a $goal.';
  }

  @override
  String get notificationsPartnerMovementTitle => 'Nuevo movimiento';

  @override
  String get notificationsPartnerMovementBody => 'Tu pareja registró un movimiento.';

  @override
  String get notificationsPartnerTransferTitle => 'Nueva transferencia';

  @override
  String get notificationsPartnerTransferBody =>
      'Tu pareja registró una transferencia entre cuentas.';

  @override
  String get notificationsPartnerDebtTitle => 'Nueva deuda';

  @override
  String get notificationsPartnerAccountTitle => 'Nueva cuenta';

  @override
  String get notificationsPartnerInvestmentTitle => 'Nueva inversión';

  @override
  String get notificationsPartnerBillTitle => 'Nueva factura recurrente';

  @override
  String get notificationsPartnerCategoryTitle => 'Nueva categoría';

  @override
  String get notificationsPartnerChallengeTitle => 'Nuevo reto de ahorro';

  @override
  String get notificationsPartnerGoalTitle => 'Nueva meta de ahorro';

  @override
  String get notificationPrefsTitle => 'Preferencias';

  @override
  String get notificationPrefsRemindersHeader => 'RECORDATORIOS';

  @override
  String get notificationPrefsDailyReminder => 'Recordatorio diario';

  @override
  String get notificationPrefsDebtPayments => 'Pagos de deudas';

  @override
  String get notificationPrefsGoalProgress => 'Avance de metas';

  @override
  String get notificationPrefsAlertsHeader => 'ALERTAS';

  @override
  String get notificationPrefsBudgetExceeded => 'Exceso de presupuesto';

  @override
  String get notificationPrefsPartnerActivity => 'Actividad de mi pareja';

  @override
  String get notificationPrefsWeeklySummary => 'Resumen semanal';

  @override
  String get exportTitle => 'Exportar reporte';

  @override
  String get exportSubtitle => 'PDF o CSV';

  @override
  String get exportCsvHint =>
      'Un archivo por sección, con montos sin formato y fechas AAAA-MM-DD, listo para una hoja de cálculo.';

  @override
  String get exportPeriod => 'Periodo';

  @override
  String get exportPeriodThisMonth => 'Este mes';

  @override
  String get exportPeriodQuarter => 'Trimestre';

  @override
  String get exportPeriodYear => 'Año';

  @override
  String get exportInclude => 'Incluir en el reporte';

  @override
  String get exportTransactions => 'Movimientos';

  @override
  String get exportBudget => 'Presupuesto';

  @override
  String get exportDebtsAndSavings => 'Deudas y ahorros';

  @override
  String get exportDebts => 'Deudas';

  @override
  String get exportSavingsGoals => 'Metas de ahorro';

  @override
  String get exportGeneratePdf => 'Generar PDF';

  @override
  String get exportGenerateCsv => 'Generar CSV';

  @override
  String get exportPdfFileName => 'finan2_reporte.pdf';

  @override
  String get exportNoData => 'Sin datos para este período.';

  @override
  String get exportColumnType => 'Tipo';

  @override
  String get exportColumnPaidBy => 'Pagó';

  @override
  String get exportColumnTags => 'Etiquetas';

  @override
  String get exportColumnPlanned => 'Planeado';

  @override
  String get exportColumnActual => 'Real';

  @override
  String get exportColumnBalance => 'Saldo';

  @override
  String get exportColumnRate => 'Tasa E.A.';

  @override
  String get exportColumnRatePercent => 'Tasa E.A. (%)';

  @override
  String get exportColumnSaved => 'Ahorrado';

  @override
  String get exportColumnTarget => 'Meta';

  @override
  String get exportColumnCompleted => '% Completado';

  @override
  String get exportColumnCompletedPercent => 'Completado (%)';

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get backupSubtitle => 'Todo el hogar, cifrado';

  @override
  String get backupDescription =>
      'La copia guarda cuentas, movimientos, presupuestos, deudas, metas, facturas recurrentes y notas en un archivo cifrado con la llave del hogar. Sin esa llave no se puede leer, así que puedes guardarlo en tu correo o en la nube.';

  @override
  String get backupSameHouseholdOnly => 'Solo se puede restaurar en este mismo hogar.';

  @override
  String get backupCreate => 'Crear copia';

  @override
  String get backupRestoreAction => 'Restaurar una copia';

  @override
  String get backupErrorTitle => 'No se pudo completar';

  @override
  String backupFileName(String date) {
    return 'finan2-copia-$date.finan2';
  }

  @override
  String get backupRestoreTitle => 'Restaurar la copia';

  @override
  String backupRestoreMessage(String date) {
    return 'El hogar volverá a como estaba el $date. Lo que se haya creado después se borra y lo que cambió vuelve a como estaba, también para tu pareja.';
  }

  @override
  String get backupRestoreConfirm => 'Restaurar';

  @override
  String get backupRestoredTitle => 'Copia restaurada';

  @override
  String backupRestoredSummary(int restored) {
    String _temp0 = intl.Intl.pluralLogic(
      restored,
      locale: localeName,
      other: '$restored registros restaurados',
      one: '1 registro restaurado',
    );
    return '$_temp0.';
  }

  @override
  String backupRestoredSummaryWithRemoved(int restored, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      restored,
      locale: localeName,
      other: '$restored registros restaurados',
      one: '1 registro restaurado',
    );
    String _temp1 = intl.Intl.pluralLogic(
      removed,
      locale: localeName,
      other: '$removed posteriores borrados',
      one: '1 posterior borrado',
    );
    return '$_temp0 y $_temp1.';
  }

  @override
  String backupReattributed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count registros de tu pareja que se habían borrado quedan a tu nombre: solo puedes crear registros como tuyos. En los movimientos se conserva quién pagó.',
      one:
          '1 registro de tu pareja que se había borrado queda a tu nombre: solo puedes crear registros como tuyos. En los movimientos se conserva quién pagó.',
    );
    return '$_temp0';
  }

  @override
  String get backupErrorOtherHousehold =>
      'Esta copia es de otro hogar. Solo se puede restaurar en el hogar donde se hizo.';

  @override
  String get backupErrorDamaged => 'La copia está dañada o se modificó. No se puede abrir.';

  @override
  String get backupErrorNewerVersion =>
      'Esta copia se hizo con una versión más nueva de Finan2. Actualiza la app.';

  @override
  String get backupErrorNotABackup => 'Este archivo no es una copia de seguridad de Finan2.';

  @override
  String backupErrorUnsupportedType(String type) {
    return 'Tipo de dato no soportado en la copia: $type';
  }
}
