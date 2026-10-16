import 'avalanche_calculator.dart';
import 'entities/debt.dart';

/// «Un poco más» for a monthly [payment]: about a quarter of it, rounded
/// down to its leading digit - $100.000 on a $420.000 installment, $200.000
/// on $1.000.000. 0 with nothing paid.
int nudgeAmount(int payment) {
  if (payment <= 0) return 0;
  final quarter = payment ~/ 4;
  if (quarter <= 0) return 0;
  var magnitude = 1;
  while (magnitude * 10 <= quarter) {
    magnitude *= 10;
  }
  return quarter ~/ magnitude * magnitude;
}

/// What a loan being filled in says before it's saved: the month it ends
/// with the payment as typed, and the month it would end paying [more] on
/// top each month. A null date means that payment never catches up with the
/// interest.
class LoanPayoffPreview {
  const LoanPayoffPreview({required this.end, required this.more, required this.endWithMore});

  final DateTime? end;
  final int more;
  final DateTime? endWithMore;
}

/// The preview for [draft] seen from [now]; null until there's something to
/// work out - a balance and a payment.
LoanPayoffPreview? loanPayoffPreview(Debt draft, DateTime now) {
  if (draft.balance <= 0 || draft.monthlyBasePayment <= 0) return null;
  final more = nudgeAmount(draft.monthlyBasePayment);
  final faster = Debt(
    id: draft.id,
    name: draft.name,
    type: draft.type,
    balance: draft.balance,
    rate: draft.rate,
    paymentDay: draft.paymentDay,
    creditLimit: draft.creditLimit,
    minPayment: draft.minPayment,
    extraPayment: draft.extraPayment + more,
    cutoffDay: draft.cutoffDay,
    originalAmount: draft.originalAmount,
    monthlyPayment: draft.monthlyPayment,
    termMonths: draft.termMonths,
    paidInstallments: draft.paidInstallments,
  );
  return LoanPayoffPreview(
    end: computeAvalanche([draft], now: now).freeDate,
    more: more,
    endWithMore: more > 0 ? computeAvalanche([faster], now: now).freeDate : null,
  );
}
