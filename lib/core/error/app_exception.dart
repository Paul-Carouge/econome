/// Base class for all application exceptions.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => '[$runtimeType] $message${code != null ? ' ($code)' : ''}';
}

/// Exception thrown when a database operation fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when a requested entity is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when input validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when a duplicate entry is detected.
class DuplicateException extends AppException {
  const DuplicateException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when a budget is exceeded or constraint violated.
class BudgetExceededException extends AppException {
  final double currentSpending;
  final double budgetLimit;

  const BudgetExceededException(
    super.message, {
    required this.currentSpending,
    required this.budgetLimit,
    super.code,
    super.stackTrace,
  });
}
