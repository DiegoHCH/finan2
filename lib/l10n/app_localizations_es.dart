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
  String budgetTitle(String month) {
    return 'Presupuesto · $month';
  }

  @override
  String budgetPlannedTotal(String amount) {
    return '$amount planeado';
  }

  @override
  String budgetAssignedPct(int pct) {
    return '$pct% asignado';
  }

  @override
  String get budgetPreviousMonth => 'Mes anterior';

  @override
  String get budgetNextMonth => 'Mes siguiente';

  @override
  String get budgetLeftToBudget => 'Falta por presupuestar';

  @override
  String get budgetNoIncomeYet => 'Registra ingresos este mes';

  @override
  String get budgetOverBudgeted => 'Presupuestado de más';

  @override
  String get budgetVsActual => 'Presupuesto vs. real';

  @override
  String get budgetEmpty => 'Aún no has presupuestado ninguna categoría.';

  @override
  String get budgetAddCategory => '+ Presupuestar otra categoría';

  @override
  String budgetForCategory(String category) {
    return 'Presupuesto para $category';
  }

  @override
  String get budgetCopyTitle => 'Este mes aún no tiene presupuesto';

  @override
  String budgetCopyMessage(int count, String month) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copia las $count categorías que planeaste en $month.',
      one: 'Copia la categoría que planeaste en $month.',
    );
    return '$_temp0';
  }

  @override
  String get budgetCopying => 'Copiando…';

  @override
  String budgetCarryIncluded(String amount) {
    return 'Incluye $amount que sobró antes';
  }

  @override
  String budgetCarryDeducted(String amount) {
    return 'Descuenta $amount que te pasaste antes';
  }

  @override
  String get annualSummaryTitle => 'Resumen anual';

  @override
  String get annualSummaryPreviousYear => 'Año anterior';

  @override
  String get annualSummaryNextYear => 'Año siguiente';

  @override
  String get annualSummaryEarned => 'Ganado';

  @override
  String get annualSummarySpent => 'Gastado';

  @override
  String get annualSummarySaved => 'Ahorrado';

  @override
  String get annualSummarySpendByMonth => 'Gasto por mes';

  @override
  String get dashboardHousehold => 'Hogar';

  @override
  String get dashboardNetWorth => 'Patrimonio neto';

  @override
  String get dashboardNetWorthFormula => 'Cuentas + ahorros + inversiones − deudas';

  @override
  String get dashboardIncome => 'Ingresos';

  @override
  String get dashboardExpenses => 'Gastos';

  @override
  String get dashboardWhereMoneyGoes => 'A dónde va el dinero';

  @override
  String get dashboardNoCategorizedSpending => 'No hay gastos categorizados este mes.';

  @override
  String get savingsChallengeTitle => 'Reto de ahorro';

  @override
  String get savingsChallengeDeleteTitle => 'Eliminar reto de ahorro';

  @override
  String savingsChallengeDeleteMessage(String name) {
    return 'Se eliminará \"$name\" y el progreso marcado. Esta acción no se puede deshacer.';
  }

  @override
  String get savingsChallengeIntro =>
      'Crea el reto de ahorro del hogar: casillas con montos fijos que van marcando a medida que las ahorran.';

  @override
  String get savingsChallengeSize => 'Tamaño';

  @override
  String get savingsChallengeSizeSmall => 'Chico';

  @override
  String get savingsChallengeSizeMedium => 'Mediano';

  @override
  String get savingsChallengeSizeLarge => 'Grande';

  @override
  String savingsChallengeSizeOption(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count casillas',
      one: '1 casilla',
    );
    return '$size ($_temp0)';
  }

  @override
  String get savingsChallengeCreate => 'Crear reto';

  @override
  String get savingsChallengeGoal => '¡Tú puedes! Meta del reto';

  @override
  String get savingsChallengeProgress => 'Progreso';

  @override
  String get savingsChallengeMarkHint => 'Marca cada casilla al ahorrar';

  @override
  String get authLoginWelcome => 'Bienvenido a Finan';

  @override
  String get authLoginSubtitle =>
      'Entra con tu cuenta. Cada quien tiene la suya; las finanzas del hogar son compartidas.';

  @override
  String get authEmailLabel => 'Correo';

  @override
  String get authEmailInvalid => 'Ingresa un correo válido';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authOr => 'o';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authCreateAccountHere => 'Créala aquí';

  @override
  String get authResetPasswordTitle => 'Recuperar contraseña';

  @override
  String get authResetPasswordMessage =>
      'Te enviamos un enlace a tu correo para elegir una contraseña nueva.';

  @override
  String get authResetPasswordSend => 'Enviar';

  @override
  String get authResetPasswordSentTitle => 'Correo enviado';

  @override
  String authResetPasswordSentMessage(String email) {
    return 'Si $email tiene una cuenta, te llegará un correo para recuperarla.';
  }

  @override
  String get authSignupTitle => 'Crea tu cuenta';

  @override
  String get authSignupSubtitle => 'Regístrate para empezar a organizar las finanzas del hogar.';

  @override
  String get authNameRequired => 'Ingresa tu nombre';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get authSignInLink => 'Inicia sesión';

  @override
  String get householdDefaultName => 'Nuestro hogar';

  @override
  String get householdCreateJoinTitle => 'Un último paso';

  @override
  String get householdCreateJoinSubtitle =>
      'Crea el hogar desde cero o únete al que ya tiene tu pareja.';

  @override
  String get householdCreateOptionTitle => 'Crear un hogar nuevo';

  @override
  String get householdCreateOptionSubtitle => 'Empiezas de cero e invitas a tu pareja.';

  @override
  String get householdJoinOptionTitle => 'Unirme con un código';

  @override
  String get householdJoinOptionSubtitle => 'Tu pareja ya creó el hogar.';

  @override
  String get householdNameLabel => 'Nombre del hogar';

  @override
  String get householdNameRequired => 'Ponle un nombre a tu hogar';

  @override
  String get householdCodeLabel => 'Código del hogar (pega el código completo)';

  @override
  String get householdCodeRequired => 'Ingresa el código que te compartieron';

  @override
  String get householdCreateButton => 'Crear hogar';

  @override
  String get householdJoinButton => 'Entrar al hogar';

  @override
  String get householdJoinedWithoutKeyTitle => 'Te uniste al hogar';

  @override
  String get householdJoinedWithoutKeyMessage =>
      'Este código no traía la llave para ver montos. Pide a tu pareja que te comparta el código completo desde la tarjeta del hogar en Ajustes.';

  @override
  String householdSetupStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get householdSetupCurrencyTitle => 'Moneda del hogar';

  @override
  String get householdSetupCurrencyDescription =>
      'En la que llevan las cuentas. Se puede cambiar en Ajustes.';

  @override
  String get householdCurrencyCop => 'Peso colombiano';

  @override
  String get householdCurrencyUsd => 'Dólar estadounidense';

  @override
  String get householdSetupAccountTitle => 'Tu primera cuenta';

  @override
  String get householdSetupAccountDescription =>
      'De donde sale y a donde llega la plata: el banco, una billetera o el efectivo. Pon lo que tiene hoy para empezar con el saldo real.';

  @override
  String get householdSetupAccountNameMissingTitle => 'Ponle un nombre';

  @override
  String get householdSetupAccountNameMissingMessage =>
      'Por ejemplo el banco o «Efectivo». Si prefieres, omite este paso.';

  @override
  String get householdSetupBalanceToday => 'Saldo de hoy';

  @override
  String get householdSetupCreateAccount => 'Crear cuenta';

  @override
  String get householdRecoveryPhraseTitle => 'Frase de recuperación';

  @override
  String get householdSetupRecoveryDescription =>
      'Los montos se cifran con una llave que vive solo en sus teléfonos. Si los dos la pierden, estas 12 palabras la recuperan. Se muestran una sola vez: anótalas en papel y guárdalas con tu pareja.';

  @override
  String get householdGeneratePhrase => 'Generar frase';

  @override
  String get householdSetupLater => 'Más tarde, desde Ajustes';

  @override
  String get householdInviteTitle => 'Invita a tu pareja';

  @override
  String get householdInviteMessage =>
      'Comparte este código para que entre con su propia cuenta al mismo hogar. Sirve una sola vez y vence en 7 días.';

  @override
  String get householdInviteWarning =>
      'Usa el botón de compartir y envíalo por WhatsApp o mensaje - no lo dictes de viva voz, lleva pegada una llave más larga que no se ve aquí. Sin el código completo, tu pareja no podrá ver los montos.';

  @override
  String get householdInviteShareSubject => 'Invitación a nuestro hogar en Finan2';

  @override
  String get householdInviteShare => 'Compartir invitación';

  @override
  String get householdInviteSkip => 'Omitir por ahora';

  @override
  String get householdRecoveryConfirmMessage =>
      'Si algún día ninguno de los dos tiene la llave del hogar en su dispositivo, estas 12 palabras permiten recuperar los montos. Vas a verlas una sola vez: anótalas en papel y guárdalas con tu pareja. Si ya había una frase o un PIN, dejarán de servir.';

  @override
  String get householdRecoverySavedTitle => 'Frase guardada';

  @override
  String get householdRecoverySavedMessage =>
      'Desde ahora esta frase permite recuperar los montos del hogar en cualquier dispositivo.';

  @override
  String householdRecoverySaveFailed(String error) {
    return 'No se pudo guardar la frase nueva, así que no sirve: la anterior sigue siendo la válida. $error';
  }

  @override
  String get householdRecoveryShowTitle => 'Anota estas 12 palabras';

  @override
  String get householdRecoveryShowMessage =>
      'En este orden. No se vuelven a mostrar y Finan2 no las guarda.';

  @override
  String get householdRecoveryShowDone => 'Ya las anoté';

  @override
  String get householdKeyIncomplete =>
      'Ese código no trae la llave completa. Pide a tu pareja que lo comparta de nuevo desde la tarjeta del hogar en Ajustes.';

  @override
  String get householdKeyWrongHousehold =>
      'Esa llave no es de este hogar. Revisa que el código sea el que tu pareja compartió desde este mismo hogar.';

  @override
  String get householdRecoveryNotSet =>
      'Este hogar no tiene una frase de recuperación configurada.';

  @override
  String get householdRecoveryPhraseMismatch =>
      'Esa frase no corresponde a este hogar. Si tu pareja generó una nueva, la anterior dejó de servir.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsHeading => 'Configuración';

  @override
  String get settingsMissingKeyBanner =>
      'Este dispositivo no tiene la llave para ver los montos de este hogar. Pega el código que tu pareja compartió desde su tarjeta del hogar, o escribe la frase de recuperación.';

  @override
  String get settingsPasteCodeToUnlock => 'Pegar código para desbloquear montos';

  @override
  String get settingsUseRecoveryPhrase => 'Usar frase de recuperación';

  @override
  String get settingsStorageWarning =>
      'Tu navegador no garantizó que los datos de Finan2 se conserven. Si no abres la app por varios días, podrías perder el acceso a los montos cifrados de este dispositivo. Asegúrate de tener una frase de recuperación en Ajustes de la cuenta.';

  @override
  String settingsMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get settingsTapToInvite => 'toca para invitar';

  @override
  String get settingsTapToShareKey => 'toca para compartir la llave';

  @override
  String get settingsFinancialSettings => 'Ajustes financieros';

  @override
  String get settingsFinancialSettingsSubtitle => 'Moneda, año y categorías';

  @override
  String get settingsAccountSettings => 'Ajustes de la cuenta';

  @override
  String get settingsAccountSettingsSubtitle => 'Hogar y notificaciones';

  @override
  String get settingsExportReport => 'Exportar reporte';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsBudget => 'Presupuesto';

  @override
  String settingsBudgetPlanned(String amount) {
    return '$amount planeado';
  }

  @override
  String get settingsAnnualSummary => 'Resumen anual';

  @override
  String get settingsInvestments => 'Inversiones';

  @override
  String get settingsNotificationCenter => 'Centro de notificaciones';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsUnlockAmountsTitle => 'Desbloquear montos';

  @override
  String get settingsUnlockAmountsMessage =>
      'Pega el código completo (con la llave después del punto) que tu pareja copió desde su tarjeta del hogar en Ajustes.';

  @override
  String get settingsUnlockCodeLabel => 'Código completo (CODIGO.llave)';

  @override
  String get settingsUnlock => 'Desbloquear';

  @override
  String get settingsAmountsUnlockedTitle => 'Montos desbloqueados';

  @override
  String get settingsAmountsUnlockedMessage => 'Ya puedes ver los montos de este hogar.';

  @override
  String get settingsRecoveryPhraseMessage =>
      'Escribe las 12 palabras en orden, separadas por espacios. Las tildes y las mayúsculas no importan.';

  @override
  String get settingsRecoveryPhraseLabel => 'Frase (12 palabras)';

  @override
  String get settingsNoKeyToInvite =>
      'Este dispositivo no tiene la llave del hogar, así que no puede invitar a nadie que vea los montos.';

  @override
  String get settingsNoKeyToShare => 'Este dispositivo tampoco tiene la llave del hogar.';

  @override
  String get settingsKeyShareSubject => 'Llave de nuestro hogar en Finan2';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLightSubtitle => 'Siempre fondo claro.';

  @override
  String get settingsThemeDarkSubtitle => 'Siempre fondo oscuro.';

  @override
  String get settingsThemeSystemSubtitle => 'Sigue el ajuste de tu dispositivo.';

  @override
  String get settingsLeaveHousehold => 'Salir del hogar';

  @override
  String settingsLeaveHouseholdSoloMessage(String name) {
    return 'Eres el único miembro de \"$name\". Si sales, se borrarán para siempre todos sus datos: cuentas, movimientos, presupuestos, deudas y metas.';
  }

  @override
  String settingsLeaveHouseholdMessage(String name) {
    return 'Vas a salir de \"$name\". Tus cuentas, movimientos y demás datos seguirán disponibles para el resto del hogar. Podrás crear o unirte a otro hogar después.';
  }

  @override
  String get settingsLeaveAndDelete => 'Salir y borrar';

  @override
  String get settingsLeave => 'Salir';

  @override
  String get settingsMyName => 'Mi nombre';

  @override
  String get settingsHouseholdMembers => 'Miembros del hogar';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsRecoveryPhraseHint => 'Recuperar montos si pierden la llave';

  @override
  String get settingsDeleteAccount => 'Eliminar mi cuenta';

  @override
  String settingsDeleteAccountSoloMessage(String name) {
    return 'Perderás el acceso a Finan2 de forma permanente y no se puede deshacer. Como eres el único miembro, también se borrarán todos los datos de \"$name\".';
  }

  @override
  String get settingsDeleteAccountMessage =>
      'Perderás el acceso a Finan2 de forma permanente y no se puede deshacer. También saldrás de tu hogar - sus datos seguirán disponibles para el otro miembro.';

  @override
  String get settingsCurrencyCop => 'Peso COP · \$';

  @override
  String get settingsCurrencyUsd => 'Dólar USD · US\$';

  @override
  String get settingsWeekMonday => 'Lunes';

  @override
  String get settingsWeekSunday => 'Domingo';

  @override
  String get settingsPickActiveYear => 'Selecciona el año activo';

  @override
  String get settingsCurrency => 'Moneda';

  @override
  String get settingsActiveYear => 'Año activo';

  @override
  String get settingsWeekStartsOn => 'La semana inicia en';

  @override
  String get settingsCategories => 'Categorías';

  @override
  String get settingsAccounts => 'Cuentas';

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
