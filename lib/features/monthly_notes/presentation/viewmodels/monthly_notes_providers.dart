import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/year_month.dart';
import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/monthly_notes_model.dart';
import '../../data/monthly_notes_repository.dart';

final monthlyNotesRepositoryProvider = Provider<MonthlyNotesRepository>((ref) {
  return MonthlyNotesRepository();
});

/// Any month's notes, for Notas del mes while browsing.
final monthNotesProvider = StreamProvider.autoDispose.family<MonthlyNotes, YearMonth>((ref, month) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(MonthlyNotes.empty);
  return ref
      .watch(monthlyNotesRepositoryProvider)
      .watchNotes(householdId, year: month.year, month: month.month);
});

final currentMonthNotesProvider = StreamProvider<MonthlyNotes>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(MonthlyNotes.empty);
  final now = currentYearMonth();
  return ref
      .watch(monthlyNotesRepositoryProvider)
      .watchNotes(householdId, year: now.year, month: now.month);
});

class MonthlyNotesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// [month]'s note - the current month's by default.
  Future<void> saveThisMonth(String text, {YearMonth? month}) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final at = month ?? currentYearMonth();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(monthlyNotesRepositoryProvider)
          .saveThisMonth(householdId, year: at.year, month: at.month, text: text),
    );
  }

  /// What [month] leaves for the one after it.
  Future<void> saveNextMonth(String text, {YearMonth? month}) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final at = month ?? currentYearMonth();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(monthlyNotesRepositoryProvider)
          .saveNextMonth(householdId, year: at.year, month: at.month, text: text),
    );
  }
}

final monthlyNotesControllerProvider = AsyncNotifierProvider<MonthlyNotesController, void>(
  MonthlyNotesController.new,
);
