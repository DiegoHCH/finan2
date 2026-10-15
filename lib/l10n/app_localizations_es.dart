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
  String get debtsTitle => 'Deudas';

  @override
  String get debtsAvalancheStrategy => 'Estrategia Avalancha';

  @override
  String get debtsEmptyTitle => '¡Libres de deudas!';

  @override
  String get debtsEmptyDescription =>
      'No tienes deudas registradas. Si adquieres una, agrégala para seguir su pago con la estrategia Avalancha.';

  @override
  String get debtsEmptyAction => '+ Agregar una deuda';

  @override
  String get debtsFreeDateLabel => '¡Libre de deudas en!';

  @override
  String get debtsCurrentPaymentsLabel => 'Con los pagos actuales';

  @override
  String get debtsCannotPayOff => 'No alcanza a pagar';

  @override
  String debtsCardSubtitle(String rate, String minPayment) {
    return 'Tasa $rate% · mín. $minPayment/mes';
  }

  @override
  String debtsPaidAmount(String amount) {
    return 'Pagado $amount';
  }

  @override
  String debtsBalanceAmount(String amount) {
    return 'Saldo $amount';
  }

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
  String debtsRateWithStatus(String rate, String status) {
    return 'Tasa $rate% E.A. · $status';
  }

  @override
  String get debtsCurrentBalance => 'Saldo actual';

  @override
  String get debtsMinPaymentShort => 'Pago mín.';

  @override
  String get debtsExtraPayment => 'Abono extra';

  @override
  String get debtsPaid => 'Pagado';

  @override
  String get debtsMonthlyInstallment => 'Cuota mensual';

  @override
  String get debtsInstallmentsLeft => 'Cuotas restantes';

  @override
  String get debtsPaymentSchedule => 'Calendario de pagos';

  @override
  String get debtsAlreadyPaidOff => 'Esta deuda ya está pagada.';

  @override
  String get debtsNoProjection => 'No hay una proyección disponible.';

  @override
  String get debtsNextPayment => 'Próximo pago';

  @override
  String get debtsScheduledPayment => 'Programado';

  @override
  String debtsScheduleBalance(String amount) {
    return 'Saldo → $amount';
  }

  @override
  String get debtsNeedAccountFirst => 'Crea una cuenta primero para poder registrar el pago.';

  @override
  String get debtsRecordPayment => 'Registrar pago';

  @override
  String get debtsPaymentFrom => 'Desde';

  @override
  String get debtsRecordedPayments => 'Pagos registrados';

  @override
  String get debtsNoCardPayments => 'Aún no registras pagos a esta tarjeta.';

  @override
  String get debtsDeletedAccount => 'Cuenta eliminada';

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
  String get debtsTypeField => 'Tipo de deuda';

  @override
  String get debtsCreditLimit => 'Cupo total';

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
  String get savingsGoalsTitle => 'Metas de ahorro';

  @override
  String get savingsGoalsTotalSaved => 'Total ahorrado';

  @override
  String savingsGoalsTotalSavedRemaining(String amount) {
    return 'Total ahorrado · falta $amount';
  }

  @override
  String get savingsGoalsEmptyTitle => 'Aún no tienes metas';

  @override
  String get savingsGoalsEmptyDescription =>
      'Crea una meta de ahorro para llevarle el pulso con tu pareja.';

  @override
  String get savingsGoalsEmptyAction => '+ Nueva meta';

  @override
  String get savingsGoalsChallengeLink => 'Reto de ahorro';

  @override
  String get savingsGoalsNoDate => 'sin fecha';

  @override
  String savingsGoalsCardSubtitle(String amount, String date) {
    return 'Meta $amount · $date';
  }

  @override
  String savingsGoalsPerMonth(String amount) {
    return '$amount/mes';
  }

  @override
  String savingsGoalsSavedAmount(String amount) {
    return 'Ahorrado $amount';
  }

  @override
  String savingsGoalsSavedRemaining(String amount) {
    return 'Ahorrado · falta $amount';
  }

  @override
  String get savingsGoalsSavedReached => 'Ahorrado · meta cumplida';

  @override
  String get savingsGoalsContribution => 'Aporte';

  @override
  String get savingsGoalsInterestEarned => 'Interés ganado';

  @override
  String get savingsGoalsRemaining => 'Falta';

  @override
  String savingsGoalsProgressOf(int percent, String amount) {
    return '$percent% de $amount';
  }

  @override
  String savingsGoalsTargetBy(String date) {
    return 'meta $date';
  }

  @override
  String get savingsGoalsOnTrack => 'a tiempo ✓';

  @override
  String get savingsGoalsBehind => 'atrasado';

  @override
  String get savingsGoalsContributions => 'Aportes';

  @override
  String get savingsGoalsNoContributions => 'Aún no registras aportes.';

  @override
  String get savingsGoalsNewContribution => 'Nuevo aporte';

  @override
  String savingsGoalsRunningTotal(String amount) {
    return 'Total → $amount';
  }

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
  String get savingsGoalsTarget => 'Meta';

  @override
  String get savingsGoalsMonthlyContribution => 'Aporte mensual';

  @override
  String get savingsGoalsTargetDate => 'Fecha meta';

  @override
  String get savingsGoalsNoDateValue => 'Sin fecha';

  @override
  String get savingsGoalsClearDate => 'Quitar fecha';

  @override
  String get savingsGoalsAlreadySaved => 'Ya tengo ahorrado';

  @override
  String get savingsGoalsInterestOptional => 'Interés E.A. (opcional)';

  @override
  String get investmentsTitle => 'Inversiones';

  @override
  String get investmentsEmptyTitle => 'Aún no hay inversiones';

  @override
  String get investmentsEmptyDescription =>
      'Agrega tu CDT, fondo o cripto para llevarle el pulso a tu portafolio.';

  @override
  String get investmentsEmptyAction => '+ Nueva inversión';

  @override
  String get investmentsPortfolioValue => 'Valor del portafolio';

  @override
  String get investmentsTotalReturnSuffix => ' de rendimiento total';

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
}
