import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/crypto/household_crypto.dart';
import '../../accounts/data/account_model.dart';
import '../../categories/data/category_model.dart';
import '../../debts/data/card_payment_mapper.dart';
import '../../debts/data/debt_mapper.dart';
import '../../debts/domain/entities/card_payment.dart';
import '../../debts/domain/entities/debt.dart';
import '../../investments/data/investment_model.dart';
import '../../recurring_bills/data/recurring_bill_mapper.dart';
import '../../recurring_bills/domain/entities/recurring_bill.dart';
import '../../savings_goals/data/savings_goal_model.dart';
import '../../transactions/data/movement_mapper.dart';
import '../../transactions/domain/entities/movement.dart';
import '../../transfers/data/transfer_model.dart';
import '../domain/demo_ids.dart';

/// Where demo records live; the markers and notices derived from them too.
const _demoCollections = [
  'accounts',
  'cardPayments',
  'categories',
  'debts',
  'goalAlerts',
  'investments',
  'notifications',
  'pendingBills',
  'recurringBills',
  'recurringDone',
  'savingsGoals',
  'transactions',
  'transfers',
];

/// Budget amounts are fields of a month's document, not documents of their
/// own: the ones demo data set are remembered on this phone to undo them.
const _budgetFieldsKey = 'demo_budget_fields';

/// Fills a household with three months of a plausible couple's money -
/// accounts, a card and a loan, goals, investments, recurring bills and
/// movements - encrypted with its key like anything typed in. Balances are
/// written as they'd stand, not replayed from the movements.
class DemoDataRepository {
  DemoDataRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
    : _db = firestore ?? FirebaseFirestore.instance,
      _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  DocumentReference<Map<String, dynamic>> _household(String id) =>
      _db.collection('households').doc(id);

