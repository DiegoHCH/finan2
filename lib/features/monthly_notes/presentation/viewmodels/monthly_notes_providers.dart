import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/monthly_notes_model.dart';
import '../../data/monthly_notes_repository.dart';

final monthlyNotesRepositoryProvider = Provider<MonthlyNotesRepository>((ref) {
  return MonthlyNotesRepository();
});

final currentMonthNotesProvider = StreamProvider<MonthlyNotes>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(MonthlyNotes.empty);
  final now = DateTime.now();
  return ref
      .watch(monthlyNotesRepositoryProvider)
      .watchNotes(householdId, year: now.year, month: now.month);
});

class MonthlyNotesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> saveThisMonth(String text) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final now = DateTime.now();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(monthlyNotesRepositoryProvider).saveThisMonth(
            householdId,
            year: now.year,
            month: now.month,
            text: text,
          ),
    );
  }

  Future<void> saveNextMonth(String text) async {
    final householdId = ref.read(currentHouseholdProvider).value?.id;
    if (householdId == null) return;
    final now = DateTime.now();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(monthlyNotesRepositoryProvider).saveNextMonth(
            householdId,
            year: now.year,
            month: now.month,
            text: text,
          ),
    );
  }
}

final monthlyNotesControllerProvider =
    AsyncNotifierProvider<MonthlyNotesController, void>(
  MonthlyNotesController.new,
);
