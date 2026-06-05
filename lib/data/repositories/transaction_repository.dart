import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../database/dao/transaction_dao.dart';
import '../database/app_database.dart';

/// Repository that handles all transaction-related business logic.
///
/// Delegates data access to [TransactionDao] and wraps results in [Result].
class TransactionRepository {
  final TransactionDao _dao;

  TransactionRepository(this._dao);

  // ─── Queries ───────────────────────────────────────────────────────

  Future<Result<List<Transaction>>> getAll() =>
      resultOf(() => _dao.getAll());

  Stream<List<Transaction>> watchAll() => _dao.watchAll();

  Future<Result<Transaction?>> getById(int id) =>
      resultOf(() => _dao.getById(id));

  Future<Result<List<Transaction>>> getByMonth(int month, int year) =>
      resultOf(() => _dao.getByMonth(month, year));

  Stream<List<Transaction>> watchByMonth(int month, int year) =>
      _dao.watchByMonth(month, year);

  Future<Result<List<Transaction>>> getRecent(int limit) =>
      resultOf(() => _dao.getRecent(limit));

  Stream<List<Transaction>> watchRecent(int limit) =>
      _dao.watchRecent(limit);

  /// Returns total income for [month]/[year] using SQL SUM.
  Future<Result<double>> getTotalIncome(int month, int year) =>
      resultOf(() => _dao.getTotalIncome(month, year));

  /// Returns total expenses for [month]/[year] using SQL SUM.
  Future<Result<double>> getTotalExpenses(int month, int year) =>
      resultOf(() => _dao.getTotalExpenses(month, year));

  /// Returns a map of categoryId → amount for expenses in [month]/[year]
  /// using SQL GROUP BY.
  Future<Result<Map<int, double>>> getExpensesByCategory(int month, int year) =>
      resultOf(() => _dao.getExpensesByCategory(month, year));

  /// Returns total income AND total expenses for a month in one call.
  Future<Result<MonthlySummary>> getMonthlySummary(int month, int year) async {
    try {
      final income = await _dao.getTotalIncome(month, year);
      final expenses = await _dao.getTotalExpenses(month, year);
      return Success(MonthlySummary(income, expenses));
    } on AppException {
      rethrow;
    } catch (e, stack) {
      return Failure(
        DatabaseException(
          e.toString(),
          stackTrace: stack,
        ),
      );
    }
  }

  /// Returns monthly summary across all months of [year] for charting.
  Future<Result<List<MonthlySummary>>> getYearlySummary(int year) async {
    try {
      final summaries = <MonthlySummary>[];
      for (int month = 1; month <= 12; month++) {
        final income = await _dao.getTotalIncome(month, year);
        final expenses = await _dao.getTotalExpenses(month, year);
        summaries.add(MonthlySummary(income, expenses));
      }
      return Success(summaries);
    } on AppException {
      rethrow;
    } catch (e, stack) {
      return Failure(
        DatabaseException(
          e.toString(),
          stackTrace: stack,
        ),
      );
    }
  }

  // ─── Mutations ─────────────────────────────────────────────────────

  Future<Result<int>> insert(TransactionsCompanion entry) =>
      resultOf(() => _dao.insert(entry));

  Future<Result<bool>> updateEntry(int id, TransactionsCompanion entry) =>
      resultOf(() => _dao.updateEntry(id, entry));

  Future<Result<int>> deleteEntry(int id) =>
      resultOf(() => _dao.deleteEntry(id));
}

/// Simple value object holding income and expenses for a period.
class MonthlySummary {
  final double income;
  final double expenses;

  const MonthlySummary(this.income, this.expenses);

  double get balance => income - expenses;

  @override
  String toString() =>
      'MonthlySummary(income: $income, expenses: $expenses, balance: $balance)';
}