  /// Returns how many records were written.
  Future<int> seed(
    String householdId, {
    required String uid,
    String partnerUid = '',
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final household = _household(householdId);
    final writes = _Writes(_db);
    final random = Random(42);
    int between(int min, int max) => (min + random.nextInt(max - min + 1)) ~/ 100 * 100;

    // Categories: the household's own where it has them, by icon.
    final existing = (await household.collection('categories').get()).docs
        .map(Category.fromFirestore)
        .toList();
    final categoryIds = <String, String>{};
    for (final (slug, name, type, color) in _categories) {
      final own = existing.where((c) => c.iconSlug == slug && c.type == type).firstOrNull;
      if (own != null) {
        categoryIds[slug] = own.id;
        continue;
      }
      final id = '${demoIdPrefix}cat_$slug';
      categoryIds[slug] = id;
      writes.set(
        household.collection('categories').doc(id),
        Category(
          id: id,
          name: name,
          type: type,
          iconSlug: slug,
          color: color,
          createdBy: uid,
        ).toFirestore(),
      );
    }

    // Accounts and debts.
    const bank = '${demoIdPrefix}acc_bancolombia';
    const wallet = '${demoIdPrefix}acc_nequi';
    const cash = '${demoIdPrefix}acc_efectivo';
    const savings = '${demoIdPrefix}acc_ahorros';
    const card = '${demoIdPrefix}debt_visa';
    for (final account in [
      Account(
        id: bank,
        name: 'Bancolombia',
        type: AccountType.banco,
        balance: 3250000,
        includeInAvailable: true,
        createdBy: uid,
      ),
      Account(
        id: wallet,
        name: 'Nequi',
        type: AccountType.billetera,
        balance: 412000,
        includeInAvailable: true,
        createdBy: uid,
      ),
      Account(
        id: cash,
        name: 'Efectivo',
        type: AccountType.efectivo,
        balance: 95000,
        includeInAvailable: true,
        createdBy: uid,
      ),
      Account(
        id: savings,
        name: 'Cuenta de ahorros',
        type: AccountType.banco,
        balance: 6800000,
        includeInAvailable: false,
        createdBy: uid,
      ),
    ]) {
      writes.set(
        household.collection('accounts').doc(account.id),
        await account.toFirestore(_crypto, householdId),
      );
    }
    for (final debt in [
      Debt(
        id: card,
        name: 'Visa Bancolombia',
        type: DebtType.tarjeta,
        balance: 1850000,
        rate: 28.5,
        paymentDay: 10,
        creditLimit: 6000000,
        minPayment: 180000,
        cutoffDay: 25,
        createdBy: uid,
      ),
      Debt(
        id: '${demoIdPrefix}debt_carro',
        name: 'Crédito del carro',
        type: DebtType.vehiculo,
        balance: 18500000,
        rate: 16.5,
        paymentDay: 5,
        originalAmount: 32000000,
        monthlyPayment: 890000,
        termMonths: 48,
        paidInstallments: 18,
        createdBy: uid,
      ),
    ]) {
      writes.set(household.collection('debts').doc(debt.id), {
        ...await debt.toFirestore(_crypto, householdId),
        // Read by the Worker's payment reminders only: demo debts stay quiet.
        'hasBalance': false,
      });
    }

    // Three months: two closed, and this one up to today.
    final months = [for (var back = 2; back >= 0; back--) DateTime(today.year, today.month - back)];
    DateTime? on(DateTime month, int day) {
      final last = DateTime(month.year, month.month + 1, 0).day;
      final date = DateTime(month.year, month.month, min(day, last), 12);
      return date.isAfter(today) ? null : date;
    }

    var n = 0;
    void movement(
      DateTime? date,
      int amount,
      String slug,
      String description, {
      String account = bank,
      bool onCard = false,
      bool partner = false,
      List<String> tags = const [],
    }) {
      if (date == null) return;
      final id = '${demoIdPrefix}tx_${n++}';
      final type = _categories.firstWhere((c) => c.$1 == slug).$3;
      writes.later(
        household.collection('transactions').doc(id),
        () => Movement(
          id: id,
          amount: amount,
          type: type,
          categoryId: categoryIds[slug]!,
          accountId: onCard ? '' : account,
          cardDebtId: onCard ? card : '',
          description: description,
          date: date,
          createdBy: uid,
          paidBy: partner && partnerUid.isNotEmpty ? partnerUid : uid,
          tags: tags,
        ).toFirestore(_crypto, householdId),
      );
    }

    for (final (i, month) in months.indexed) {
      final closed = i < months.length - 1;
      movement(on(month, 1), 4800000, 'salario', 'Salario');
      movement(on(month, 1), 3900000, 'salario', 'Salario', partner: true);
      if (i == 1) {
        movement(on(month, 14), 850000, 'freelance', 'Proyecto de diseño', account: wallet);
      }
      // This month's rent and fijos come from the recurring bills below.
      if (closed) {
        movement(on(month, 1), 1600000, 'arriendo', 'Arriendo');
        movement(on(month, 12), 120000, 'celular', 'Internet y celular', partner: true);
        movement(on(month, 18), 45000, 'streaming', 'Netflix', onCard: true);
      }
      movement(on(month, 8), between(210000, 260000), 'servicios', 'Luz, agua y gas');
      movement(on(month, 2), 500000, 'emergencia', 'Fondo de emergencia', account: savings);
      movement(on(month, 2), 400000, 'viaje', 'Ahorro viaje', account: savings, partner: true);
      for (final (day, place) in [
        (4, 'Éxito'),
        (11, 'D1'),
        (18, 'Carulla'),
        (25, 'Plaza de mercado'),
      ]) {
        movement(
          on(month, day),
          between(150000, 320000),
          'mercado',
          place,
          onCard: day.isEven,
          partner: day > 15,
          tags: day == 25 ? const ['fruta'] : const [],
        );
      }
      for (final (day, what) in [
        (3, 'Uber'),
        (7, 'Gasolina'),
        (13, 'Peaje'),
        (16, 'Uber'),
        (22, 'Gasolina'),
        (27, 'Parqueadero'),
      ]) {
        movement(
          on(month, day),
          between(12000, 140000),
          'transporte',
          what,
          account: day.isOdd ? wallet : cash,
          partner: day > 20,
        );
      }
      for (final (day, place) in [
        (6, 'Almuerzo'),
        (14, 'Domicilio Rappi'),
        (20, 'Crepes & Waffles'),
        (28, 'Café'),
      ]) {
        movement(
          on(month, day),
          between(18000, 140000),
          'restaurante',
          place,
          onCard: true,
          partner: day.isEven,
          tags: day == 20 ? const ['salida'] : const [],
        );
      }
      movement(
        on(month, 9),
        between(40000, 120000),
        'ocio',
        i.isEven ? 'Cine' : 'Concierto',
        partner: true,
        tags: const ['salida'],
      );
      movement(on(month, 23), between(60000, 150000), 'salud', 'Farmacia', account: wallet);
      movement(
        on(month, 15),
        between(50000, 110000),
        'hogar_aseo',
        'Aseo del hogar',
        partner: true,
      );

      if (closed) {
        final paid = on(month, 10)!;
        final paymentId = '${demoIdPrefix}payment_$i';
        writes.later(
          household.collection('cardPayments').doc(paymentId),
          () => CardPayment(
            id: paymentId,
            amount: 950000,
            fromAccountId: bank,
            cardDebtId: card,
            date: paid,
            createdBy: uid,
          ).toFirestore(_crypto, householdId),
        );
      }
      final moved = on(month, 3);
      if (moved != null) {
        final transferId = '${demoIdPrefix}transfer_$i';
        writes.later(
          household.collection('transfers').doc(transferId),
          () => Transfer(
            id: transferId,
            amount: closed ? 300000 : 150000,
            fromAccountId: bank,
            toAccountId: closed ? wallet : cash,
            date: moved,
            createdBy: uid,
          ).toFirestore(_crypto, householdId),
        );
      }
    }

    // Recurring bills: the app makes this month's movement when each is due.
    for (final (slug, name, amount, day) in [
      ('arriendo', 'Arriendo', 1600000, 1),
      ('celular', 'Internet y celular', 120000, 12),
      ('streaming', 'Netflix', 45000, 18),
    ]) {
      final id = '${demoIdPrefix}bill_$slug';
      writes.later(
        household.collection('recurringBills').doc(id),
        () => RecurringBill(
          id: id,
          name: name,
          type: CategoryType.factura,
          categoryId: categoryIds[slug]!,
          accountId: bank,
          amount: amount,
          dayOfMonth: day,
          startDate: months.first,
          createdBy: uid,
        ).toFirestore(_crypto, householdId),
      );
    }

    // Goals, with what's been put in them so far.
    for (final (slug, name, target, targetDate, monthly, rate, paid) in [
      (
        'viaje',
        'Viaje a Cartagena',
        4000000,
        DateTime(today.year, today.month + 8),
        400000,
        0.0,
        400000,
      ),
      ('emergencia', 'Fondo de emergencia', 9000000, null, 500000, 9.5, 500000),
    ]) {
      final id = '${demoIdPrefix}goal_$slug';
      writes.later(
        household.collection('savingsGoals').doc(id),
        () => SavingsGoal(
          id: id,
          name: name,
          iconSlug: slug,
          targetAmount: target,
          targetDate: targetDate,
          monthlyContribution: monthly,
          interestRate: rate,
          contributions: [
            for (var back = slug == 'viaje' ? 3 : 6; back >= 0; back--)
              Contribution(
                date: DateTime(today.year, today.month - back, 2),
                amount: paid,
                createdBy: uid,
              ),
          ],
          createdBy: uid,
        ).toFirestore(_crypto, householdId),
      );
    }

    for (final investment in [
      Investment(
        id: '${demoIdPrefix}inv_cdt',
        name: 'CDT a 12 meses',
        kind: InvestmentKind.rentaFija,
        rate: 11.2,
        investedAmount: 5000000,
        currentValue: 5280000,
        createdBy: uid,
      ),
      Investment(
        id: '${demoIdPrefix}inv_etf',
        name: 'Fondo de acciones',
        kind: InvestmentKind.rentaVariable,
        rate: 0,
        investedAmount: 2000000,
        currentValue: 2150000,
        createdBy: uid,
      ),
    ]) {
      writes.later(
        household.collection('investments').doc(investment.id),
        () => investment.toFirestore(_crypto, householdId),
      );
    }

    // This month's plan, only for categories it doesn't already budget.
    final budgetRef = household.collection('budgets').doc('${today.year}_${today.month}');
    final budget = (await budgetRef.get()).data() ?? const {};
    final setFields = <String>[];
    final plan = <String, Object>{};
    for (final (slug, amount) in [
      ('mercado', 1200000),
      ('transporte', 350000),
      ('restaurante', 450000),
      ('ocio', 250000),
      ('salud', 200000),
      ('hogar_aseo', 150000),
      ('servicios', 300000),
      ('arriendo', 1600000),
    ]) {
      final categoryId = categoryIds[slug]!;
      if (budget.containsKey(categoryId)) continue;
      plan[categoryId] = await _crypto.encryptAmount(householdId, amount);
      setFields.add('${budgetRef.id}|$categoryId');
    }
    if (plan.isNotEmpty) writes.merge(budgetRef, plan);

    final written = await writes.flush();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _budgetFieldsKey,
      {...?prefs.getStringList(_budgetFieldsKey), ...setFields}.toList(),
    );
    return written;
  }

