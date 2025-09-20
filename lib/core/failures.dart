abstract class BaseFailure implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const BaseFailure(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => message;
}

class NetworkFailure extends BaseFailure {
  const NetworkFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class ParsingFailure extends BaseFailure {
  const ParsingFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class NotFoundFailure extends BaseFailure {
  const NotFoundFailure(String message) : super(message);
}

class UnknownFailure extends BaseFailure {
  const UnknownFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}
