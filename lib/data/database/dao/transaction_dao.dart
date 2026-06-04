import 'package:drift/drift.dart';
import '../app_database.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Categories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  Future<List<Transaction>> getAll() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Stream<List<Transaction>> watchAll() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<Transaction?> getById(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Transaction>> watchByMonth(int month, int year) {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    return (select(transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<Transaction>> getByMonth(int month, int year) {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    return (select(transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Transaction>> getRecent(int limit) =>
      (select(transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(limit))
          .get();

  Stream<List<Transaction>> watchRecent(int limit) =>
      (select(transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(limit))
          .watch();

  Future<double> getTotalIncome(int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await (select(transactions)
          ..where((t) =>
              t.type.equals('income') &
              t.date.isBetweenValues(start, end)))
        .get();
    double total = 0;
    for (final t in rows) total += t.amount;
    return total;
  }

  Future<double> getTotalExpenses(int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await (select(transactions)
          ..where((t) =>
              t.type.equals('expense') &
              t.date.isBetweenValues(start, end)))
        .get();
    double total = 0;
    for (final t in rows) total += t.amount;
    return total;
  }

  Future<Map<int, double>> getExpensesByCategory(int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await (select(transactions)
          ..where((t) =>
              t.type.equals('expense') &
              t.date.isBetweenValues(start, end)))
        .get();

    final map = <int, double>{};
    for (final row in rows) {
      map[row.categoryId] = (map[row.categoryId] ?? 0) + row.amount;
    }
    return map;
  }

  Future<int> insert(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateEntry(int id, TransactionsCompanion entry) async =>
      (await (update(transactions)..where((t) => t.id.equals(id))).write(entry)) > 0;

  Future<int> deleteEntry(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
}
