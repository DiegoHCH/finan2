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
}
