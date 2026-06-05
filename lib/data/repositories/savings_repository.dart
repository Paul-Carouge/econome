import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../database/dao/savings_dao.dart';
import '../database/app_database.dart';

/// Repository that handles all savings-goal-related business logic.
class SavingsRepository {
  final SavingsDao _dao;

  SavingsRepository(this._dao);

  // ─── Queries ───────────────────────────────────────────────────────

  Stream<List<SavingsGoal>> watchAll() => _dao.watchAll();

  Future<Result<List<SavingsGoal>>> getAll() =>
      resultOf(() => _dao.getAll());

  Future<Result<SavingsGoal?>> getById(int id) =>
      resultOf(() => _dao.getById(id));

  // ─── Mutations ─────────────────────────────────────────────────────

  /// Inserts a new savings goal with validation.
  Future<Result<int>> insert(SavingsGoalsCompanion entry) async {
    try {
      if (entry.targetAmount.value <= 0) {
        return Failure(
          ValidationException('L\'objectif doit avoir un montant positif'),
        );
      }
      final id = await _dao.insert(entry);
      return Success(id);
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

  /// Updates an existing savings goal.
  Future<Result<bool>> updateEntry(int id, SavingsGoalsCompanion entry) =>
      resultOf(() => _dao.updateEntry(id, entry));

  /// Deletes a savings goal.
  Future<Result<int>> deleteEntry(int id) =>
      resultOf(() => _dao.deleteEntry(id));

  /// Adds a contribution to a savings goal.
  /// Validates that the goal exists before contributing.
  Future<Result<void>> addContribution(int id, double amount) async {
    try {
      if (amount <= 0) {
        return Failure(
          ValidationException('La contribution doit être positive'),
        );
      }
      final goal = await _dao.getById(id);
      if (goal == null) {
        return Failure(
          NotFoundException('Objectif d\'épargne introuvable (id: $id)'),
        );
      }
      await _dao.addContribution(id, amount);
      return const Success(null);
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
