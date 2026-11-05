/// Errors the UI knows how to show. The data layer never lets raw
/// exceptions (Dio, platform) escape: it maps them to a [Failure].
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// No connection, timeout or server unreachable.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your internet connection and try again.']);
}

/// The API rejected the request with a known error `code`
/// (from its `application/problem+json` body).
final class ApiFailure extends Failure {
  const ApiFailure({required this.statusCode, required this.code, required String message, this.fieldErrors = const {}})
    : super(message);

  final int statusCode;
  final String code;

  /// Validation errors per field, e.g. `{'email': 'must be a well-formed email address'}`.
  final Map<String, String> fieldErrors;
}

/// Session expired and could not be refreshed: the user must sign in again.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Your session has expired. Please sign in again.']);
}

/// Anything unexpected.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
