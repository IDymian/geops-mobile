import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/core/network/auth_interceptor.dart';
import 'package:geops_mobile/core/storage/token_storage.dart';

/// In-memory token storage.
class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage(this.tokens);

  TokenPair? tokens;

  @override
  Future<TokenPair?> read() async => tokens;

  @override
  Future<void> save(TokenPair tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async => tokens = null;
}

/// Fake API: `/me` accepts only the current access token; `/auth/refresh` rotates tokens.
class FakeApi implements HttpClientAdapter {
  FakeApi({this.refreshSucceeds = true});

  final bool refreshSucceeds;
  String validAccessToken = 'access-2';
  int refreshCalls = 0;
  final List<String?> authHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final auth = options.headers['Authorization'] as String?;
    authHeaders.add(auth);

    if (options.path == '/auth/refresh') {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return refreshSucceeds
          ? _json(200, {'accessToken': validAccessToken, 'refreshToken': 'refresh-2'})
          : _json(401, {'code': 'AUTH_REFRESH_INVALID'});
    }
    if (options.path.startsWith('/auth/')) return _json(200, {'ok': true}); // public endpoints
    return auth == 'Bearer $validAccessToken' ? _json(200, {'ok': true}) : _json(401, {'code': 'AUTH_UNAUTHORIZED'});
  }

  ResponseBody _json(int status, Map<String, Object?> body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeTokenStorage storage;
  late FakeApi api;
  late Dio dio;
  late int sessionExpiredCalls;

  Dio buildClient(FakeApi adapter) => Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;

  void setUpClient({bool refreshSucceeds = true}) {
    storage = FakeTokenStorage(const TokenPair(accessToken: 'access-1', refreshToken: 'refresh-1'));
    api = FakeApi(refreshSucceeds: refreshSucceeds);
    sessionExpiredCalls = 0;
    final plain = buildClient(api);
    dio = buildClient(api)
      ..interceptors.add(
        AuthInterceptor(
          tokenStorage: storage,
          refreshClient: plain,
          retryClient: plain,
          onSessionExpired: () => sessionExpiredCalls++,
        ),
      );
  }

  test('attaches the access token to API calls but not to auth endpoints', () async {
    setUpClient();
    api.validAccessToken = 'access-1';

    await dio.get<Object?>('/me');
    await dio.post<Object?>('/auth/login', data: {});

    expect(api.authHeaders, ['Bearer access-1', null]);
  });

  test('on 401 it refreshes once, stores the new tokens and retries', () async {
    setUpClient();

    final response = await dio.get<Map<String, Object?>>('/me');

    expect(response.statusCode, 200);
    expect(api.refreshCalls, 1);
    expect(storage.tokens?.accessToken, 'access-2');
    expect(storage.tokens?.refreshToken, 'refresh-2');
    expect(api.authHeaders.last, 'Bearer access-2');
  });

  test('several requests failing at once trigger a single refresh', () async {
    setUpClient();

    final responses = await Future.wait([dio.get<Object?>('/me'), dio.get<Object?>('/me'), dio.get<Object?>('/me')]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(api.refreshCalls, 1);
  });

  test('when the refresh fails the session ends and the 401 reaches the caller', () async {
    setUpClient(refreshSucceeds: false);

    await expectLater(
      dio.get<Object?>('/me'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
    );
    expect(storage.tokens, isNull);
    expect(sessionExpiredCalls, 1);
  });
}
