abstract class BaseFailure implements Exception {
  const BaseFailure(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

class NetworkFailure extends BaseFailure {
  const NetworkFailure(super.message, {super.cause, super.stackTrace});
}

class ParsingFailure extends BaseFailure {
  const ParsingFailure(super.message, {super.cause, super.stackTrace});
}

class NotFoundFailure extends BaseFailure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends BaseFailure {
  const UnknownFailure(super.message, {super.cause, super.stackTrace});
}
