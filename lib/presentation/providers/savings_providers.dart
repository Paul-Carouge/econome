import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

// ─── Savings Providers ────────────────────────────────────────────────
final savingsListProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(savingsDaoProvider).watchAll();
});
