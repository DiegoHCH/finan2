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

  /// No description provided for @transactionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get transactionsTitle;

  /// No description provided for @transactionsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get transactionsNewTitle;

  /// No description provided for @transactionsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar movimiento'**
  String get transactionsEditTitle;

  /// No description provided for @transactionsDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar movimiento'**
  String get transactionsDelete;

  /// No description provided for @transactionsDeleted.
  ///
  /// In es, this message translates to:
  /// **'Movimiento borrado'**
  String get transactionsDeleted;

  /// No description provided for @transactionsDeleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo borrar'**
  String get transactionsDeleteFailed;

  /// No description provided for @transactionsMaxTagsTitle.
  ///
  /// In es, this message translates to:
  /// **'Máximo {max} etiquetas'**
  String transactionsMaxTagsTitle(int max);

  /// No description provided for @transactionsMaxTagsMessage.
  ///
  /// In es, this message translates to:
  /// **'Quita una antes de añadir otra.'**
  String get transactionsMaxTagsMessage;

  /// No description provided for @transactionsCreditCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de crédito'**
  String get transactionsCreditCard;

  /// No description provided for @transactionsIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Completa el monto, la categoría y la cuenta.'**
  String get transactionsIncomplete;

  /// No description provided for @transactionsNoCategoriesOfType.
  ///
  /// In es, this message translates to:
  /// **'No hay categorías de este tipo todavía. Créalas en Ajustes.'**
  String get transactionsNoCategoriesOfType;

  /// No description provided for @transactionsNoAccounts.
  ///
  /// In es, this message translates to:
  /// **'No hay cuentas todavía. Créalas en Ajustes.'**
  String get transactionsNoAccounts;

  /// No description provided for @transactionsSelectAccount.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una cuenta'**
  String get transactionsSelectAccount;

  /// No description provided for @transactionsTags.
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get transactionsTags;

  /// Tags are lowercase words joined by hyphens.
  ///
  /// In es, this message translates to:
  /// **'Añadir etiqueta, por ejemplo viaje-cartagena'**
  String get transactionsAddTagHint;

  /// No description provided for @transactionsAddTag.
  ///
  /// In es, this message translates to:
  /// **'Añadir etiqueta'**
  String get transactionsAddTag;

  /// Label above the member chips on an income: who received it.
  ///
  /// In es, this message translates to:
  /// **'Lo recibió'**
  String get transactionsReceivedBy;

  /// Label above the member chips: who paid the movement.
  ///
  /// In es, this message translates to:
  /// **'Pagó'**
  String get transactionsPaidBy;

  /// No description provided for @transactionsLoggedBy.
  ///
  /// In es, this message translates to:
  /// **'Registrado por'**
  String get transactionsLoggedBy;

  /// Header: the net of the listed movements, already formatted as money.
  ///
  /// In es, this message translates to:
  /// **'{amount} neto'**
  String transactionsNet(String amount);

  /// No description provided for @transactionsNetInYear.
  ///
  /// In es, this message translates to:
  /// **'{amount} neto en {year}'**
  String transactionsNetInYear(String amount, int year);

  /// Appended to the header's net when filters or a search are on.
  ///
  /// In es, this message translates to:
  /// **'{text} · filtrado'**
  String transactionsFiltered(String text);

  /// No description provided for @transactionsPreviousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get transactionsPreviousMonth;

  /// No description provided for @transactionsNextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get transactionsNextMonth;

  /// No description provided for @transactionsSearchWholeYear.
  ///
  /// In es, this message translates to:
  /// **'Buscar en todo {year}'**
  String transactionsSearchWholeYear(int year);

  /// No description provided for @transactionsNoMatchTitle.
  ///
  /// In es, this message translates to:
  /// **'Nada coincide'**
  String get transactionsNoMatchTitle;

  /// No description provided for @transactionsNoMatchYear.
  ///
  /// In es, this message translates to:
  /// **'Ningún movimiento de {year} coincide con la búsqueda.'**
  String transactionsNoMatchYear(int year);

  /// month is a month and year, e.g. Julio 2026.
  ///
  /// In es, this message translates to:
  /// **'Ningún movimiento de {month} coincide con la búsqueda o los filtros.'**
  String transactionsNoMatchMonth(String month);

  /// No description provided for @transactionsClearSearch.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get transactionsClearSearch;

  /// No description provided for @transactionsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay movimientos'**
  String get transactionsEmptyTitle;

  /// No description provided for @transactionsEmptyTitleMonth.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos en {month}'**
  String transactionsEmptyTitleMonth(String month);

  /// No description provided for @transactionsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primer ingreso o gasto del mes y aquí verás el resumen del hogar.'**
  String get transactionsEmptyDescription;

  /// No description provided for @transactionsEmptyDescriptionMonth.
  ///
  /// In es, this message translates to:
  /// **'No se registró ningún ingreso ni gasto este mes.'**
  String get transactionsEmptyDescriptionMonth;

  /// No description provided for @transactionsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Agregar el primero'**
  String get transactionsEmptyAction;

  /// No description provided for @transactionsRecurringBills.
  ///
  /// In es, this message translates to:
  /// **'Facturas recurrentes'**
  String get transactionsRecurringBills;

  /// No description provided for @transactionsNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get transactionsNotes;

  /// No description provided for @transactionsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar descripción, categoría o monto'**
  String get transactionsSearchHint;

  /// No description provided for @transactionsFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get transactionsFilters;

  /// No description provided for @transactionsFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtrar movimientos'**
  String get transactionsFilterTitle;

  /// No description provided for @transactionsFilterType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get transactionsFilterType;

  /// No description provided for @transactionsFilterNoCategories.
  ///
  /// In es, this message translates to:
  /// **'No hay categorías de este tipo.'**
  String get transactionsFilterNoCategories;

  /// No description provided for @transactionsFilterTag.
  ///
  /// In es, this message translates to:
  /// **'Etiqueta'**
  String get transactionsFilterTag;

  /// No description provided for @transactionsFilterClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get transactionsFilterClear;

  /// No description provided for @transactionsFilterApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get transactionsFilterApply;

  /// No description provided for @transfersTitle.
  ///
  /// In es, this message translates to:
  /// **'Transferir'**
  String get transfersTitle;

  /// No description provided for @transfersInvalid.
  ///
  /// In es, this message translates to:
  /// **'Elige un monto y dos cuentas distintas.'**
  String get transfersInvalid;

  /// No description provided for @transfersAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto a transferir'**
  String get transfersAmountLabel;

  /// No description provided for @transfersFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get transfersFrom;

  /// No description provided for @transfersTo.
  ///
  /// In es, this message translates to:
  /// **'Hacia'**
  String get transfersTo;

  /// No description provided for @transfersSelectAccount.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una cuenta'**
  String get transfersSelectAccount;

  /// No description provided for @transfersHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Transferencias'**
  String get transfersHistoryTitle;

  /// No description provided for @transfersDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar transferencia'**
  String get transfersDeleteTitle;

  /// No description provided for @transfersDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se revertirá el ajuste de saldo en ambas cuentas. Esta acción no se puede deshacer.'**
  String get transfersDeleteMessage;

  /// Shown in place of the name of an account that no longer exists.
  ///
  /// In es, this message translates to:
  /// **'Cuenta eliminada'**
  String get transfersDeletedAccount;

  /// No description provided for @transfersEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay transferencias'**
  String get transfersEmptyTitle;

  /// No description provided for @transfersEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Los movimientos de dinero entre tus propias cuentas aparecerán aquí.'**
  String get transfersEmptyDescription;

  /// No description provided for @transfersEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Transferir'**
  String get transfersEmptyAction;

  /// No description provided for @accountsTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get accountsTitle;

  /// No description provided for @accountsAvailableMoney.
  ///
  /// In es, this message translates to:
  /// **'Dinero disponible'**
  String get accountsAvailableMoney;

  /// No description provided for @accountsTotalAvailable.
  ///
  /// In es, this message translates to:
  /// **'Total disponible'**
  String get accountsTotalAvailable;

  /// No description provided for @accountsCountInHousehold.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{en 1 cuenta del hogar} other{en {count} cuentas del hogar}}'**
  String accountsCountInHousehold(int count);

  /// No description provided for @accountsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cuentas'**
  String get accountsEmptyTitle;

  /// No description provided for @accountsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Agrega tu primera cuenta (efectivo, banco, billetera) para empezar a registrar movimientos.'**
  String get accountsEmptyDescription;

  /// No description provided for @accountsEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Nueva cuenta'**
  String get accountsEmptyAction;

  /// No description provided for @accountsTransferBetween.
  ///
  /// In es, this message translates to:
  /// **'Transferir entre cuentas'**
  String get accountsTransferBetween;

  /// No description provided for @accountsHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get accountsHistory;

  /// No description provided for @accountsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get accountsNewTitle;

  /// No description provided for @accountsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar cuenta'**
  String get accountsEditTitle;

  /// No description provided for @accountsTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de cuenta'**
  String get accountsTypeLabel;

  /// No description provided for @accountsCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get accountsCurrentBalance;

  /// No description provided for @accountsIncludeInAvailable.
  ///
  /// In es, this message translates to:
  /// **'Incluir en dinero disponible'**
  String get accountsIncludeInAvailable;

  /// No description provided for @accountsDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get accountsDeleteTitle;

  /// No description provided for @accountsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Esta acción no se puede deshacer.'**
  String accountsDeleteMessage(String name);

  /// No description provided for @accountsCannotDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar'**
  String get accountsCannotDeleteTitle;

  /// No description provided for @accountsCannotDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" tiene {count, plural, =1{1 registro} other{{count} registros}} (movimientos, transferencias, pagos de tarjeta o facturas recurrentes). Bórralos o cámbialos de cuenta primero. Si solo quieres que no sume, desactiva \"Incluir en dinero disponible\".'**
  String accountsCannotDeleteMessage(String name, int count);

  /// Account types.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get accountsTypeCash;

  /// No description provided for @accountsTypeBank.
  ///
  /// In es, this message translates to:
  /// **'Banco'**
  String get accountsTypeBank;

  /// A digital wallet app, e.g. Nequi.
  ///
  /// In es, this message translates to:
  /// **'Billetera'**
  String get accountsTypeWallet;

  /// No description provided for @accountsTypeDebit.
  ///
  /// In es, this message translates to:
  /// **'Débito'**
  String get accountsTypeDebit;

  /// No description provided for @categoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categoriesTitle;

  /// How many categories the household has.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 activa} other{{count} activas}}'**
  String categoriesActiveCount(int count);

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay categorías'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera categoría para poder registrar movimientos.'**
  String get categoriesEmptyDescription;

  /// No description provided for @categoriesEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'+ Nueva categoría'**
  String get categoriesEmptyAction;

  /// No description provided for @categoriesNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get categoriesNewTitle;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar categoría'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesPreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get categoriesPreview;

  /// No description provided for @categoriesTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get categoriesTypeLabel;

  /// No description provided for @categoriesIcon.
  ///
  /// In es, this message translates to:
  /// **'Ícono'**
  String get categoriesIcon;

  /// No description provided for @categoriesColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get categoriesColor;

  /// No description provided for @categoriesRolloverTitle.
  ///
  /// In es, this message translates to:
  /// **'Acumular de un mes a otro'**
  String get categoriesRolloverTitle;

  /// No description provided for @categoriesRolloverSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que sobre del presupuesto pasa al mes siguiente, y lo que te pases se descuenta. Se reinicia cada enero.'**
  String get categoriesRolloverSubtitle;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Esta acción no se puede deshacer.'**
  String categoriesDeleteMessage(String name);

  /// No description provided for @categoriesCannotDeleteYetTitle.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar todavía'**
  String get categoriesCannotDeleteYetTitle;

  /// usage is categoriesUsage*, e.g. 2 movimientos y 1 factura recurrente; type is the category type in lowercase.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" tiene {usage}. Crea otra categoría de {type} para pasarlos ahí y luego elimina esta.'**
  String categoriesCannotDeleteYetMessage(String name, String usage, String type);

  /// No description provided for @categoriesReassignTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A dónde pasamos lo de {name}?'**
  String categoriesReassignTitle(String name);

  /// No description provided for @categoriesReassignMessage.
  ///
  /// In es, this message translates to:
  /// **'Tiene {usage}. Elige la categoría que se quedará con ellos; después \"{name}\" se elimina.'**
  String categoriesReassignMessage(String usage, String name);

  /// No description provided for @categoriesUsageMovements.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 movimiento} other{{count} movimientos}}'**
  String categoriesUsageMovements(int count);

  /// No description provided for @categoriesUsageRecurringBills.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 factura recurrente} other{{count} facturas recurrentes}}'**
  String categoriesUsageRecurringBills(int count);

  /// No description provided for @categoriesUsageBoth.
  ///
  /// In es, this message translates to:
  /// **'{movements} y {bills}'**
  String categoriesUsageBoth(String movements, String bills);

  /// Category types, singular.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get categoriesTypeIncome;

  /// No description provided for @categoriesTypeBill.
  ///
  /// In es, this message translates to:
  /// **'Factura'**
  String get categoriesTypeBill;

  /// No description provided for @categoriesTypeExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get categoriesTypeExpense;

  /// No description provided for @categoriesTypeSavings.
  ///
  /// In es, this message translates to:
  /// **'Ahorro'**
  String get categoriesTypeSavings;

  /// Category types, plural: section headers and filters.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get categoriesTypeIncomePlural;

  /// No description provided for @categoriesTypeBillPlural.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get categoriesTypeBillPlural;

  /// No description provided for @categoriesTypeExpensePlural.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get categoriesTypeExpensePlural;

  /// No description provided for @categoriesTypeSavingsPlural.
  ///
  /// In es, this message translates to:
  /// **'Ahorros'**
  String get categoriesTypeSavingsPlural;

  /// Default categories a new household starts with. Stored as data, in the language of the phone that created the household.
  ///
  /// In es, this message translates to:
  /// **'Salario'**
  String get categoriesDefaultSalary;

  /// No description provided for @categoriesDefaultFreelance.
  ///
  /// In es, this message translates to:
  /// **'Freelance'**
  String get categoriesDefaultFreelance;

  /// No description provided for @categoriesDefaultRent.
  ///
  /// In es, this message translates to:
  /// **'Arriendo'**
  String get categoriesDefaultRent;

  /// No description provided for @categoriesDefaultUtilities.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get categoriesDefaultUtilities;

  /// No description provided for @categoriesDefaultPhoneInternet.
  ///
  /// In es, this message translates to:
  /// **'Celular e internet'**
  String get categoriesDefaultPhoneInternet;

  /// No description provided for @categoriesDefaultStreaming.
  ///
  /// In es, this message translates to:
  /// **'Streaming'**
  String get categoriesDefaultStreaming;

  /// No description provided for @categoriesDefaultGroceries.
  ///
  /// In es, this message translates to:
  /// **'Mercado'**
  String get categoriesDefaultGroceries;

  /// No description provided for @categoriesDefaultTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get categoriesDefaultTransport;

  /// No description provided for @categoriesDefaultRestaurants.
  ///
  /// In es, this message translates to:
  /// **'Restaurantes'**
  String get categoriesDefaultRestaurants;

  /// No description provided for @categoriesDefaultLeisure.
  ///
  /// In es, this message translates to:
  /// **'Ocio'**
  String get categoriesDefaultLeisure;

  /// No description provided for @categoriesDefaultHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get categoriesDefaultHealth;

  /// No description provided for @categoriesDefaultHomeCleaning.
  ///
  /// In es, this message translates to:
  /// **'Hogar y aseo'**
  String get categoriesDefaultHomeCleaning;

  /// No description provided for @categoriesDefaultEmergencyFund.
  ///
  /// In es, this message translates to:
  /// **'Fondo de emergencia'**
  String get categoriesDefaultEmergencyFund;

  /// No description provided for @categoriesDefaultTravel.
  ///
  /// In es, this message translates to:
  /// **'Viaje'**
  String get categoriesDefaultTravel;
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
