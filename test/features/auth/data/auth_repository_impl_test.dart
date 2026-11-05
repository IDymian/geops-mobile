import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/core/storage/token_storage.dart';
import 'package:geops_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:geops_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:geops_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:geops_mobile/features/auth/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockRemote remote;
  late MockTokenStorage storage;
  late AuthRepositoryImpl repository;

  const response = AuthResponseModel(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
    expiresIn: 900,
    user: UserModel(id: 'u-1', email: 'ana@example.com', fullName: 'Ana Torres', role: UserRoleModel.provider),
  );

  DioException apiError(int status, Map<String, Object?> body) {
    final request = RequestOptions(path: '/auth/login');
    return DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<Object?>(requestOptions: request, statusCode: status, data: body),
    );
  }

  setUpAll(() => registerFallbackValue(const TokenPair(accessToken: '', refreshToken: '')));

  setUp(() {
    remote = MockRemote();
    storage = MockTokenStorage();
    repository = AuthRepositoryImpl(remote, storage);
    when(() => storage.save(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
  });

  test('login saves both tokens securely and returns the user', () async {
    when(() => remote.login(email: 'ana@example.com', password: 'Secreta123')).thenAnswer((_) async => response);

    final user = await repository.login(email: '  ana@example.com ', password: 'Secreta123');

    expect(user.role, UserRole.provider);
    final saved = verify(() => storage.save(captureAny())).captured.single as TokenPair;
    expect(saved.accessToken, 'access-1');
    expect(saved.refreshToken, 'refresh-1');
  });

  test('login errors become a Failure with the API code', () async {
    when(
      () => remote.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(apiError(401, {'code': 'AUTH_INVALID_CREDENTIALS', 'detail': 'Invalid email or password.'}));

    expect(
      repository.login(email: 'ana@example.com', password: 'nope'),
      throwsA(isA<ApiFailure>().having((f) => f.code, 'code', 'AUTH_INVALID_CREDENTIALS')),
    );
  });

  test('restoreSession without stored tokens returns null', () async {
    when(() => storage.read()).thenAnswer((_) async => null);

    expect(await repository.restoreSession(), isNull);
    verifyNever(() => remote.refresh(any()));
  });

  test('restoreSession refreshes the stored token', () async {
    when(() => storage.read()).thenAnswer((_) async => const TokenPair(accessToken: 'old', refreshToken: 'r-old'));
    when(() => remote.refresh('r-old')).thenAnswer((_) async => response);

    final user = await repository.restoreSession();

    expect(user?.email, 'ana@example.com');
    verify(() => storage.save(any())).called(1);
  });

  test('restoreSession with a revoked token clears it and signs out', () async {
    when(() => storage.read()).thenAnswer((_) async => const TokenPair(accessToken: 'old', refreshToken: 'r-old'));
    when(() => remote.refresh('r-old')).thenThrow(apiError(401, {'code': 'AUTH_REFRESH_INVALID'}));

    expect(await repository.restoreSession(), isNull);
    verify(() => storage.clear()).called(1);
  });

  test('restoreSession offline keeps the tokens and reports a NetworkFailure', () async {
    when(() => storage.read()).thenAnswer((_) async => const TokenPair(accessToken: 'old', refreshToken: 'r-old'));
    when(() => remote.refresh('r-old')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        type: DioExceptionType.connectionError,
      ),
    );

    await expectLater(repository.restoreSession(), throwsA(isA<NetworkFailure>()));
    verifyNever(() => storage.clear());
  });

  test('logout clears local tokens even if the server is unreachable', () async {
    when(() => storage.read()).thenAnswer((_) async => const TokenPair(accessToken: 'a', refreshToken: 'r'));
    when(() => remote.logout('r')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/logout'),
        type: DioExceptionType.connectionError,
      ),
    );

    await repository.logout();

    verify(() => storage.clear()).called(1);
  });
}
