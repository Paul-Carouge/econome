import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

// ─── Budget Providers ─────────────────────────────────────────────────
final currentBudgetProvider = FutureProvider<Budget?>((ref) async {
  final now = DateTime.now();
  return ref.watch(budgetDaoProvider).getByMonth(now.month, now.year);
});
