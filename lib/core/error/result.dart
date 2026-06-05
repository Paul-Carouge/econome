import 'app_exception.dart';

/// A sealed result type that represents either a successful value or a failure.
///
/// Use [Result.success] for happy paths and [Result.failure] for errors.
/// Pattern-match with `switch` or use [when]/[map] to handle both cases.
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result] wrapping [value].
  factory Result.success(T value) = Success<T>;

  /// Creates a failed [Result] wrapping an [AppException].
  factory Result.failure(AppException error) = Failure<T>;

  /// Returns the success value or throws the [AppException] on failure.
  T getOrThrow() => switch (this) {
        Success(value: final v) => v,
        Failure(error: final e) => throw e,
      };

  /// Returns the success value or [defaultValue] on failure.
  T getOrElse(T defaultValue) => switch (this) {
        Success(value: final v) => v,
        Failure() => defaultValue,
      };

  /// Returns the success value or `null` on failure.
  T? getOrNull() => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  /// Applies [onSuccess] if this is a [Success], or [onFailure] if this is a [Failure].
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(AppException error) onFailure,
  }) =>
      switch (this) {
        Success(value: final v) => onSuccess(v),
        Failure(error: final e) => onFailure(e),
      };

  /// Transforms the success value using [fn], preserving the failure case.
  Result<R> map<R>(R Function(T value) fn) => switch (this) {
        Success(value: final v) => Success(fn(v)),
        Failure(error: final e) => Failure(e),
      };

  /// Returns `true` if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this is a [Failure].
  bool get isFailure => this is Failure<T>;
}

/// Represents a successful operation with a value of type [T].
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed operation with an [AppException] error.
final class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);

  @override
  String toString() => 'Failure(${error.runtimeType}: ${error.message})';
}

/// Extension on [Future<Result<T>>] for ergonomic chaining.
extension FutureResultExtension<T> on Future<Result<T>> {
  /// Returns the success value or throws on failure.
  Future<T> getOrThrow() async => (await this).getOrThrow();

  /// Returns the success value or [defaultValue] on failure.
  Future<T> getOrElse(T defaultValue) async => (await this).getOrElse(defaultValue);

  /// Returns the success value or `null` on failure.
  Future<T?> getOrNull() async => (await this).getOrNull();

  /// Applies [onSuccess] or [onFailure] on completion.
  Future<R> when<R>({
    required R Function(T value) onSuccess,
    required R Function(AppException error) onFailure,
  }) async =>
      (await this).when(onSuccess: onSuccess, onFailure: onFailure);
}

/// Helper to wrap async code that may throw into a [Result].
///
/// ```dart
/// final result = await resultOf(() => dao.someOperation());
/// ```
Future<Result<T>> resultOf<T>(Future<T> Function() fn) async {
  try {
    final value = await fn();
    return Success(value);
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

/// Helper to wrap sync code that may throw into a [Result].
///
/// ```dart
/// final result = resultOfSync(() => riskyOperation());
/// ```
Result<T> resultOfSync<T>(T Function() fn) {
  try {
    return Success(fn());
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
