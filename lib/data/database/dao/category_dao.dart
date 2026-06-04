import 'package:drift/drift.dart';
import '../app_database.dart';
import '../seed_data.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories, Transactions])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  Future<List<Category>> getAll() => select(categories).get();

  Future<List<Category>> getByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).get();

  Future<Category?> getById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Category>> getExpenseCategories() =>
      (select(categories)..where((c) => c.type.equals('expense'))..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).get();

  Future<List<Category>> getIncomeCategories() =>
      (select(categories)..where((c) => c.type.equals('income'))..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).get();

  Stream<List<Category>> watchAll() => select(categories).watch();

  Stream<List<Category>> watchExpenseCategories() =>
      (select(categories)..where((c) => c.type.equals('expense'))..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).watch();

  Future<int> insert(CategoriesCompanion entry) => into(categories).insert(entry);

  Future<void> insertDefaults() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    for (final cat in CategorySeed.defaultCategories) {
      await into(categories).insert(CategoriesCompanion(
        name: Value(cat['name'] as String),
        icon: Value(cat['icon'] as String),
        color: Value(cat['color'] as int),
        type: Value(cat['type'] as String),
        sortOrder: Value(cat['sortOrder'] as int),
        isCustom: const Value(false),
      ));
    }
  }

  Future<bool> updateEntry(int id, CategoriesCompanion entry) async =>
      (await (update(categories)..where((c) => c.id.equals(id))).write(entry)) > 0;

  Future<int> deleteEntry(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  Future<double> getTotalSpentByCategory(int categoryId, int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);

    final rows = await (select(transactions)
          ..where((t) =>
              t.categoryId.equals(categoryId) &
              t.type.equals('expense') &
              t.date.isBetweenValues(start, end)))
        .get();
    return rows.map((t) => t.amount).reduce((a, b) => a + b);
  }
}
