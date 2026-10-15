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
  String get transactionsTitle => 'Movimientos';

  @override
  String get transactionsNewTitle => 'Nuevo movimiento';

  @override
  String get transactionsEditTitle => 'Editar movimiento';

  @override
  String get transactionsDelete => 'Eliminar movimiento';

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
  String get transactionsIncomplete => 'Completa el monto, la categoría y la cuenta.';

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
  String get transactionsLoggedBy => 'Registrado por';

  @override
  String transactionsNet(String amount) {
    return '$amount neto';
  }

  @override
  String transactionsNetInYear(String amount, int year) {
    return '$amount neto en $year';
  }

  @override
  String transactionsFiltered(String text) {
    return '$text · filtrado';
  }

  @override
  String get transactionsPreviousMonth => 'Mes anterior';

  @override
  String get transactionsNextMonth => 'Mes siguiente';

  @override
  String transactionsSearchWholeYear(int year) {
    return 'Buscar en todo $year';
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
  String get transactionsEmptyTitle => 'Aún no hay movimientos';

  @override
  String transactionsEmptyTitleMonth(String month) {
    return 'Sin movimientos en $month';
  }

  @override
  String get transactionsEmptyDescription =>
      'Registra tu primer ingreso o gasto del mes y aquí verás el resumen del hogar.';

  @override
  String get transactionsEmptyDescriptionMonth =>
      'No se registró ningún ingreso ni gasto este mes.';

  @override
  String get transactionsEmptyAction => '+ Agregar el primero';

  @override
  String get transactionsRecurringBills => 'Facturas recurrentes';

  @override
  String get transactionsNotes => 'Notas';

  @override
  String get transactionsSearchHint => 'Buscar descripción, categoría o monto';

  @override
  String get transactionsFilters => 'Filtros';

  @override
  String get transactionsFilterTitle => 'Filtrar movimientos';

  @override
  String get transactionsFilterType => 'Tipo';

  @override
  String get transactionsFilterNoCategories => 'No hay categorías de este tipo.';

  @override
  String get transactionsFilterTag => 'Etiqueta';

  @override
  String get transactionsFilterClear => 'Limpiar';

  @override
  String get transactionsFilterApply => 'Aplicar';

  @override
  String get transfersTitle => 'Transferir';

  @override
  String get transfersInvalid => 'Elige un monto y dos cuentas distintas.';

  @override
  String get transfersAmountLabel => 'Monto a transferir';

  @override
  String get transfersFrom => 'Desde';

  @override
  String get transfersTo => 'Hacia';

  @override
  String get transfersSelectAccount => 'Selecciona una cuenta';

  @override
  String get transfersHistoryTitle => 'Transferencias';

  @override
  String get transfersDeleteTitle => 'Eliminar transferencia';

  @override
  String get transfersDeleteMessage =>
      'Se revertirá el ajuste de saldo en ambas cuentas. Esta acción no se puede deshacer.';

  @override
  String get transfersDeletedAccount => 'Cuenta eliminada';

  @override
  String get transfersEmptyTitle => 'Aún no hay transferencias';

  @override
  String get transfersEmptyDescription =>
      'Los movimientos de dinero entre tus propias cuentas aparecerán aquí.';

  @override
  String get transfersEmptyAction => '+ Transferir';

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get accountsAvailableMoney => 'Dinero disponible';

  @override
  String get accountsTotalAvailable => 'Total disponible';

  @override
  String accountsCountInHousehold(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count cuentas del hogar',
      one: 'en 1 cuenta del hogar',
    );
    return '$_temp0';
  }

  @override
  String get accountsEmptyTitle => 'Aún no hay cuentas';

  @override
  String get accountsEmptyDescription =>
      'Agrega tu primera cuenta (efectivo, banco, billetera) para empezar a registrar movimientos.';

  @override
  String get accountsEmptyAction => '+ Nueva cuenta';

  @override
  String get accountsTransferBetween => 'Transferir entre cuentas';

  @override
  String get accountsHistory => 'Historial';

  @override
  String get accountsNewTitle => 'Nueva cuenta';

  @override
  String get accountsEditTitle => 'Editar cuenta';

  @override
  String get accountsTypeLabel => 'Tipo de cuenta';

  @override
  String get accountsCurrentBalance => 'Saldo actual';

  @override
  String get accountsIncludeInAvailable => 'Incluir en dinero disponible';

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
    return '\"$name\" tiene $_temp0 (movimientos, transferencias, pagos de tarjeta o facturas recurrentes). Bórralos o cámbialos de cuenta primero. Si solo quieres que no sume, desactiva \"Incluir en dinero disponible\".';
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
  String categoriesActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas',
      one: '1 activa',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmptyTitle => 'Aún no hay categorías';

  @override
  String get categoriesEmptyDescription =>
      'Crea tu primera categoría para poder registrar movimientos.';

  @override
  String get categoriesEmptyAction => '+ Nueva categoría';

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
      'Lo que sobre del presupuesto pasa al mes siguiente, y lo que te pases se descuenta. Se reinicia cada enero.';

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
      other: '$count facturas recurrentes',
      one: '1 factura recurrente',
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
}