  /// Deletes every demo record and what was derived from it, and the budget
  /// amounts demo data set from this phone. Returns how many documents went.
  Future<int> remove(String householdId) async {
    final household = _household(householdId);
    final writes = _Writes(_db);
    for (final name in _demoCollections) {
      for (final doc in (await household.collection(name).get()).docs) {
        if (isDemoId(doc.id)) writes.delete(doc.reference);
      }
    }
    final removed = await writes.flush();

    final prefs = await SharedPreferences.getInstance();
    final fields = prefs.getStringList(_budgetFieldsKey) ?? const [];
    final byMonth = <String, Map<String, Object>>{};
    for (final entry in fields) {
      final [month, categoryId] = entry.split('|');
      (byMonth[month] ??= {})[categoryId] = FieldValue.delete();
    }
    for (final MapEntry(key: month, value: deletions) in byMonth.entries) {
      writes.merge(household.collection('budgets').doc(month), deletions);
    }
    await writes.flush();
    await prefs.remove(_budgetFieldsKey);
    return removed;
  }
}

/// The categories demo movements use: slug, name if the household lacks
/// it, type and color.
const _categories = [
  ('salario', 'Salario', CategoryType.ingreso, 0xFF16A34A),
  ('freelance', 'Trabajos extra', CategoryType.ingreso, 0xFF16A34A),
  ('arriendo', 'Arriendo', CategoryType.factura, 0xFF0F766E),
  ('servicios', 'Servicios', CategoryType.factura, 0xFF475569),
  ('celular', 'Celular e internet', CategoryType.factura, 0xFF0284C7),
  ('streaming', 'Suscripciones', CategoryType.factura, 0xFFDB2777),
  ('mercado', 'Mercado', CategoryType.gasto, 0xFFEA580C),
  ('transporte', 'Transporte', CategoryType.gasto, 0xFF2563EB),
  ('restaurante', 'Restaurantes', CategoryType.gasto, 0xFFDC2626),
  ('ocio', 'Ocio', CategoryType.gasto, 0xFF7C3AED),
  ('salud', 'Salud', CategoryType.gasto, 0xFF059669),
  ('hogar_aseo', 'Hogar y aseo', CategoryType.gasto, 0xFF0891B2),
  ('emergencia', 'Fondo de emergencia', CategoryType.ahorro, 0xFF4F46E5),
  ('viaje', 'Viajes', CategoryType.ahorro, 0xFF0EA5E9),
];

/// Firestore commits at most 500 writes at once.
class _Writes {
  _Writes(this._db);

  final FirebaseFirestore _db;
  final _pending = <Future<void> Function(WriteBatch)>[];

  void set(DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data) =>
      _pending.add((batch) async => batch.set(ref, data));

  /// For data that needs encrypting first.
  void later(
    DocumentReference<Map<String, dynamic>> ref,
    Future<Map<String, dynamic>> Function() data,
  ) => _pending.add((batch) async => batch.set(ref, await data()));

  void merge(DocumentReference<Map<String, dynamic>> ref, Map<String, Object> data) =>
      _pending.add((batch) async => batch.set(ref, data, SetOptions(merge: true)));

  void delete(DocumentReference<Map<String, dynamic>> ref) =>
      _pending.add((batch) async => batch.delete(ref));

  /// Commits everything pending; returns how many writes there were.
  Future<int> flush() async {
    final total = _pending.length;
    for (var start = 0; start < _pending.length; start += 400) {
      final batch = _db.batch();
      for (final add in _pending.skip(start).take(400)) {
        await add(batch);
      }
      await batch.commit();
    }
    _pending.clear();
    return total;
  }
}
