sealed class Result<T> {
  const Result();

  R when<R>(
      {required R Function(T data) success,
      required R Function(Failure failure) error}) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    return error((self as Error<T>).failure);
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  Failure? get failureOrNull =>
      this is Error<T> ? (this as Error<T>).failure : null;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

abstract class Failure {
  const Failure(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause, super.stackTrace});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause, super.stackTrace});
}
