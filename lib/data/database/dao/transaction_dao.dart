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

  /// Returns total income for [month]/[year] using SQL SUM.
  Future<double> getTotalIncome(int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE type = ? AND date >= ? AND date < ?',
      variables: [Variable.withString('income'), Variable.withString(start), Variable.withString(end)],
    ).get();
    return rows.first.read<double>('total');
  }

  /// Returns total expenses for [month]/[year] using SQL SUM.
  Future<double> getTotalExpenses(int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE type = ? AND date >= ? AND date < ?',
      variables: [Variable.withString('expense'), Variable.withString(start), Variable.withString(end)],
    ).get();
    return rows.first.read<double>('total');
  }

  /// Returns a map of categoryId → total amount for expenses in [month]/[year]
  /// using SQL GROUP BY — no Dart loops.
  Future<Map<int, double>> getExpensesByCategory(int month, int year) async {
    final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(year, month + 1, 1).toIso8601String().substring(0, 10);
    final rows = await customSelect(
      'SELECT category_id, COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE type = ? AND date >= ? AND date < ? '
      'GROUP BY category_id',
      variables: [Variable.withString('expense'), Variable.withString(start), Variable.withString(end)],
    ).get();
    return {
      for (final row in rows)
        row.read<int>('category_id'): row.read<double>('total'),
    };
  }

  Future<int> insert(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateEntry(int id, TransactionsCompanion entry) async =>
      (await (update(transactions)..where((t) => t.id.equals(id))).write(entry)) > 0;

  Future<int> deleteEntry(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
}
