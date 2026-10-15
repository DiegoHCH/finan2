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
  String get coreSheetErrorTitle => 'Algo salió mal';

  @override
  String get coreReauthTitle => 'Confirma tu contraseña';

  @override
  String get corePassword => 'Contraseña';

  @override
  String get corePeriodPrevious => 'Anterior';

  @override
  String get corePeriodBackToToday => 'Volver a hoy';

  @override
  String get coreGoToSettings => 'Ir a Ajustes';

  @override
  String get coreMissingKeyInline => 'Falta la llave de este hogar para ver estos montos.';

  @override
  String get coreMissingKeyTitle => 'Falta la llave de este hogar';

  @override
  String get coreMissingKeyBody =>
      'Este dispositivo no puede ver ni registrar montos todavía. Pide a tu pareja el código completo (con la llave después del punto) o usa la frase de recuperación del hogar en Ajustes para desbloquearlos.';

  @override
  String get coreNotificationPrimerTitle => 'Activa las notificaciones';

  @override
  String get coreNotificationPrimerBody =>
      'Te avisamos cuando tu pareja registre algo, se acerque una fecha de pago, o se pasen del presupuesto. Puedes ajustar esto después en Ajustes.';

  @override
  String get coreNotificationPrimerEnable => 'Activar notificaciones';

  @override
  String get coreInstallBanner =>
      'Para recibir notificaciones y que tus datos no se borren solos, instala Finan2: toca Compartir y luego \"Agregar a inicio\".';

  @override
  String get coreHomeTabHome => 'Inicio';

  @override
  String get coreHomeTabMovements => 'Movimientos';

  @override
  String get coreHomeTabDebts => 'Deudas';

  @override
  String get coreHomeTabGoals => 'Metas';

  @override
  String get coreHomeTabSettings => 'Ajustes';

  @override
  String get coreSplashTagline => 'Finanzas del hogar - para dos';

  @override
  String get errorInvalidEmail => 'El correo no es válido.';

  @override
  String get errorWrongCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get errorEmailInUse => 'Ya existe una cuenta con ese correo.';

  @override
  String get errorWeakPassword => 'La contraseña es muy débil.';

  @override
  String get errorNetwork => 'Problema de conexión, intenta de nuevo.';

  @override
  String errorUnknownWithCode(String code) {
    return 'Algo salió mal ($code).';
  }

  @override
  String get errorInviteNotFound =>
      'Esa invitación no existe o ya venció. Pide a tu pareja una nueva desde Ajustes.';

  @override
  String get errorHouseholdFull =>
      'No pudimos unirte: el hogar ya tiene 2 miembros o la invitación dejó de ser válida.';

  @override
  String get errorGeneric => 'Algo salió mal, intenta de nuevo.';

  @override
  String get errorMissingKey =>
      'Este dispositivo no tiene la llave para ver los montos de este hogar. Pide a tu pareja el código de invitación completo.';

  @override
  String errorRecoveryPhraseWordCount(int expected, int typed) {
    return 'La frase debe tener $expected palabras (escribiste $typed).';
  }

  @override
  String errorRecoveryPhraseUnknownWord(String word) {
    return '\"$word\" no es una palabra de la frase. Revisa que esté bien escrita.';
  }

  @override
  String get errorRecoveryPhraseInvalid =>
      'La frase no es válida. Revisa que las palabras estén en el orden correcto y bien escritas.';

  @override
  String get validationPasswordPolicy => 'Mínimo 8 caracteres, con una mayúscula y una minúscula';

  @override
  String get reminderDailyChannel => 'Recordatorio diario';

  @override
  String get reminderDailyTitle => 'Registra tus gastos de hoy';

  @override
  String get reminderDailyBody => 'No olvides anotar lo que ingresó o gastó el hogar hoy.';

  @override
  String get reminderWeeklyChannel => 'Resumen semanal';

  @override
  String get reminderWeeklyTitle => 'Resumen semanal listo';

  @override
  String get reminderWeeklyBody => 'Revisa cómo le fue al hogar esta semana en Finan2.';

  @override
  String get reminderDebtChannel => 'Pagos de deudas';

  @override
  String reminderDebtTodayTitle(String debt) {
    return 'Hoy pagas $debt';
  }

  @override
  String reminderDebtTodayBody(String debt) {
    return 'Hoy es el día de pago de tu deuda $debt.';
  }

  @override
  String reminderDebtSoonTitle(String debt) {
    return 'Pago de $debt pronto';
  }

  @override
  String reminderDebtSoonBody(String debt, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'La cuota de $debt vence en $_temp0.';
  }

  @override
  String get reminderActivityChannel => 'Actividad del hogar';
}
