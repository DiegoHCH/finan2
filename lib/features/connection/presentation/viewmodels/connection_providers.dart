import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/presentation/viewmodels/household_providers.dart';
import '../../data/connection_repository.dart';

final connectionRepositoryProvider = Provider<ConnectionRepository>(
  (ref) => ConnectionRepository(),
);

/// True while this device can't reach the server; false - and loading -
/// until it's known, so nothing is announced on a normal start.
final offlineProvider = StreamProvider<bool>((ref) {
  final householdId = ref.watch(currentHouseholdProvider).value?.id;
  if (householdId == null) return Stream.value(false);
  return ref.watch(connectionRepositoryProvider).watchOffline(householdId);
});
