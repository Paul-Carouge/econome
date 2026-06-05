import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../database/dao/budget_dao.dart';
import '../database/app_database.dart';

/// Repository that handles all budget-related business logic.
///
/// Delegates data access to [BudgetDao] and wraps results in [Result].
class BudgetRepository {
  final BudgetDao _dao;

  BudgetRepository(this._dao);

  // ─── Queries ───────────────────────────────────────────────────────

  Stream<List<Budget>> watchAll() => _dao.watchAll();

  Future<Result<Budget?>> getByMonth(int month, int year) =>
      resultOf(() => _dao.getByMonth(month, year));

  // ─── Mutations ─────────────────────────────────────────────────────

  /// Upserts a budget with validation.
  /// Returns [ValidationException] if totalBudget is negative.
  Future<Result<int>> upsert(BudgetsCompanion entry) async {
    try {
      final budget = entry.totalBudget.value;
      if (budget < 0) {
        return Failure(
          ValidationException('Le budget ne peut pas être négatif'),
        );
      }
      final id = await _dao.upsert(entry);
      return Success(id);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        DatabaseException(
          e.toString(),
          stackTrace: stack,
        ),
      );
    }
  }

  /// Deletes a budget by id.
  Future<Result<int>> deleteEntry(int id) =>
      resultOf(() => _dao.deleteEntry(id));

  /// Checks if the monthly budget is exceeded for a given spending amount.
  Future<Result<bool>> isBudgetExceeded(int month, int year, double spending) async {
    try {
      final budget = await _dao.getByMonth(month, year);
      if (budget == null) return const Success(false);
      return Success(spending > budget.totalBudget);
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
}
