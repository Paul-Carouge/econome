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

  /// Returns total spent on a specific category using SQL SUM.
  Future<double> getTotalSpentByCategory(int categoryId, int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE category_id = ? AND type = ? AND date >= ? AND date < ?',
      variables: [
        Variable.withInt(categoryId),
        Variable.withString('expense'),
        Variable.withString(start),
        Variable.withString(end),
      ],
    ).get();
    return rows.first.read<double>('total');
  }
}
