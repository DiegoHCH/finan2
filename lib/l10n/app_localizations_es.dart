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
  String get budgetPreviousMonth => 'Mes anterior';

  @override
  String get budgetNextMonth => 'Mes siguiente';

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
  String budgetEmptyTitle(String month) {
    return '$month todavía no tiene plan.';
  }

  @override
  String get budgetEmptyDescription =>
      'Pongan cuánto quieren gastar en cada categoría y aquí verán lo que les queda de cada una.';

  @override
  String get budgetEmptyAction => 'Planear una categoría';

  @override
  String budgetEmptyCopy(String month) {
    return 'Copiar el plan de $month';
  }

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
  String get annualSummaryEarned => 'Entró';

  @override
  String get annualSummarySpent => 'Salió';

  @override
  String get annualSummarySaved => 'Ahorrado';

  @override
  String get annualSummarySpendByMonth => 'Gasto por mes';

  @override
  String get dashboardNoCategorizedSpending => 'No hay gastos categorizados este mes.';

  @override
  String get dashboardDecrypting => 'Descifrando los montos en este teléfono…';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String dashboardLeftOfPlan(String month) {
    return 'Les queda del plan de $month';
  }

  @override
  String dashboardOverPlan(String month) {
    return 'Se pasaron del plan de $month';
  }

  @override
  String dashboardSpentIn(String month) {
    return 'Gastado en $month';
  }

  @override
  String dashboardOfPlan(String amount) {
    return 'de $amount';
  }

  @override
  String dashboardDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'faltan $count días',
      one: 'falta 1 día',
      zero: 'último día',
    );
    return '$_temp0';
  }

  @override
  String dashboardPerDay(String amount) {
    return 'unos $amount al día';
  }

  @override
  String get dashboardNoPlan => 'Sin plan este mes';

  @override
  String dashboardIncomeIn(String amount) {
    return 'entraron $amount';
  }

  @override
  String get dashboardLegendLeft => 'Queda';

  @override
  String get dashboardLegendOther => 'Otras';

  @override
  String get dashboardNoticeSee => 'Ver';

  @override
  String get dashboardWhoPaid => 'Quién pagó este mes';

  @override
  String dashboardMovementCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos',
      one: '1 movimiento',
    );
    return '$_temp0';
  }

  @override
  String get dashboardRecent => 'Últimos movimientos';

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
  String get authLoginSubtitle =>
      'Cada quien entra con su cuenta. Si comparten el hogar, lo que anotan lo ven los dos.';

  @override
  String get authLoginHeadline => 'La libreta de la casa,\npara ti o para los dos.';

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
  String get authSignIn => 'Entrar';

  @override
  String get authContinueWithGoogle => 'Seguir con Google';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authCreateAccountHere => 'Créala';

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
  String get authSignupTitle => 'Tu cuenta';

  @override
  String get authSignupSubtitle => 'Es solo tuya. La casa la armas o te unes en el paso siguiente.';

  @override
  String get authNameRequired => 'Ingresa tu nombre';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authHaveAccountLink => 'Ya tengo cuenta';

  @override
  String get householdDefaultName => 'Nuestro hogar';

  @override
  String get householdCreateJoinTitle => '¿Armas la casa o ya existe?';

  @override
  String get householdCreateJoinSubtitle =>
      'Créalo tú. Si alguien más va a anotar contigo, entra con un código.';

  @override
  String get householdCreateOptionTitle => 'Crear la casa';

  @override
  String get householdCreateOptionSubtitle => 'Empiezo yo. Si quiero, invito a alguien después.';

  @override
  String get householdJoinOptionTitle => 'Tengo un código';

  @override
  String get householdJoinOptionSubtitle => 'Alguien ya lo creó y me pasó el código.';

  @override
  String get householdNameLabel => 'Nombre de la casa';

  @override
  String get householdNameRequired => 'Ponle un nombre a la casa';

  @override
  String get householdCodeLabel => 'Código';

  @override
  String get householdCodeHint => 'Pégalo completo, tal como te llegó: lleva la llave de la casa.';

  @override
  String get householdCodeRequired => 'Ingresa el código que te compartieron';

  @override
  String get householdCreateButton => 'Armar la casa';

  @override
  String get householdJoinButton => 'Entrar a la casa';

  @override
  String get householdJoinedWithoutKeyTitle => 'Te uniste al hogar';

  @override
  String get householdJoinedWithoutKeyMessage =>
      'Este código no traía la llave para ver montos. Pide a quien te invitó que te la comparta desde Ajustes, en «Compartir la llave».';

  @override
  String householdSetupStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get householdSetupCurrencyTitle => '¿En qué moneda llevan las cuentas?';

  @override
  String get householdSetupCurrencyDescription =>
      'La de todos los montos de la casa. Se puede cambiar después en Ajustes.';

  @override
  String get householdCurrencyCop => 'Peso colombiano';

  @override
  String get householdCurrencyUsd => 'Dólar estadounidense';

  @override
  String get householdSetupAccountTitle => '¿Dónde está la plata hoy?';

  @override
  String get householdSetupAccountDescription =>
      'Una cuenta para empezar: el banco, una billetera o el efectivo. Con el saldo real, lo que anotes cuadra desde el primer día.';

  @override
  String get householdSetupAccountNameMissingTitle => 'Ponle un nombre';

  @override
  String get householdSetupAccountNameMissingMessage =>
      'Por ejemplo el banco o «Efectivo». Si prefieres, déjala para después con «Ahora no».';

  @override
  String get householdSetupBalanceToday => 'Saldo de hoy';

  @override
  String get householdSetupCreateAccount => 'Crear cuenta';

  @override
  String get householdRecoveryPhraseTitle => 'Frase de recuperación';

  @override
  String get householdSetupRecoveryDescription =>
      'Los montos se cifran con una llave que vive solo en tus teléfonos. Si se pierde, 12 palabras la recuperan. Se muestran una sola vez: anótalas en papel y guárdalas en un lugar seguro. También se puede hacer después, desde Ajustes.';

  @override
  String get householdSetupRecoveryTitle => '¿Y si pierden la llave?';

  @override
  String get householdGeneratePhrase => 'Generar frase';

  @override
  String get householdSetupLater => 'Ahora no';

  @override
  String get householdInviteTitle => '¿Alguien más va a anotar?';

  @override
  String get householdInviteMessage =>
      'Si compartes el hogar, mándale este código con el botón de compartir. Lleva pegada la llave de la casa, que no se ve aquí: compártelo solo con esa persona y no lo publiques en ningún lado. Si lo usas tú solo, sigue sin invitar.';

  @override
  String get householdInviteFootnote =>
      'Sirve una vez y vence en 7 días · se puede generar otro en Ajustes';

  @override
  String get householdInviteMissingPartner => 'Invita a alguien';

  @override
  String get householdInviteShareSubject => 'Invitación a nuestro hogar en Finan2';

  @override
  String get householdInviteShare => 'Compartir';

  @override
  String get householdInviteSkip => 'Por ahora, solo yo';

  @override
  String get householdRecoveryConfirmMessage =>
      'Si algún día la llave del hogar no está en ningún teléfono, estas 12 palabras permiten recuperar los montos. Vas a verlas una sola vez: anótalas en papel y guárdalas en un lugar seguro. Si ya había una frase o un PIN, dejarán de servir.';

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
      'Ese código no trae la llave completa. Pide a la otra persona del hogar que la comparta de nuevo desde Ajustes, en «Compartir la llave».';

  @override
  String get householdKeyWrongHousehold =>
      'Esa llave no es de este hogar. Revisa que el código sea el que se compartió desde este mismo hogar.';

  @override
  String get householdRecoveryNotSet =>
      'Este hogar no tiene una frase de recuperación configurada.';

  @override
  String get householdRecoveryPhraseMismatch =>
      'Esa frase no corresponde a este hogar. Si se generó una nueva, la anterior dejó de servir.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccountsAndCards => 'Cuentas y tarjetas';

  @override
  String get settingsMemberYou => 'tú';

  @override
  String get settingsMemberPartner => 'en la casa';

  @override
  String get settingsInvite => 'Invitar a la casa';

  @override
  String get settingsInviteSomeone => 'Invitar';

  @override
  String get settingsShareKey => 'Compartir la llave';

  @override
  String get settingsMissingKeyBanner =>
      'Este dispositivo no tiene la llave para ver los montos de este hogar. Pega el código que se compartió desde Ajustes, en «Compartir la llave», o escribe la frase de recuperación.';

  @override
  String get settingsPasteCodeToUnlock => 'Pegar código para desbloquear montos';

  @override
  String get settingsUseRecoveryPhrase => 'Usar frase de recuperación';

  @override
  String get settingsStorageWarning =>
      'Tu navegador no garantizó que los datos de Finan2 se conserven. Si no abres la app por varios días, podrías perder el acceso a los montos cifrados de este dispositivo. Asegúrate de tener una frase de recuperación en Ajustes, en «Tu cuenta».';

  @override
  String get settingsFinancialSettings => 'Moneda y año';

  @override
  String get settingsAccountSettings => 'Tu cuenta';

  @override
  String get settingsExportReport => 'Exportar';

  @override
  String get settingsBackup => 'Copia y llave';

  @override
  String get settingsInvestments => 'Inversiones';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsUnlockAmountsTitle => 'Desbloquear montos';

  @override
  String get settingsUnlockAmountsMessage =>
      'Pega el código completo (con la llave después del punto) que se compartió desde Ajustes, en «Compartir la llave».';

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
  String get settingsHouseholdMembers => 'Miembros del hogar';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Como el teléfono';

  @override
  String get settingsLanguageSystemSubtitle => 'Sigue el idioma de tu teléfono.';

  @override
  String get settingsLanguageFixedSubtitle =>
      'Siempre en este idioma, aunque el teléfono esté en otro.';

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
  String get coreSheetErrorTitle => 'Algo salió mal';

  @override
  String get coreReauthTitle => 'Confirma tu contraseña';

  @override
  String get corePassword => 'Contraseña';

  @override
  String get corePeriodBackToToday => 'Volver a hoy';

  @override
  String get coreMissingKeyTitle => 'Este teléfono no tiene la llave de la casa.';

  @override
  String get coreMissingKeyBody =>
      'Los montos se cifran con una llave que solo vive en sus teléfonos. Sin ella, este no puede abrir los movimientos ni anotar nuevos.';

  @override
  String get coreMissingKeyUsePhrase => 'Usar la frase de 12 palabras';

  @override
  String coreMissingKeyAskPartner(String name) {
    return 'Pedirle el código a $name';
  }

  @override
  String get coreMissingKeyPasteCode => 'Pegar el código de la llave';

  @override
  String get coreOffline =>
      'Sin conexión. Lo que anotes se guarda aquí y se envía solo cuando vuelva la señal.';

  @override
  String get coreUnsynced => 'por enviar';

  @override
  String get coreLoading => 'Cargando';

  @override
  String get coreNotificationPrimerTitle => 'Activa las notificaciones';

  @override
  String get coreNotificationPrimerBody =>
      'Te avisamos cuando se acerque una fecha de pago o se pasen del presupuesto y, si compartes el hogar, cuando la otra persona registre algo. Puedes ajustar esto después en Ajustes.';

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
  String get coreHomeTabPlan => 'Plan';

  @override
  String get coreHomeAdd => 'Anotar';

  @override
  String get coreHomeTabSettings => 'Ajustes';

  @override
  String get coreSplashTagline => 'Finanzas del hogar - para ti o para los dos';

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
      'Esa invitación no existe o ya venció. Pide una nueva a quien te invitó, desde Ajustes.';

  @override
  String get errorHouseholdFull =>
      'No pudimos unirte: el hogar ya tiene 2 miembros o la invitación dejó de ser válida.';

  @override
  String get errorGeneric => 'Algo salió mal, intenta de nuevo.';

  @override
  String get errorMissingKey =>
      'Este dispositivo no tiene la llave para ver los montos de este hogar. Pide el código de invitación completo a la otra persona del hogar.';

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

  @override
  String get debtsEmptyTitle => 'No deben nada.';

  @override
  String get debtsEmptyDescription =>
      'Si llega una tarjeta o un crédito, agréguenlo aquí y la app les dice cuándo terminan.';

  @override
  String get debtsEmptyAction => 'Agregar una deuda';

  @override
  String get debtsFreeDateLabel => 'Libres de deudas en';

  @override
  String get debtsCurrentPaymentsLabel => 'Con los pagos actuales';

  @override
  String get debtsCannotPayOff => 'No alcanza a pagar';

  @override
  String get debtsTypeCard => 'Tarjeta';

  @override
  String get debtsTypeLoan => 'Crédito';

  @override
  String get debtsTypeMortgage => 'Hipoteca';

  @override
  String get debtsTypeVehicle => 'Vehículo';

  @override
  String get debtsStatusPaidOff => 'deuda pagada';

  @override
  String debtsStatusFreeBy(String date) {
    return 'libre en $date';
  }

  @override
  String get debtsStatusCannotPayOff => 'no alcanza a pagar con los abonos actuales';

  @override
  String get debtsCurrentBalance => 'Saldo pendiente';

  @override
  String get debtsExtraPayment => 'Abono extra';

  @override
  String get debtsMonthlyInstallment => 'Cuota mensual';

  @override
  String get debtsPaymentSchedule => 'Calendario de pagos';

  @override
  String get debtsAlreadyPaidOff => 'Esta deuda ya está pagada.';

  @override
  String get debtsNoProjection => 'No hay una proyección disponible.';

  @override
  String get debtsScheduledPayment => 'Previsto';

  @override
  String get debtsNeedAccountFirst => 'Crea una cuenta primero para poder registrar el pago.';

  @override
  String get debtsRecordPayment => 'Registrar pago';

  @override
  String get debtsPaymentFrom => 'Desde';

  @override
  String get debtsDeletePayment => 'Eliminar pago';

  @override
  String get debtsNewTitle => 'Nueva deuda';

  @override
  String get debtsEditTitle => 'Editar deuda';

  @override
  String get debtsDelete => 'Eliminar deuda';

  @override
  String debtsDeleteMessage(String name) {
    return 'Se eliminará \"$name\". Los pagos y compras ya registrados se quedan en el historial. Esta acción no se puede deshacer.';
  }

  @override
  String get debtsCreditLimit => 'Cupo';

  @override
  String get debtsRatePercent => 'Tasa E.A. %';

  @override
  String get debtsMinPayment => 'Pago mínimo';

  @override
  String get debtsCutoffDay => 'Día de corte';

  @override
  String get debtsPaymentDay => 'Día de pago';

  @override
  String get debtsOriginalAmount => 'Monto original';

  @override
  String get debtsTermInstallments => 'Plazo (cuotas)';

  @override
  String get debtsPaidInstallments => 'Cuotas pagadas';

  @override
  String get savingsGoalsTotalSaved => 'Total ahorrado';

  @override
  String get savingsGoalsEmptyTitle => 'Todavía no hay metas.';

  @override
  String get savingsGoalsEmptyDescription =>
      'Un viaje, un colchón, un carro: pónganle cifra y fecha, y aquí verán cuánto les falta y cuánto apartar cada mes.';

  @override
  String get savingsGoalsEmptyAction => 'Crear una meta';

  @override
  String get savingsGoalsChallengeLink => 'Reto de ahorro';

  @override
  String get savingsGoalsNoDate => 'sin fecha';

  @override
  String savingsGoalsPerMonth(String amount) {
    return '$amount/mes';
  }

  @override
  String get savingsGoalsBehind => 'va atrasada';

  @override
  String get savingsGoalsContributions => 'Aportes';

  @override
  String get savingsGoalsNoContributions => 'Aún no registras aportes.';

  @override
  String get savingsGoalsNewContribution => 'Nuevo aporte';

  @override
  String get savingsGoalsIconTrip => 'Viaje';

  @override
  String get savingsGoalsIconEmergency => 'Emergencia';

  @override
  String get savingsGoalsIconHome => 'Casa';

  @override
  String get savingsGoalsIconStudy => 'Estudio';

  @override
  String get savingsGoalsIconOther => 'Otro';

  @override
  String get savingsGoalsNewTitle => 'Nueva meta';

  @override
  String get savingsGoalsEditTitle => 'Editar meta';

  @override
  String get savingsGoalsDelete => 'Eliminar meta';

  @override
  String savingsGoalsDeleteMessage(String name) {
    return 'Se eliminará \"$name\" con todos sus aportes. Esta acción no se puede deshacer.';
  }

  @override
  String get savingsGoalsIconField => 'Ícono';

  @override
  String get savingsGoalsTarget => 'Cuánto necesitan';

  @override
  String get savingsGoalsMonthlyContribution => 'Aporte mensual';

  @override
  String get savingsGoalsTargetDate => 'Para cuándo';

  @override
  String get savingsGoalsNoDateValue => 'Sin fecha';

  @override
  String get savingsGoalsClearDate => 'Quitar fecha';

  @override
  String get savingsGoalsAlreadySaved => 'Ya tienen';

  @override
  String get savingsGoalsInterestOptional => 'Interés E.A. (opcional)';

  @override
  String get investmentsTitle => 'Inversiones';

  @override
  String get investmentsEmptyTitle => 'Todavía no hay inversiones.';

  @override
  String get investmentsEmptyDescription =>
      'Agrega tu CDT, fondo o cripto para llevarle el pulso a tu portafolio.';

  @override
  String get investmentsEmptyAction => 'Agregar una inversión';

  @override
  String get investmentsKindFixedIncome => 'Renta fija';

  @override
  String get investmentsKindVariableIncome => 'Renta variable';

  @override
  String get investmentsKindHighRisk => 'Alto riesgo';

  @override
  String investmentsKindWithRate(String kind, String rate) {
    return '$kind · $rate% E.A.';
  }

  @override
  String get investmentsCurrentValue => 'Valor actual';

  @override
  String get investmentsNewTitle => 'Nueva inversión';

  @override
  String get investmentsEditTitle => 'Editar inversión';

  @override
  String get investmentsDelete => 'Eliminar inversión';

  @override
  String investmentsDeleteMessage(String name) {
    return 'Se eliminará \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get investmentsKindField => 'Tipo';

  @override
  String get investmentsInvested => 'Invertido';

  @override
  String get investmentsRate => 'Tasa E.A.';

  @override
  String get transactionsTitle => 'Movimientos';

  @override
  String get transactionsNewTitle => 'Anotar';

  @override
  String get transactionsEditTitle => 'Editar movimiento';

  @override
  String get transactionsDetailOver => 'Movimiento';

  @override
  String get transactionsEdit => 'Editar';

  @override
  String get transactionsDelete => 'Borrar movimiento';

  @override
  String get transactionsDeleted => 'Movimiento borrado';

  @override
  String get transactionsDeleteFailed => 'No se pudo borrar';

  @override
  String transactionsMaxTagsTitle(int max) {
    return 'Máximo $max etiquetas';
  }

  @override
  String get transactionsMaxTagsMessage => 'Quita una antes de añadir otra.';

  @override
  String get transactionsCreditCard => 'Tarjeta de crédito';

  @override
  String get transactionsTypeTransfer => 'Pasar';

  @override
  String get transactionsTransferNeedsTwoAccounts => 'Para eso hacen falta al menos dos cuentas.';

  @override
  String get transactionsTransferExplain =>
      '«Pasar» mueve plata entre tus cuentas, del banco al efectivo por ejemplo. No es gasto ni ingreso: el total no cambia.';

  @override
  String get transactionsTransferCreateAccount => 'Crear otra cuenta';

  @override
  String get transactionsIncomplete => 'Completa el monto, la categoría y la cuenta.';

  @override
  String get transactionsIncompleteTitle => 'Falta un dato';

  @override
  String transactionsDateToday(String date) {
    return 'Hoy, $date';
  }

  @override
  String get transactionsNoCategoriesOfType =>
      'No hay categorías de este tipo todavía. Créalas en Ajustes.';

  @override
  String get transactionsNoAccounts => 'No hay cuentas todavía. Créalas en Ajustes.';

  @override
  String get transactionsSelectAccount => 'Selecciona una cuenta';

  @override
  String get transactionsTags => 'Etiquetas';

  @override
  String get transactionsAddTagHint => 'Añadir etiqueta, por ejemplo viaje-cartagena';

  @override
  String get transactionsAddTag => 'Añadir etiqueta';

  @override
  String get transactionsReceivedBy => 'Lo recibió';

  @override
  String get transactionsPaidBy => 'Pagó';

  @override
  String get transactionsLoggedBy => 'Lo anotó';

  @override
  String get transactionsPreviousMonth => 'Mes anterior';

  @override
  String get transactionsNextMonth => 'Mes siguiente';

  @override
  String transactionsDayToday(String day) {
    return 'Hoy · $day';
  }

  @override
  String transactionsDayYesterday(String day) {
    return 'Ayer · $day';
  }

  @override
  String get transactionsByTag => 'Por etiqueta';

  @override
  String get transactionsByTagHint =>
      'Lo gastado este mes con cada etiqueta. Toca una para ver sus movimientos.';

  @override
  String transactionsResultsTotal(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos',
      one: '1 movimiento',
    );
    return '$_temp0 · $amount';
  }

  @override
  String transactionsSearchWholeYear(int year) {
    return 'Todo $year';
  }

  @override
  String get transactionsNoMatchTitle => 'Nada coincide';

  @override
  String transactionsNoMatchYear(int year) {
    return 'Ningún movimiento de $year coincide con la búsqueda.';
  }

  @override
  String transactionsNoMatchMonth(String month) {
    return 'Ningún movimiento de $month coincide con la búsqueda o los filtros.';
  }

  @override
  String get transactionsClearSearch => 'Limpiar búsqueda';

  @override
  String transactionsEmptyTitle(String month) {
    return '$month está en blanco.';
  }

  @override
  String get transactionsEmptyDescription =>
      'Lo primero que anoten aparece aquí, con quién lo pagó. Los fijos del mes se anotan solos el día que toca.';

  @override
  String get transactionsEmptyDescriptionMonth =>
      'Ese mes no se anotó nada. Si algo quedó por fuera, todavía se puede anotar con su fecha.';

  @override
  String get transactionsEmptyAction => 'Anotar el primero';

  @override
  String transactionsSeeMonth(String month) {
    return 'Ver $month';
  }

  @override
  String get transactionsRecurringBills => 'Fijos';

  @override
  String get transactionsNotes => 'Notas';

  @override
  String get transactionsSearchHint => 'Buscar descripción, categoría, monto o #etiqueta';

  @override
  String get transactionsFilters => 'Filtros';

  @override
  String get transactionsFilterTitle => 'Filtrar';

  @override
  String get transactionsFilterType => 'Tipo';

  @override
  String get transactionsFilterNoCategories => 'No hay categorías de este tipo.';

  @override
  String get transactionsFilterTag => 'Etiqueta';

  @override
  String transactionsPaidByChip(String name) {
    return 'Pagó $name';
  }

  @override
  String get transactionsFilterBoth => 'Los dos';

  @override
  String get transactionsFilterClear => 'Limpiar';

  @override
  String transactionsFilterSee(int count) {
    return 'Ver $count';
  }

  @override
  String get transfersInvalid => 'Elige un monto y dos cuentas distintas.';

  @override
  String get transfersFrom => 'De';

  @override
  String get transfersTo => 'A';

  @override
  String get transfersSelectAccount => 'Selecciona una cuenta';

  @override
  String get transfersHistoryTitle => 'Pasos entre cuentas';

  @override
  String get transfersDeleteTitle => 'Eliminar transferencia';

  @override
  String get transfersDeleteMessage =>
      'Se revertirá el ajuste de saldo en ambas cuentas. Esta acción no se puede deshacer.';

  @override
  String get transfersDeletedAccount => 'Cuenta eliminada';

  @override
  String get transfersEmptyTitle => 'Todavía no han pasado plata.';

  @override
  String get transfersEmptyDescription =>
      'Cuando pasen plata de una cuenta a otra queda anotado aquí, sin contar como gasto.';

  @override
  String get transfersEmptyAction => 'Pasar plata';

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get accountsEmptyTitle => 'Todavía no hay cuentas.';

  @override
  String get accountsEmptyDescription =>
      'Agreguen el efectivo, el banco o la billetera de donde sale la plata, y aquí verán cuánto tienen disponible.';

  @override
  String get accountsEmptyAction => 'Agregar una cuenta';

  @override
  String get accountsTransferBetween => 'Pasar entre cuentas';

  @override
  String get accountsNewTitle => 'Nueva cuenta';

  @override
  String get accountsEditTitle => 'Editar cuenta';

  @override
  String get accountsTypeLabel => 'Tipo';

  @override
  String get accountsCurrentBalance => 'Saldo de hoy';

  @override
  String get accountsIncludeInAvailable => 'Cuenta en «Disponible»';

  @override
  String get accountsDeleteTitle => 'Eliminar cuenta';

  @override
  String accountsDeleteMessage(String name) {
    return 'Se eliminará \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get accountsCannotDeleteTitle => 'No se puede eliminar';

  @override
  String accountsCannotDeleteMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return '\"$name\" tiene $_temp0 (movimientos, transferencias, pagos de tarjeta o facturas recurrentes). Bórralos o cámbialos de cuenta primero. Si solo quieres que no sume, apaga «Cuenta en Disponible».';
  }

  @override
  String get accountsTypeCash => 'Efectivo';

  @override
  String get accountsTypeBank => 'Banco';

  @override
  String get accountsTypeWallet => 'Billetera';

  @override
  String get accountsTypeDebit => 'Débito';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String categoriesRowUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mov. este año',
      one: '1 mov. este año',
      zero: 'Sin movimientos este año',
    );
    return '$_temp0';
  }

  @override
  String get categoriesRowRollover => 'Acumula';

  @override
  String get categoriesNoneOfType => 'Aún no hay categorías de este tipo. Créala con el +.';

  @override
  String get categoriesEmptyTitle => 'Todavía no hay categorías.';

  @override
  String get categoriesEmptyDescription =>
      'Cada movimiento va en una categoría: creen la primera para empezar a anotar.';

  @override
  String get categoriesEmptyAction => 'Crear una categoría';

  @override
  String get categoriesNewTitle => 'Nueva categoría';

  @override
  String get categoriesEditTitle => 'Editar categoría';

  @override
  String get categoriesPreview => 'Vista previa';

  @override
  String get categoriesTypeLabel => 'Tipo';

  @override
  String get categoriesIcon => 'Ícono';

  @override
  String get categoriesColor => 'Color';

  @override
  String get categoriesRolloverTitle => 'Acumular de un mes a otro';

  @override
  String get categoriesRolloverSubtitle =>
      'Lo que sobra o se pasa cuenta para el mes siguiente; se reinicia en enero.';

  @override
  String get categoriesDeleteTitle => 'Eliminar categoría';

  @override
  String categoriesDeleteMessage(String name) {
    return 'Se eliminará \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get categoriesCannotDeleteYetTitle => 'No se puede eliminar todavía';

  @override
  String categoriesCannotDeleteYetMessage(String name, String usage, String type) {
    return '\"$name\" tiene $usage. Crea otra categoría de $type para pasarlos ahí y luego elimina esta.';
  }

  @override
  String categoriesReassignTitle(String name) {
    return '¿A dónde pasamos lo de $name?';
  }

  @override
  String categoriesReassignMessage(String usage, String name) {
    return 'Tiene $usage. Elige la categoría que se quedará con ellos; después \"$name\" se elimina.';
  }

  @override
  String categoriesUsageMovements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos',
      one: '1 movimiento',
    );
    return '$_temp0';
  }

  @override
  String categoriesUsageRecurringBills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fijos',
      one: '1 fijo',
    );
    return '$_temp0';
  }

  @override
  String categoriesUsageBoth(String movements, String bills) {
    return '$movements y $bills';
  }

  @override
  String get categoriesTypeIncome => 'Ingreso';

  @override
  String get categoriesTypeBill => 'Factura';

  @override
  String get categoriesTypeExpense => 'Gasto';

  @override
  String get categoriesTypeSavings => 'Ahorro';

  @override
  String get categoriesTypeIncomePlural => 'Ingresos';

  @override
  String get categoriesTypeBillPlural => 'Facturas';

  @override
  String get categoriesTypeExpensePlural => 'Gastos';

  @override
  String get categoriesTypeSavingsPlural => 'Ahorros';

  @override
  String get categoriesDefaultSalary => 'Salario';

  @override
  String get categoriesDefaultFreelance => 'Freelance';

  @override
  String get categoriesDefaultRent => 'Arriendo';

  @override
  String get categoriesDefaultUtilities => 'Servicios';

  @override
  String get categoriesDefaultPhoneInternet => 'Celular e internet';

  @override
  String get categoriesDefaultStreaming => 'Streaming';

  @override
  String get categoriesDefaultGroceries => 'Mercado';

  @override
  String get categoriesDefaultTransport => 'Transporte';

  @override
  String get categoriesDefaultRestaurants => 'Restaurantes';

  @override
  String get categoriesDefaultLeisure => 'Ocio';

  @override
  String get categoriesDefaultHealth => 'Salud';

  @override
  String get categoriesDefaultHomeCleaning => 'Hogar y aseo';

  @override
  String get categoriesDefaultEmergencyFund => 'Fondo de emergencia';

  @override
  String get categoriesDefaultTravel => 'Viaje';

  @override
  String get recurringBillsTitle => 'Fijos';

  @override
  String get recurringBillsCommittedLabel => 'Comprometido cada mes';

  @override
  String recurringBillsCommittedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fijos',
      one: '1 fijo',
      zero: 'Ningún fijo activo',
    );
    return '$_temp0';
  }

  @override
  String get recurringBillsAveragedNote => 'los no mensuales, en promedio';

  @override
  String get recurringBillsAutoNote => 'Se anotan solos en Movimientos el día que les toca.';

  @override
  String get recurringBillsEmptyTitle => 'Todavía no hay fijos.';

  @override
  String get recurringBillsEmptyDescription =>
      'Programa el arriendo, los servicios o el sueldo para que se anoten solos el día que les toca.';

  @override
  String get recurringBillsEmptyAction => 'Agregar un fijo';

  @override
  String get recurringBillsStatusPaused => 'En pausa';

  @override
  String get recurringBillsStatusEnded => 'Ya terminó';

  @override
  String get recurringBillsTypeIncome => 'Ingreso';

  @override
  String get recurringBillsTypeBill => 'Factura';

  @override
  String get recurringBillsNewTitle => 'Nuevo fijo';

  @override
  String get recurringBillsEditTitle => 'Editar fijo';

  @override
  String get recurringBillsMissingFields => 'Completa el nombre, monto, categoría y cuenta.';

  @override
  String get recurringBillsSemimonthlyDayTitle => 'Elige un día hasta el 15';

  @override
  String get recurringBillsSemimonthlyDayMessage =>
      'Una quincenal se repite 15 días después de la primera fecha. Elige el primer pago entre el 1 y el 15 del mes - por ejemplo el 15 para cobrar el 15 y el 30.';

  @override
  String get recurringBillsDelete => 'Eliminar fijo';

  @override
  String recurringBillsDeleteMessage(String name) {
    return 'Se eliminará \"$name\" y dejará de anotarse. Los movimientos que ya creó se quedan. Esta acción no se puede deshacer. Si solo quieres detenerlo un tiempo, ponlo en pausa.';
  }

  @override
  String get recurringBillsNoCategories =>
      'No hay categorías de este tipo todavía. Créalas en Ajustes.';

  @override
  String get recurringBillsNoAccounts => 'No hay cuentas todavía. Créalas en Ajustes.';

  @override
  String get recurringBillsSelectAccount => 'Selecciona una cuenta';

  @override
  String get recurringBillsRepeats => 'Cada cuánto';

  @override
  String get recurringBillsFrom => 'Desde';

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
      'No se anota mientras esté en pausa. Al reanudarlo, las fechas que pasaron no se anotan.';

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
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': 'Cada lunes',
      'tuesday': 'Cada martes',
      'wednesday': 'Cada miércoles',
      'thursday': 'Cada jueves',
      'friday': 'Cada viernes',
      'saturday': 'Cada sábado',
      'other': 'Cada domingo',
    });
    return '$_temp0';
  }

  @override
  String recurringBillsScheduleBiweekly(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': 'Cada 2 semanas, los lunes',
      'tuesday': 'Cada 2 semanas, los martes',
      'wednesday': 'Cada 2 semanas, los miércoles',
      'thursday': 'Cada 2 semanas, los jueves',
      'friday': 'Cada 2 semanas, los viernes',
      'saturday': 'Cada 2 semanas, los sábados',
      'other': 'Cada 2 semanas, los domingos',
    });
    return '$_temp0';
  }

  @override
  String recurringBillsScheduleSemimonthly(int day, int secondDay) {
    return 'Días $day y $secondDay';
  }

  @override
  String recurringBillsScheduleMonthly(int day) {
    return 'Cada mes, día $day';
  }

  @override
  String recurringBillsScheduleYearly(String date) {
    return 'Cada año, $date';
  }

  @override
  String recurringBillsScheduleUntil(String schedule, String date) {
    return '$schedule, hasta el $date';
  }

  @override
  String recurringBillsMonthlyCost(String kind, String amount) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'average': 'Unos $amount al mes',
      'other': '$amount al mes',
    });
    return '$_temp0';
  }

  @override
  String recurringBillsAverageWhy(String frequency) {
    String _temp0 = intl.Intl.selectLogic(frequency, {
      'weekly': '52 pagos al año: algunos meses caen 5.',
      'biweekly': '26 pagos al año: algunos meses caen 3.',
      'yearly': '1 pago al año, repartido en 12.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String recurringBillsFrequencyHint(String frequency) {
    String _temp0 = intl.Intl.selectLogic(frequency, {
      'biweekly': 'Cada 14 días, siempre el mismo día de la semana: algunos meses caen 3.',
      'semimonthly': '2 veces al mes, en días fijos: siempre 2.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get monthlyNotesTitle => 'Notas del mes';

  @override
  String get monthlyNotesThisMonth => 'Notas de este mes';

  @override
  String get monthlyNotesNextMonth => 'Para el mes siguiente';

  @override
  String get monthlyNotesEmpty => 'Nada escrito todavía. Toca para escribir.';

  @override
  String get monthlyNotesWrite => 'Escribir';

  @override
  String get monthlyNotesHint => 'Lo que no cabe en números.';

  @override
  String get monthlyNotesExplain =>
      'Lo que no cabe en números, compartido con tu hogar. Para que un gasto sume, anótalo con una etiqueta, como #gasolina: Movimientos te da el total.';

  @override
  String get monthlyNotesFromLastMonth => 'Te dejaste esto para este mes';

  @override
  String get notificationsTitle => 'Avisos';

  @override
  String get notificationsMarkAllRead => 'Marcar todo como leído';

  @override
  String get notificationsUnread => 'Sin leer';

  @override
  String get notificationsEmpty =>
      'Aquí llegan los pagos que se acercan, las metas que van bien, lo que se pasa del presupuesto y, si compartes el hogar, lo que anota la otra persona.';

  @override
  String get notificationsEmptyTitle => 'Todo tranquilo.';

  @override
  String get notificationsEmptyAction => 'Elegir qué avisar';

  @override
  String notificationsMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String notificationsHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String get notificationsYesterday => 'ayer';

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
    return 'Alguien del hogar agregó un aporte a $goal.';
  }

  @override
  String get notificationsPartnerMovementTitle => 'Nuevo movimiento';

  @override
  String get notificationsPartnerMovementBody => 'Alguien del hogar registró un movimiento.';

  @override
  String get notificationsPartnerTransferTitle => 'Nueva transferencia';

  @override
  String get notificationsPartnerTransferBody =>
      'Alguien del hogar registró una transferencia entre cuentas.';

  @override
  String get notificationsPartnerDebtTitle => 'Nueva deuda';

  @override
  String get notificationsPartnerAccountTitle => 'Nueva cuenta';

  @override
  String get notificationsPartnerInvestmentTitle => 'Nueva inversión';

  @override
  String get notificationsPartnerBillTitle => 'Nuevo fijo';

  @override
  String get notificationsPartnerCategoryTitle => 'Nueva categoría';

  @override
  String get notificationsPartnerChallengeTitle => 'Nuevo reto de ahorro';

  @override
  String get notificationsPartnerGoalTitle => 'Nueva meta de ahorro';

  @override
  String get notificationPrefsTitle => 'Qué avisar';

  @override
  String notificationPrefsIntro(String name) {
    return 'Solo para ti: $name elige los suyos.';
  }

  @override
  String get notificationPrefsIntroSolo => 'Solo para ti: cada quien elige los suyos.';

  @override
  String get notificationPrefsDailyReminder => 'Recordatorio para anotar';

  @override
  String get notificationPrefsDailyReminderWhen => 'Todos los días, a esta hora';

  @override
  String get notificationPrefsDailyReminderTimeTooltip => 'Cambiar la hora';

  @override
  String get notificationPrefsDebtPayments => 'Pagos que se acercan';

  @override
  String get notificationPrefsDebtPaymentsWhen => '3, 2 y 1 día antes, y el mismo día';

  @override
  String get notificationPrefsGoalProgress => 'Avance de metas';

  @override
  String get notificationPrefsGoalProgressWhen => 'Una vez, cuando una meta pasa el 90%';

  @override
  String get notificationPrefsBudgetExceeded => 'Categoría que se pasa';

  @override
  String get notificationPrefsBudgetExceededWhen => 'Una vez por categoría y mes';

  @override
  String get notificationPrefsPartnerActivity => 'Lo que anota la otra persona';

  @override
  String notificationPrefsPartnerActivityNamed(String name) {
    return 'Lo que anota $name';
  }

  @override
  String get notificationPrefsPartnerActivityWhen => 'Cada movimiento, cuenta o meta nueva';

  @override
  String get notificationPrefsWeeklySummary => 'Resumen semanal';

  @override
  String notificationPrefsWeeklySummaryWhen(String time) {
    return 'Los domingos, $time';
  }

  @override
  String get exportTitle => 'Exportar';

  @override
  String get exportPeriod => 'Periodo';

  @override
  String exportPeriodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get exportPeriodThisMonth => 'Este mes';

  @override
  String get exportPeriodQuarter => '3 meses';

  @override
  String get exportPeriodYear => '12 meses';

  @override
  String get exportInclude => 'Qué incluir';

  @override
  String get exportTransactions => 'Movimientos';

  @override
  String get exportBudget => 'Presupuesto';

  @override
  String get exportDebtsAndSavings => 'Deudas y metas';

  @override
  String get exportPdfTitle => 'PDF';

  @override
  String get exportPdfFor => 'Para leer o imprimir, con los montos con formato.';

  @override
  String get exportCsvTitle => 'CSV para hoja de cálculo';

  @override
  String get exportCsvFor => 'Un archivo por sección, con números limpios y fechas AAAA-MM-DD.';

  @override
  String get exportOnDevice =>
      'El archivo se arma en este teléfono con los datos ya descifrados: nada sale de aquí hasta que lo compartes.';

  @override
  String get exportAction => 'Exportar';

  @override
  String get exportDebts => 'Deudas';

  @override
  String get exportSavingsGoals => 'Metas de ahorro';

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
  String get backupDescription =>
      'Todo el hogar en un archivo cifrado con la llave de la casa. Sin la llave no se puede leer: se puede guardar en el correo o en la nube.';

  @override
  String get backupCreate => 'Crear copia ahora';

  @override
  String get backupRestoreAction => 'Restaurar una copia';

  @override
  String get backupRestoreLead => 'Al restaurar';

  @override
  String get backupRestoreNote =>
      ', el hogar vuelve a como estaba ese día, para todos en él: lo creado después se borra. Solo funciona en este mismo hogar.';

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
    return 'El hogar volverá a como estaba el $date. Lo que se haya creado después se borra y lo que cambió vuelve a como estaba, también para la otra persona del hogar.';
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
          '$count registros de la otra persona que se habían borrado quedan a tu nombre: solo puedes crear registros como tuyos. En los movimientos se conserva quién pagó.',
      one:
          '1 registro de la otra persona que se había borrado queda a tu nombre: solo puedes crear registros como tuyos. En los movimientos se conserva quién pagó.',
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

  @override
  String get planBudget => 'Presupuesto';

  @override
  String budgetLeft(String amount) {
    return 'quedan $amount';
  }

  @override
  String get budgetComplete => 'Completo';

  @override
  String get budgetUnplanned => 'sin plan';

  @override
  String budgetSpentOf(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String budgetSpentNoPlan(String spent) {
    return '$spent gastado';
  }

  @override
  String budgetOverTitle(String category, String amount) {
    return '$category se pasó $amount';
  }

  @override
  String budgetOverManyTitle(int count) {
    return '$count categorías se pasaron';
  }

  @override
  String get budgetOverMessage => 'Sale de lo que queda del plan.';

  @override
  String budgetOverManyMessage(String category, String amount) {
    return '$category es la que más: $amount.';
  }

  @override
  String budgetPlannedRemaining(String planned, String amount) {
    return '$planned planeado · faltan $amount por asignar';
  }

  @override
  String budgetPlannedOver(String planned, String amount) {
    return '$planned planeado · $amount más de lo que entró';
  }

  @override
  String budgetPlannedNoIncome(String planned) {
    return '$planned planeado · aún no entra nada este mes';
  }

  @override
  String get goalsSavedTogether => 'Ahorrado en el hogar';

  @override
  String goalsOnTime(int onTime, int dated) {
    return 'van a tiempo en $onTime de $dated metas';
  }

  @override
  String goalsToGo(String amount) {
    return 'faltan $amount para completarlas';
  }

  @override
  String goalRowLine(String saved, String target, String when) {
    return '$saved de $target · $when';
  }

  @override
  String goalFor(String date) {
    return 'para $date';
  }

  @override
  String goalsDebtsFree(String date) {
    return 'Deudas: libres en $date';
  }

  @override
  String get goalsDebtsStuck => 'Deudas: con los pagos actuales no se terminan';

  @override
  String goalsDebtsOrder(String first, String second) {
    return 'Primero $first, luego $second.';
  }

  @override
  String goalsDebtsOnly(String name) {
    return 'Solo queda $name.';
  }

  @override
  String goalOnTimePace(String amount) {
    return 'Van a tiempo: $amount al mes';
  }

  @override
  String goalBehindPace(String amount) {
    return 'Van atrasados: hacen falta $amount al mes';
  }

  @override
  String get goalReached => '¡Meta cumplida!';

  @override
  String goalOfFor(String target, String when) {
    return 'de $target · $when';
  }

  @override
  String goalInterest(String amount) {
    return 'Incluye $amount de intereses';
  }

  @override
  String goalContributionOf(String month) {
    return 'Aporte de $month';
  }

  @override
  String get goalCreate => 'Crear';

  @override
  String goalNeededTitle(String amount) {
    return '$amount al mes';
  }

  @override
  String goalNeededMessage(String date) {
    return 'Es lo que hace falta para llegar en $date.';
  }

  @override
  String get commonEdit => 'Editar';

  @override
  String debtsLeftAvalanche(String amount) {
    return 'quedan $amount · orden Avalancha (primero la tasa más alta)';
  }

  @override
  String debtsRowCard(String rate, String amount, int day) {
    return '$rate% · mín. $amount · día $day';
  }

  @override
  String debtsRowLoan(String rate, String amount, int day) {
    return '$rate% · cuota $amount · día $day';
  }

  @override
  String get debtsFirst => '1.º';

  @override
  String debtsNextTitle(String name, String date) {
    return 'Próximo pago: $name, $date';
  }

  @override
  String debtsNextMinSuggested(String min, String suggested) {
    return '$min mínimo · sugerido $suggested';
  }

  @override
  String debtsNextMin(String min) {
    return '$min mínimo';
  }

  @override
  String debtsDetailSub(String reference, int pct, String status) {
    return 'de $reference · $pct% pagado · $status';
  }

  @override
  String debtsRateOnly(String rate) {
    return 'Tasa $rate% E.A.';
  }

  @override
  String debtsRateExtra(String rate, String amount) {
    return 'Tasa $rate% E.A. · abono extra $amount';
  }

  @override
  String get debtsPaidBy => 'Pagado por';

  @override
  String debtsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'en $days días',
      one: 'mañana',
      zero: 'hoy',
    );
    return '$_temp0';
  }

  @override
  String debtsDeletePaymentMessage(String amount, String date) {
    return 'Se quitará el pago de $amount del $date.';
  }

  @override
  String get challengeSavedIn => 'Ahorrado en el reto';

  @override
  String challengeCells(int done, int total, String target) {
    return '$done de $total casillas · meta $target';
  }

  @override
  String challengeNextTitle(String amount) {
    return 'Siguiente: $amount';
  }

  @override
  String get challengeNextMessage => 'Márcala cuando la aporten.';

  @override
  String get challengeMark => 'Marcar';

  @override
  String get challengeDoneTitle => 'Reto completo';

  @override
  String challengeDoneMessage(String amount) {
    return 'Ahorraron $amount.';
  }

  @override
  String annualTitleYear(int year) {
    return 'Resumen $year';
  }

  @override
  String annualAverage(String amount) {
    return 'prom. $amount';
  }

  @override
  String annualHighestTitle(String month) {
    return '$month fue el mes más alto';
  }

  @override
  String annualHighestReason(String category, String amount) {
    return '$category: $amount más que en un mes normal.';
  }

  @override
  String get accountsAvailableLabel => 'Disponible entre las cuentas';

  @override
  String get accountsAvailableNote => 'las tarjetas y créditos no suman aquí';

  @override
  String get accountsCards => 'Tarjetas';

  @override
  String accountsRowExcluded(String type) {
    return '$type · no suma en «Disponible»';
  }

  @override
  String get accountsIncludeHint => 'Apágalo para cuentas que no se tocan, como un ahorro aparte.';

  @override
  String get accountsAdd => 'Nueva cuenta';

  @override
  String get commonCreate => 'Crear';

  @override
  String debtsFormTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'tarjeta': 'Tarjeta de crédito',
      'credito': 'Crédito',
      'hipoteca': 'Hipoteca',
      'vehiculo': 'Crédito de vehículo',
      'other': 'Deuda',
    });
    return '$_temp0';
  }

  @override
  String debtsCardDays(int cutoff, int day) {
    return 'Corte día $cutoff · paga día $day';
  }

  @override
  String debtsCardPayDay(int day) {
    return 'Paga día $day';
  }

  @override
  String get debtsCardPlaceholder => 'Tu tarjeta';

  @override
  String get debtsOwedToday => 'Cuánto deben hoy';

  @override
  String debtsEndsIn(String date) {
    return 'Terminan en $date';
  }

  @override
  String debtsEndsSooner(String amount, String date) {
    return 'Si abonan $amount más al mes: $date.';
  }

  @override
  String get debtsNeverEnds => 'Con esa cuota no se termina de pagar';

  @override
  String get debtsNeverEndsHint => 'Los intereses se comen el pago: suban la cuota o abonen más.';

  @override
  String get investmentsWorthToday => 'Valen hoy';

  @override
  String investmentsPutIn(String amount) {
    return 'pusieron $amount';
  }

  @override
  String get investmentsGaining => 'ganan';

  @override
  String get investmentsLosing => 'pierden';

  @override
  String get investmentsManualNote => 'Se actualizan a mano: la app no se conecta a ningún banco.';

  @override
  String get investmentsAdd => 'Nueva inversión';

  @override
  String transfersRowTo(String name) {
    return 'A $name';
  }

  @override
  String transfersRowFrom(String name, String date) {
    return 'de $name · $date';
  }

  @override
  String transfersHas(String amount) {
    return 'tiene $amount';
  }

  @override
  String transfersLeaves(String amount) {
    return 'queda $amount';
  }

  @override
  String get transfersNotExpense => 'No es un gasto: no toca el presupuesto.';

  @override
  String get transfersSwap => 'Invertir el sentido';

  @override
  String get demoSeed => 'Llenar con datos de prueba';

  @override
  String get demoRemove => 'Quitar datos de prueba';

  @override
  String get demoSeedTitle => '¿Llenar con datos de prueba?';

  @override
  String get demoSeedMessage =>
      'Se añaden tres meses de cuentas, una tarjeta, un crédito, metas, inversiones, fijos y movimientos inventados. Lo que ya tienen no se toca, y no avisan a nadie.';

  @override
  String get demoSeedConfirm => 'Llenar';

  @override
  String get demoSeedDoneTitle => 'Listo';

  @override
  String demoSeedDone(int count) {
    return 'Se escribieron $count registros de prueba.';
  }

  @override
  String get demoRemoveTitle => '¿Quitar los datos de prueba?';

  @override
  String get demoRemoveMessage => 'Se borra solo lo inventado. Lo que anotaron ustedes se queda.';

  @override
  String get demoRemoveConfirm => 'Quitar';

  @override
  String get demoRemoveDoneTitle => 'Quitados';

  @override
  String demoRemoveDone(int count) {
    return 'Se borraron $count registros de prueba.';
  }

  @override
  String get demoError =>
      'No se pudo terminar. Revisa la conexión y vuelve a intentarlo: se puede repetir sin duplicar nada.';

  @override
  String householdInviteValidUntil(String date) {
    return 'Sirve una vez y vence el $date.';
  }

  @override
  String get householdInviteNewCode => 'Generar otro código';

  @override
  String get householdInviteNewCodeTitle => '¿Generar otro código?';

  @override
  String get householdInviteNewCodeMessage =>
      'El código que ya mandaste dejará de funcionar. Hazlo si llegó a quien no era o si se perdió.';

  @override
  String householdJoinConfirmTitle(String household) {
    return '¿Entrar a $household?';
  }

  @override
  String get householdJoinConfirmTitleUnnamed => '¿Entrar a esta casa?';

  @override
  String householdJoinConfirmMessage(String name) {
    return 'Te invitó $name. Desde ahora los dos van a ver y anotar el dinero de esta casa.';
  }

  @override
  String get householdJoinConfirmMessageUnnamed =>
      'Desde ahora los dos van a ver y anotar el dinero de esta casa.';

  @override
  String get appLockTitle => 'Bloqueo de la app';

  @override
  String get appLockIntro =>
      'Finan2 pide tu PIN al abrirse y al volver tras 30 segundos fuera, así no tienes que iniciar sesión cada vez. Es solo de este teléfono.';

  @override
  String get appLockBiometrics => 'Usar huella o rostro';

  @override
  String get appLockBiometricsWhen => 'Abre sin escribir el PIN. El PIN sigue sirviendo.';

  @override
  String get appLockChangePin => 'Cambiar PIN';

  @override
  String get appLockEnterPin => 'Escribe tu PIN';

  @override
  String get appLockEnterPinMessage => 'Finan2 está bloqueado en este teléfono.';

  @override
  String appLockWrongPin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'PIN incorrecto. Te quedan $count intentos.',
      one: 'PIN incorrecto. Te queda 1 intento.',
      zero: 'PIN incorrecto.',
    );
    return '$_temp0';
  }

  @override
  String appLockWait(int seconds) {
    return 'Demasiados intentos. Prueba otra vez en $seconds s.';
  }

  @override
  String get appLockForgot => '¿Olvidaste tu PIN?';

  @override
  String get appLockForgotTitle => 'Quitar el PIN cerrando sesión';

  @override
  String get appLockForgotMessage =>
      'Al cerrar sesión se borra el PIN de este teléfono. Vuelve a entrar con tu correo o con Google y tus datos siguen ahí.';

  @override
  String get appLockUseBiometrics => 'Usar huella o rostro';

  @override
  String get appLockBiometricReason => 'Abre Finan2';

  @override
  String get appLockErase => 'Borrar';

  @override
  String appLockStep(int step) {
    return 'Paso $step de 2';
  }

  @override
  String get appLockCreateTitle => 'Elige un PIN';

  @override
  String get appLockCreateMessage =>
      '4 dígitos que vas a escribir al abrir Finan2. Mejor uno que no sea tu fecha de nacimiento.';

  @override
  String get appLockConfirmTitle => 'Escríbelo otra vez';

  @override
  String get appLockConfirmMessage => 'Para estar seguros de que es el que quieres.';

  @override
  String get appLockMismatch => 'No coinciden. Elige el PIN otra vez.';

  @override
  String get appLockCurrentTitle => 'Escribe tu PIN actual';

  @override
  String get appLockCurrentMessage => 'Para cambiar el bloqueo hace falta el PIN de ahora.';

  @override
  String get appLockValuePin => 'Solo PIN';

  @override
  String get appLockValueBiometrics => 'Con huella o rostro';

  @override
  String get appLockBiometricsUnavailable =>
      'Este teléfono no tiene huella ni rostro configurados. Agrégalos en los ajustes del teléfono y vuelve aquí.';

  @override
  String get onboardingNotificationsTitle => 'Que no se te pase nada';

  @override
  String get onboardingNotificationsMessage =>
      'Te avisamos cuando se acerque un pago, cuando se pasen del presupuesto y, si compartes el hogar, cuando la otra persona anote algo. Lo ajustas cuando quieras en Ajustes › Avisos.';

  @override
  String get onboardingPinTitle => 'Crea tu PIN';

  @override
  String get onboardingPinMessage =>
      'Con estos 4 dígitos entras a Finan2 sin volver a iniciar sesión. Solo vale en este teléfono.';

  @override
  String get onboardingBiometricsTitle => '¿Entrar con tu huella o tu rostro?';

  @override
  String get onboardingBiometricsMessage =>
      'Más rápido que escribir el PIN, que sigue sirviendo. Lo cambias cuando quieras en Ajustes › Bloqueo de la app.';

  @override
  String get onboardingBiometricsFailed =>
      'No pudimos reconocerte. Prueba otra vez o elige «Ahora no».';

  @override
  String get notificationPrefsOffBanner =>
      'Las notificaciones están apagadas en este teléfono: no te llega ningún aviso.';

  @override
  String get notificationPrefsBlockedTitle => 'Actívalas desde el teléfono';

  @override
  String get notificationPrefsBlockedMessage =>
      'El teléfono ya no deja preguntar desde la app. Ve a los ajustes del teléfono › Aplicaciones › Finan2 › Notificaciones y actívalas.';

  @override
  String get profileTitle => 'Tu perfil';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileEmail => 'Correo';

  @override
  String get profilePassword => 'Contraseña';

  @override
  String get profilePasswordGoogle =>
      'Entras con Google: la contraseña se cambia en tu cuenta de Google.';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profilePasswordSentTitle => 'Revisa tu correo';

  @override
  String profilePasswordSentMessage(String email) {
    return 'Te enviamos un enlace a $email para elegir una contraseña nueva.';
  }

  @override
  String get profilePreferences => 'Preferencias';

  @override
  String get profilePreferencesNote =>
      'El idioma y el tema se guardan en tu cuenta: en otro teléfono los encuentras igual.';
}
