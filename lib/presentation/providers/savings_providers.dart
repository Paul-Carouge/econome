import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

part 'savings_providers.g.dart';

// ─── Savings Providers ────────────────────────────────────────────────
@riverpod
Stream<List<SavingsGoal>> savingsList(SavingsListRef ref) {
  return ref.watch(savingsDaoProvider).watchAll();
}
