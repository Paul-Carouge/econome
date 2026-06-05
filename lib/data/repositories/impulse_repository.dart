import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../database/dao/impulse_dao.dart';
import '../database/app_database.dart';

/// Repository that handles all impulse-item-related business logic.
class ImpulseRepository {
  final ImpulseDao _dao;

  ImpulseRepository(this._dao);

  // ─── Queries ───────────────────────────────────────────────────────

  Stream<List<ImpulseItem>> watchAll() => _dao.watchAll();

  Stream<List<ImpulseItem>> watchByStatus(String status) =>
      _dao.watchByStatus(status);

  Future<Result<List<ImpulseItem>>> getCooling() =>
      resultOf(() => _dao.getCooling());

  Future<Result<ImpulseItem?>> getById(int id) =>
      resultOf(() => _dao.getById(id));

  /// Returns the count of active (cooling) impulse items using SQL COUNT.
  Future<Result<int>> getActiveCount() =>
      resultOf(() => _dao.getActiveCount());

  // ─── Mutations ─────────────────────────────────────────────────────

  Future<Result<int>> insert(ImpulseItemsCompanion entry) =>
      resultOf(() => _dao.insert(entry));

  /// Updates the status of an impulse item.
  /// Validates that the status is one of the allowed values.
  Future<Result<bool>> updateStatus(int id, String status) async {
    try {
      if (!['cooling', 'approved', 'dismissed'].contains(status)) {
        return Failure(
          ValidationException('Statut invalide : $status'),
        );
      }
      final result = await _dao.updateStatus(id, status);
      return Success(result);
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

  Future<Result<int>> deleteEntry(int id) =>
      resultOf(() => _dao.deleteEntry(id));
}
