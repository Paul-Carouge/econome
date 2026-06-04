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

  Future<int> upsert(BudgetsCompanion entry) =>
      into(budgets).insertOnConflictUpdate(entry);

  Future<int> deleteEntry(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();
}
