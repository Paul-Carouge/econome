import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

// ─── Category Providers ───────────────────────────────────────────────
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryDaoProvider).watchExpenseCategories();
});

final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryDaoProvider).watchAll();
});
