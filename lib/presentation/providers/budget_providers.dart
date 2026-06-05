import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

part 'budget_providers.g.dart';

// ─── Budget Providers ─────────────────────────────────────────────────
@riverpod
Future<Budget?> currentBudget(CurrentBudgetRef ref) async {
  final now = DateTime.now();
  return ref.watch(budgetDaoProvider).getByMonth(now.month, now.year);
}
