import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/core/errors/error_mapper.dart';
import 'package:geops_mobile/core/errors/failure.dart';

void main() {
  final request = RequestOptions(path: '/test');

  DioException badResponse(int status, Object? body) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(requestOptions: request, statusCode: status, data: body),
  );

  test('timeouts and connection errors become NetworkFailure', () {
    for (final type in [DioExceptionType.connectionTimeout, DioExceptionType.connectionError]) {
      expect(mapError(DioException(requestOptions: request, type: type)), isA<NetworkFailure>());
    }
  });

  test('problem details become ApiFailure with code and field errors', () {
    final failure = mapError(
      badResponse(400, {
        'status': 400,
        'detail': 'One or more fields are invalid.',
        'code': 'VALIDATION_FAILED',
        'errors': {'email': 'must be a well-formed email address'},
      }),
    );

    expect(failure, isA<ApiFailure>());
    failure as ApiFailure;
    expect(failure.code, 'VALIDATION_FAILED');
    expect(failure.statusCode, 400);
    expect(failure.fieldErrors['email'], 'must be a well-formed email address');
  });

  test('wrong credentials stay an ApiFailure, other 401s mean the session expired', () {
    final wrongPassword = mapError(badResponse(401, {'code': 'AUTH_INVALID_CREDENTIALS', 'detail': 'Invalid'}));
    expect(wrongPassword, isA<ApiFailure>());

    expect(mapError(badResponse(401, {'code': 'AUTH_TOKEN_EXPIRED'})), isA<UnauthorizedFailure>());
    expect(mapError(badResponse(401, null)), isA<UnauthorizedFailure>());
  });

  test('anything else becomes UnknownFailure', () {
    expect(mapError(Exception('boom')), isA<UnknownFailure>());
    expect(mapError(badResponse(500, '<html>')), isA<UnknownFailure>());
  });
}
