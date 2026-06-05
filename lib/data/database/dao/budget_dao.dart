import 'package:drift/drift.dart';
import '../app_database.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(AppDatabase db) : super(db);

  Stream<List<Budget>> watchAll() =>
      (select(budgets)..orderBy([(b) => OrderingTerm.desc(b.year), (b) => OrderingTerm.desc(b.month)])).watch();

  Future<Budget?> getByMonth(int month, int year) =>
      (select(budgets)..where((b) => b.month.equals(month) & b.year.equals(year))).getSingleOrNull();

  /// Inserts or updates a budget for a given month/year.
  ///
  /// Drift's [insertOnConflictUpdate] can fail with certain SQLite versions
  /// when the companion doesn't include the full conflict target.
  /// This explicit approach avoids that: look up first, then insert or update.
  Future<int> upsert(BudgetsCompanion entry) async {
    final month = entry.month.value;
    final year = entry.year.value;

    final existing = await getByMonth(month, year);
    if (existing != null) {
      // Update the existing row
      await (update(budgets)..where((b) => b.id.equals(existing.id)))
          .write(entry.copyWith(id: Value(existing.id)));
      return existing.id;
    } else {
      // Insert a new row
      return into(budgets).insert(entry);
    }
  }

  Future<int> deleteEntry(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();
}
