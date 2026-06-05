import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

part 'category_providers.g.dart';

// ─── Category Providers ───────────────────────────────────────────────
@riverpod
Stream<List<Category>> expenseCategories(ExpenseCategoriesRef ref) {
  return ref.watch(categoryDaoProvider).watchExpenseCategories();
}

@riverpod
Stream<List<Category>> allCategories(AllCategoriesRef ref) {
  return ref.watch(categoryDaoProvider).watchAll();
}
