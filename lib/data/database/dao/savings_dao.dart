import 'package:drift/drift.dart';
import '../app_database.dart';

part 'savings_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class SavingsDao extends DatabaseAccessor<AppDatabase> with _$SavingsDaoMixin {
  SavingsDao(AppDatabase db) : super(db);

  Stream<List<SavingsGoal>> watchAll() =>
      (select(savingsGoals)..orderBy([(g) => OrderingTerm.desc(g.createdAt)])).watch();

  Future<List<SavingsGoal>> getAll() =>
      (select(savingsGoals)..orderBy([(g) => OrderingTerm.desc(g.createdAt)])).get();

  Future<SavingsGoal?> getById(int id) =>
      (select(savingsGoals)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<int> insert(SavingsGoalsCompanion entry) =>
      into(savingsGoals).insert(entry);

  Future<bool> updateEntry(int id, SavingsGoalsCompanion entry) async =>
      (await (update(savingsGoals)..where((g) => g.id.equals(id))).write(entry)) > 0;

  Future<int> deleteEntry(int id) =>
      (delete(savingsGoals)..where((g) => g.id.equals(id))).go();

  Future<void> addContribution(int id, double amount) async {
    final goal = await getById(id);
    if (goal == null) return;

    final newAmount = goal.currentAmount + amount;
    final isComplete = newAmount >= goal.targetAmount;

    await (update(savingsGoals)..where((g) => g.id.equals(id))).write(
      SavingsGoalsCompanion(
        currentAmount: Value(newAmount),
        isCompleted: Value(isComplete),
      ),
    );

  }
}
