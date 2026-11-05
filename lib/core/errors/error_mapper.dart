import 'package:dio/dio.dart';

import 'failure.dart';

/// Maps any error thrown while calling the API to a [Failure].
///
/// The API answers errors as RFC 9457 problem details:
/// `{ "status": 400, "detail": "...", "code": "VALIDATION_FAILED", "errors": { ... } }`.
Failure mapError(Object error) {
  if (error is Failure) return error;
  if (error is! DioException) return const UnknownFailure();

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return _fromResponse(error.response);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const UnknownFailure();
  }
}

Failure _fromResponse(Response<Object?>? response) {
  final statusCode = response?.statusCode ?? 0;
  final body = response?.data;

  if (body is Map<String, Object?>) {
    final code = body['code'];
    final detail = body['detail'];
    final errors = body['errors'];
    if (code is String) {
      if (statusCode == 401 && code != 'AUTH_INVALID_CREDENTIALS') {
        return const UnauthorizedFailure();
      }
      return ApiFailure(
        statusCode: statusCode,
        code: code,
        message: detail is String ? detail : 'Request failed.',
        fieldErrors: errors is Map<String, Object?> ? {for (final e in errors.entries) e.key: '${e.value}'} : const {},
      );
    }
  }

  if (statusCode == 401) return const UnauthorizedFailure();
  return const UnknownFailure();
}
