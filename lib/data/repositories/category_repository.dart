import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../database/dao/category_dao.dart';
import '../database/app_database.dart';

/// Repository that handles all category-related business logic.
class CategoryRepository {
  final CategoryDao _dao;

  CategoryRepository(this._dao);

  // ─── Queries ───────────────────────────────────────────────────────

  Future<Result<List<Category>>> getAll() =>
      resultOf(() => _dao.getAll());

  Future<Result<List<Category>>> getByType(String type) =>
      resultOf(() => _dao.getByType(type));

  Future<Result<Category?>> getById(int id) =>
      resultOf(() => _dao.getById(id));

  Future<Result<List<Category>>> getExpenseCategories() =>
      resultOf(() => _dao.getExpenseCategories());

  Future<Result<List<Category>>> getIncomeCategories() =>
      resultOf(() => _dao.getIncomeCategories());

  Stream<List<Category>> watchAll() => _dao.watchAll();

  Stream<List<Category>> watchExpenseCategories() =>
      _dao.watchExpenseCategories();

  /// Returns total spent on a specific category using SQL SUM.
  Future<Result<double>> getTotalSpentByCategory(
    int categoryId,
    int month,
    int year,
  ) =>
      resultOf(() => _dao.getTotalSpentByCategory(categoryId, month, year));

  // ─── Mutations ─────────────────────────────────────────────────────

  Future<Result<int>> insert(CategoriesCompanion entry) =>
      resultOf(() => _dao.insert(entry));

  /// Inserts default categories if none exist.
  Future<Result<void>> insertDefaults() async {
    try {
      await _dao.insertDefaults();
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

  Future<Result<bool>> updateEntry(int id, CategoriesCompanion entry) =>
      resultOf(() => _dao.updateEntry(id, entry));

  /// Deletes a category. Returns [ValidationException] if it's a default category.
  Future<Result<int>> deleteEntry(int id) async {
    try {
      final cat = await _dao.getById(id);
      if (cat == null) {
        return Failure(
          NotFoundException('Catégorie introuvable (id: $id)'),
        );
      }
      if (!cat.isCustom) {
        return Failure(
          ValidationException('Impossible de supprimer une catégorie par défaut'),
        );
      }
      final result = await _dao.deleteEntry(id);
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
}
